"""The `sigstore_rekor_types` APIs."""

from __future__ import annotations

from calendar import c
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, RootModel, StrictStr

from ._internal import (  # noqa: F401
    alpine,
    cose,
    dsse,
    hashedrekord,
    helm,
    intoto,
    jar,
    rekord,
    rfc3161,
    rpm,
    tuf,
)

__version__ = "0.0.11"


class _ProposedEntryMixin(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )
    api_version: StrictStr = Field(
        pattern=r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$",
        default="0.0.1",
    )
    kind: StrictStr
    spec: _Spec = Field(..., discriminator="kind")


class Alpine(_ProposedEntryMixin):
    kind: Literal["alpine"]
    spec: alpine.AlpinePackageSchema


class Cose(_ProposedEntryMixin):
    kind: Literal["cose"]
    spec: cose.CoseSchema


class Dsse(_ProposedEntryMixin):
    kind: Literal["dsse"]
    spec: dsse.DsseSchema


class Hashedrekord(_ProposedEntryMixin):
    kind: Literal["hashedrekord"]
    spec: hashedrekord.RekorSchema


class Helm(_ProposedEntryMixin):
    kind: Literal["helm"]
    spec: helm.HelmSchema


class Intoto(_ProposedEntryMixin):
    kind: Literal["intoto"]
    spec: intoto.IntotoSchema


class Jar(_ProposedEntryMixin):
    kind: Literal["jar"]
    spec: jar.JarSchema


class Rekord(_ProposedEntryMixin):
    kind: Literal["rekord"]
    spec: rekord.RekorSchema


_Spec = Alpine | Cose | Dsse | Hashedrekord | Helm | Intoto | Jar | Rekord
