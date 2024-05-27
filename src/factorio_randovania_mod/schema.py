from __future__ import annotations

import json
import typing
from pathlib import Path

from jsonschema import Draft7Validator

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import Configuration

_SCHEMA_PATH = Path(__file__).parent.joinpath("files", "schema.json")


def _read_schema() -> dict:
    with _SCHEMA_PATH.open() as f:
        return json.load(f)


def validate(data: dict) -> Configuration:
    Draft7Validator(_read_schema()).validate(data)

    return typing.cast("Configuration", data)
