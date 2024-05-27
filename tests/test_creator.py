import json
from pathlib import Path

from factorio_randovania_mod import creator


def test_create_no_game(tmp_path: Path, test_files: Path) -> None:
    with test_files.joinpath("patcher_a.json").open() as f:
        patch_data = json.load(f)

    creator.create(None, patch_data, tmp_path.joinpath("mod"))

    files = list(tmp_path.joinpath("mod").rglob("*"))
    assert len(files) == 21
