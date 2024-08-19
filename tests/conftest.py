from pathlib import Path

import pytest

_DIR = Path(__file__).parent


@pytest.fixture
def test_files() -> Path:
    return _DIR.joinpath("test_files")
