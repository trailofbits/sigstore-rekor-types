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

# NOTE(ww): For whatever reason, the POST endpoint doesn't work. Instead,
# we tell the converter to retrieve the OpenAPI YAML URL itself.
curl -X 'GET' \
  "https://converter.swagger.io/api/convert?url=https%3A%2F%2Fraw.githubusercontent.com%2Fsigstore%2Frekor%2F${rekor_ref}%2Fopenapi.yaml" \
  -H 'accept: application/json' \
  > "${rekor_dir}/openapi.json"

datamodel-codegen \
    --input "${rekor_dir}/openapi.json" \
    --input-file-type openapi \
    --target-python-version 3.8 \
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
    --output "${pkg_dir}/_internal.py"

# Cap it off by auto-reformatting.
make -C "${here}/.." reformat

# Once more for good luck.
make -C "${here}/.." reformat
