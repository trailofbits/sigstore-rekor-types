"""The `sigstore_rekor_types` APIs."""

from __future__ import annotations

import sys
from typing import Literal, Union

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr

from ._internal import (
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

if sys.version_info < (3, 9):
    from typing_extensions import Annotated
else:
    from typing import Annotated

__version__ = "0.0.18"


class Error(BaseModel):
    """A Rekor server error."""

    code: StrictInt
    message: StrictStr


class _ProposedEntryMixin(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )
    api_version: StrictStr = Field(
        pattern=r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$",
        default="0.0.1",
        alias="apiVersion",
    )


class Alpine(_ProposedEntryMixin):
    """Proposed entry model for an `alpine` record."""

    kind: Literal["alpine"] = "alpine"
    spec: alpine.AlpinePackageSchema


class Cose(_ProposedEntryMixin):
    """Proposed entry model for a `cose` record."""

    kind: Literal["cose"] = "cose"
    spec: cose.CoseSchema


class Dsse(_ProposedEntryMixin):
    """Proposed entry model for a `dsse` record."""

    kind: Literal["dsse"] = "dsse"
    spec: dsse.DsseSchema


class Hashedrekord(_ProposedEntryMixin):
    """Proposed entry model for a `dsse` record."""

    kind: Literal["hashedrekord"] = "hashedrekord"
    spec: hashedrekord.HashedrekordSchema


class Helm(_ProposedEntryMixin):
    """Proposed entry model for a `dsse` record."""

    kind: Literal["helm"] = "helm"
    spec: helm.HelmSchema


class Intoto(_ProposedEntryMixin):
    """Proposed entry model for a `dsse` record."""

    kind: Literal["intoto"] = "intoto"
    spec: intoto.IntotoSchema


class Jar(_ProposedEntryMixin):
    """Proposed entry model for a `jar` record."""

    kind: Literal["jar"] = "jar"
    spec: jar.JarSchema


class Rekord(_ProposedEntryMixin):
    """Proposed entry model for a `rekord` record."""

    kind: Literal["rekord"] = "rekord"
    spec: rekord.RekorSchema


class Rfc3161(_ProposedEntryMixin):
    """Proposed entry model for a `rfc3161` record."""

    kind: Literal["rfc3161"] = "rfc3161"
    spec: rfc3161.TimestampSchema


class Rpm(_ProposedEntryMixin):
    """Proposed entry model for an `rpm` record."""

    kind: Literal["rpm"] = "rpm"
    spec: rpm.RpmSchema


class Tuf(_ProposedEntryMixin):
    """Proposed entry model for a `tuf` record."""

    kind: Literal["tuf"] = "tuf"
    spec: tuf.TufSchema


ProposedEntry = Annotated[
    Union[Alpine, Cose, Dsse, Hashedrekord, Helm, Intoto, Jar, Rekord, Rfc3161, Rpm, Tuf],
    Field(discriminator="kind"),
]
