# generated by datamodel-codegen:

from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, RootModel


class PublicKey(BaseModel):
    """The X509 certificate containing the public key JAR which verifies the signature of the JAR."""

    model_config = ConfigDict(
        populate_by_name=True,
    )
    content: str = Field(
        ...,
        description=(
            "Specifies the content of the X509 certificate containing the public key used to verify"
            " the signature"
        ),
    )


class Signature(BaseModel):
    """Information about the included signature in the JAR file."""

    model_config = ConfigDict(
        populate_by_name=True,
    )
    content: str = Field(
        ...,
        description="Specifies the PKCS7 signature embedded within the JAR file ",
    )
    public_key: PublicKey = Field(
        ...,
        alias="publicKey",
        description=(
            "The X509 certificate containing the public key JAR which verifies the signature of"
            " the JAR"
        ),
    )


class JarV001Schema(BaseModel):
    """Schema for JAR entries."""

    model_config = ConfigDict(
        populate_by_name=True,
    )
    signature: Optional[Signature] = Field(
        default=None,
        description="Information about the included signature in the JAR file",
    )


class JarSchema(RootModel[JarV001Schema]):
    model_config = ConfigDict(
        populate_by_name=True,
    )
    root: JarV001Schema = Field(..., description="Schema for JAR objects", title="JAR Schema")