import hashlib
import json
from pathlib import Path

from factorio_randovania_mod import layout_string


def test_create(test_files: Path) -> None:
    with test_files.joinpath("patcher_a.json").open() as f:
        patch_data = json.load(f)

    result = layout_string.create_string(patch_data)

    assert hashlib.sha256(result.encode("ascii")).digest() == (
        b"\x1a\xa1j\x9f1\x18\xa8\xff\xd2\xcf\x97\xbc\xb4=\xdf\xe4\x1f\x88\x94*%\xac\xb3K\x9f(\xd3\n\xdf\xb9\x02\x08"
    )
