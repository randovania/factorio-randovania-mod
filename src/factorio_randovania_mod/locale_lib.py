from __future__ import annotations

import itertools
import os
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import configparser
    from pathlib import Path


def get_from_locale(locale: configparser.ConfigParser, group: str, n: str) -> str:
    if n in locale[group]:
        return locale[group][n]
    if f"{n}-1" in locale[group]:
        return locale[group][f"{n}-1"]

    i = n.rfind("-")
    if i != -1:
        front, number = n[:i], n[i + 1 :]
        if number.isdigit():
            return get_from_locale(locale, group, front)

    raise KeyError(n)


def get_localized_name(locale: configparser.ConfigParser, n: str) -> str:
    for k in [
        "item-name",
        "entity-name",
        "fluid-name",
        "equipment-name",
        "recipe-name",
        "technology-name",
    ]:
        if n in locale[k]:
            return locale[k][n]
        if f"{n}-1" in locale[k]:
            return locale[k][f"{n}-1"]

    if n.startswith("fill-"):
        return f"Fill {locale['fluid-name'][n[5:-7]]} barrel"

    if n.endswith("-barrel"):
        return f"{locale['fluid-name'][n[:-7]]} barrel"

    hardcoded_names = {
        "solid-fuel-from-heavy-oil": "Solid Fuel (Heavy Oil)",
        "solid-fuel-from-light-oil": "Solid Fuel (Light Oil)",
        "solid-fuel-from-petroleum-gas": "Solid Fuel (Petroleum Gas)",
    }

    try:
        return hardcoded_names[n]
    except KeyError:
        i = n.rfind("-")
        if i != -1:
            front, number = n[:i], n[i + 1 :]
            if number.isdigit():
                return f"{get_localized_name(locale, front)} {number}"
        raise


def ensure_locale_read(locale: configparser.ConfigParser, files: list[Path]) -> None:
    for file in files:
        with file.open() as fp:
            locale.read_file(itertools.chain(["[global]"], fp), source=os.fspath(file))
