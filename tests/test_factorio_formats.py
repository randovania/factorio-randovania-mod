from pathlib import Path

from construct import Container

from factorio_randovania_mod.factorio_formats import ModSettings, SpaceOptimizedUInt


def test_space_optimized():
    assert SpaceOptimizedUInt.build(0) == b"\x00"
    assert SpaceOptimizedUInt.build(254) == b"\xfe"
    assert SpaceOptimizedUInt.build(255) == b"\xff\xff\x00\x00\x00"


def test_decode_mod_settings(test_files: Path) -> None:
    settings_file = test_files.joinpath("mod-settings.dat")
    assert ModSettings.parse_file(settings_file) == Container(
        game_version=Container(main=2, major=0, minor=7, developer=0),
        tree=Container(
            [
                (
                    "startup",
                    Container(
                        [
                            ("sl-speed-multiplier", Container(value=2)),
                            ("sl-packaged-fuel-return-canister", Container(value=False)),
                            ("sl-train-fuel", Container(value=False)),
                        ]
                    ),
                ),
                ("runtime-global", Container()),
                ("runtime-per-user", Container()),
            ]
        ),
    )
