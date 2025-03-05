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
        b"\x8e\xd19\x9e\xbc\x1b\x1a\xf8KD\xca\x92@\xda#\x17\x8a\xf7\xa7\x1c\x08D0\xa5:P\xf1\xd2E~\xa7/"
    )
