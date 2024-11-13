def test_import():
    import rekor_types

    assert isinstance(rekor_types.__version__, str)
