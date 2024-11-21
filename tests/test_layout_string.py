import hashlib
import json
from pathlib import Path

from factorio_randovania_mod import layout_string


def test_create(test_files: Path) -> None:
    with test_files.joinpath("patcher_a.json").open() as f:
        patch_data = json.load(f)

    result = layout_string.create_string(patch_data)

    assert hashlib.sha256(result.encode("ascii")).digest() == (
        b"k\xe0\xd2\xa4\x83\xff\xe9\xb4\x896X1\x1e\x9a\x13p[\xd6\xaf\x16\xa7h\xee=g\xcb\xc5\x82\x8a\x9a\xfb\t"
    )
