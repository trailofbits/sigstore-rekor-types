import sigstore_rekor_types


def test_version() -> None:
    version = getattr(sigstore_rekor_types, "__version__", None)
    assert version is not None
    assert isinstance(version, str)
