#!/usr/bin/env bash

# codegen: generate Python models from Rekor's OpenAPI specs
#
# The way we do this is a little roundabout:
# 1. We `git clone` a copy of Rekor at the version we're generating from
# 2. We use the online Swagger conversion API to turn Rekor's Swagger 2.0
#    definition into an OpenAPI 3.0 definition, and save the converted
#    definition into the Rekor root directory
# 3. We use `datamodel-codegen` to generate models from the 3.0 definition.
#
# This indirection is necessary because of various incompatibilities between
# components: Rekor uses OpenAPI/Swagger 2.0 because go-swagger only supports
# 2.0, while datamodel-codegen uses OpenAPI 3.0.

set -eo pipefail

# Always enable debug logging in CI.
DEBUG="${DEBUG:-${CI}}"

dbg() {
    [[ -n "${DEBUG}" ]] && >&2 echo "[+] ${*}"
}

type -p datamodel-codegen || { >&2 echo "barf: missing datamodel-codegen"; exit 1; }

here="$(dirname -- "$(readlink -f -- "${0}")")"
pkg_dir="$(readlink -f -- "${here}/../sigstore_rekor_types")"
[[ -d "${pkg_dir}" ]] || { >&2 echo "missing package dir: ${pkg_dir}"; exit 1; }
dbg "codegen running from ${here} and writing to ${pkg_dir}"

rekor_ref="$(<"${here}/version")"
dbg "generating from Rekor ${rekor_ref}"

rekor_dir=$(mktemp -d)/rekor
dbg "cloning Rekor into ${rekor_dir}"
git clone --quiet \
    --depth=1 \
    --branch="${rekor_ref}" \
    https://github.com/sigstore/rekor \
    "${rekor_dir}"

# NOTE(ww): Everything below happens because of a confluence of unfortunate
# factors:
#
#  * Rekor's top-level `openapi.yaml` is written in OpenAPI 2.0 (because go-swagger
#    only supports 2.0)
#  * `datamodel-codegen` only supports OpenAPI 3.0+
#  * If we convert Rekor's `openapi.yaml` into an OpenAPI 3.0 format, then
#    `datamodel-codegen` *works*, but produces suboptimal code (lots
#    of duplicated models like `Hash1`, `Hash2`, etc. in the same namespace).
#
# To get around all of this, we poke through each internal JSON Schema definition
# used by Rekor and generate them one-by-one into their own modules.
#
# See:
#  * https://github.com/go-swagger/go-swagger/issues/1122
#  * https://github.com/koxudaxi/datamodel-code-generator/issues/1590
#  * https://github.com/sigstore/rekor/issues/1729
mkdir -p "${pkg_dir}/_internal"
touch "${pkg_dir}/_internal/__init__.py"
rekor_types=(alpine cose dsse hashedrekord helm intoto jar rekord rfc3161 rpm tuf)
for type in "${rekor_types[@]}"; do
    dbg "generating models for Rekor type: ${type}"
    datamodel-codegen \
        --input "${rekor_dir}/pkg/types/${type}/${type}_schema.json" \
        --input-file-type jsonschema \
        --target-python-version 3.8 \
        --collapse-root-models \
        --snake-case-field \
        --capitalize-enum-members \
        --field-constraints \
        --use-schema-description \
        --use-subclass-enum \
        --disable-timestamp \
        --reuse-model \
        --use-default-kwarg \
        --allow-population-by-field-name \
        --strict-types str bytes int float bool \
        --output-model-type pydantic_v2.BaseModel \
        --output "${pkg_dir}/_internal/${type}.py"
done

# Cap it off by auto-reformatting.
make -C "${here}/.." reformat

# Once more for good luck.
make -C "${here}/.." reformat
