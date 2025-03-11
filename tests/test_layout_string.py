from __future__ import annotations

import hashlib
import json
from typing import TYPE_CHECKING

from factorio_randovania_mod import layout_string

if TYPE_CHECKING:
    from pathlib import Path

    import pytest_mock


def test_create(test_files: Path, mocker: pytest_mock.MockFixture) -> None:
    mocker.patch("factorio_randovania_mod.mod_lua_api.mod_version", return_value="0.2.0")

    with test_files.joinpath("patcher_a.json").open() as f:
        patch_data = json.load(f)

    result = layout_string.create_string(patch_data)

    assert hashlib.sha256(result.encode("ascii")).digest() == (
        b"z\x8d\x12\xf6d\xcf\xefaO\x14\x03\xfd\xc1.\xbc\x86c\xe3\xdc\xe2\x8a%\x88N\x84\xe8\x7f3r\xd9Qc"
    )
