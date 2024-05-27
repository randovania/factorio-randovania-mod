from __future__ import annotations

import string
import typing


def wrap_array_pretty(data: list) -> str:
    return "{\n    " + ",\n    ".join(wrap(item, "    ") for item in data) + "\n}"


def _dict_key(key: str) -> str:
    if set(key).issubset(string.ascii_letters + "_"):
        return key
    else:
        return f'["{key}"]'


def wrap(data: typing.Any, indent: str = "") -> str:
    if isinstance(data, list | tuple):
        return "{" + ", ".join(wrap(item, indent) for item in data) + "}"

    if isinstance(data, dict):
        return (
            "{\n"
            + "\n".join(
                f"{indent}    {_dict_key(key)} = {wrap(value, f'{indent}    ')}," for key, value in data.items()
            )
            + f"\n{indent}}}"
        )

    if isinstance(data, bool):
        return "true" if data else "false"

    if data is None:
        return "nil"

    if isinstance(data, str):
        return f'"{data}"'

    return str(data)
