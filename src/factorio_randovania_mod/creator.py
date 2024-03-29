from __future__ import annotations

import collections
import configparser
import shutil
import typing
from pathlib import Path

import PIL.Image

from factorio_randovania_mod import color_util
from factorio_randovania_mod.lua_util import wrap_array_pretty, wrap

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import Configuration


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


template_path = Path(__file__).parent.joinpath("lua_src")


def create_burner_images(factorio_path: Path, output_path: Path) -> None:
    lab_angle = 120.0
    assembler_angle = 310.0

    base_graphics_path = factorio_path.joinpath("data/base/graphics")

    lab_images = [
        "entity/lab/lab.png",
        "entity/lab/lab-light.png",
        "entity/lab/hr-lab.png",
        "entity/lab/hr-lab-light.png",
        "icons/lab.png",
    ]
    assembler_images = [
        "entity/assembling-machine-1/assembling-machine-1.png",
        "entity/assembling-machine-1/hr-assembling-machine-1.png",
        "icons/assembling-machine-1.png",
    ]

    conversions = []

    for path in lab_images:
        conversions.append(
            (
                path,
                path.replace("lab", "burner-lab"),
                lab_angle / 360.0,
            )
        )

    for path in assembler_images:
        conversions.append(
            (
                path,
                path.replace("assembling-machine-1", "burner-assembling-machine"),
                assembler_angle / 360.0,
            )
        )

    for source_path, target_path, rotation in conversions:
        img = PIL.Image.open(base_graphics_path.joinpath(source_path))
        new_img = color_util.shift_hue(img, rotation / 360.0)
        out_path = output_path.joinpath("graphics", target_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        new_img.save(out_path)


def create(factorio_path: Path, patch_data: Configuration, output_folder: Path) -> None:
    output_path = output_folder.joinpath("randovania-layout")
    shutil.rmtree(output_path, ignore_errors=True)

    original_locale = configparser.ConfigParser()
    original_locale.read(
        [
            factorio_path.joinpath("data/base/locale/en/base.cfg"),
            template_path.joinpath("locale/en/strings.cfg"),
        ]
    )

    locale = configparser.ConfigParser()
    locale.read(
        [
            template_path.joinpath("locale/en/strings.cfg"),
        ]
    )

    tech_tree_lua = []
    progressive_sources = collections.defaultdict(list)
    local_unlocks = {}

    for tech in patch_data["technologies"]:
        tech_name = tech["tech_name"]
        locale["technology-name"][tech_name] = tech["locale_name"]
        locale["technology-description"][tech_name] = tech["description"]

        new_tech = {
            "name": tech_name,
            "icon": tech["icon"],
            "costs": {
                "count": tech["cost"]["count"],
                "time": tech["cost"]["time"],
                "ingredients": [[it, 1] for it in tech["cost"]["ingredients"]],
            },
            "prerequisites": tech["prerequisites"] if tech["prerequisites"] else None,
            # "fake_effects": tech["fake_effects"],
        }
        for extra in ["icon_size"]:
            if extra in tech:
                new_tech[extra] = tech[extra]
        tech_tree_lua.append(new_tech)

        if len(tech["unlocks"]) == 1:
            new_tech["take_effects_from"] = tech["unlocks"][0]
            locale["technology-description"][tech_name] = get_from_locale(
                original_locale, "technology-description", tech["unlocks"][0]
            )
        elif tech["unlocks"]:
            local_unlocks[tech_name] = tech["unlocks"]
            progressive_sources[tuple(tech["unlocks"])].append(tech_name)

    existing_tree_repurpose = {}

    # TODO: add the offworld research to `existing_tree_repurpose`

    for progressive_sequence, sources in progressive_sources.items():
        for i, tech_name in enumerate(progressive_sequence):
            if i == 0:
                prerequisites = sources
            else:
                prerequisites = [progressive_sequence[i - 1]]

            existing_tree_repurpose[tech_name] = {
                "science_pack": "impossible-science-pack",
                "prerequisites": prerequisites,
            }

    shutil.copytree(template_path, output_path)

    def generate_file(name: str, content: str) -> None:
        output_path.joinpath("generated", name).write_text("return " + content)

    generate_file("tech-tree.lua", wrap_array_pretty(tech_tree_lua))
    generate_file("local-unlocks.lua", wrap(local_unlocks))
    generate_file("starting-tech.lua", wrap_array_pretty(patch_data["starting_tech"]))
    generate_file("existing-tree-repurpose.lua", wrap(existing_tree_repurpose))
    generate_file("custom-recipes.lua", wrap_array_pretty(patch_data["recipes"]))

    create_burner_images(factorio_path, output_path)

    with output_path.joinpath("locale/en/strings.cfg").open("w") as f:
        locale.write(f, space_around_delimiters=False)
