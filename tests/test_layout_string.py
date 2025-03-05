import hashlib
import json
from pathlib import Path

from factorio_randovania_mod import layout_string


def test_create(test_files: Path) -> None:
    with test_files.joinpath("patcher_a.json").open() as f:
        patch_data = json.load(f)

    result = layout_string.create_string(patch_data)

    assert hashlib.sha256(result.encode("ascii")).digest() == (
        b"V\xb2\x9a2_&\x7f\x91\xe87\x96h\x1e\xfaG\xbd\xe1F}\xd0c\xa7\x8e`5l7\x16;m\xa2#"
    )
