from factorio_randovania_mod.factorio_formats import SpaceOptimizedUInt


def test_space_optimized():
    assert SpaceOptimizedUInt.build(0) == b"\x00"
    assert SpaceOptimizedUInt.build(254) == b"\xfe"
    assert SpaceOptimizedUInt.build(255) == b"\xff\xff\x00\x00\x00"
