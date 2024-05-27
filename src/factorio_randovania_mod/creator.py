from __future__ import annotations

import collections
import configparser
import shutil
import typing
from pathlib import Path

from factorio_randovania_mod import schema
from factorio_randovania_mod.color_util import hue_shift
from factorio_randovania_mod.locale_lib import ensure_locale_read, get_from_locale
from factorio_randovania_mod.lua_util import wrap, wrap_array_pretty

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import (
        ConfigurationTechnologiesItem,
    )
    from factorio_randovania_mod.mod_lua_api import CustomTechTreeItem, GeneratedFiles

_TEMPLATE_PATH = Path(__file__).parent.joinpath("lua_src")


def create_hue_shifted_images(factorio_path: Path, output_path: Path) -> None:
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
        hue_shift(
            base_graphics_path.joinpath(source_path),
            output_path.joinpath("graphics", target_path),
            rotation,
        )


def process_technology(
    output_locale: configparser.ConfigParser,
    local_unlocks: dict[str, list[str]],
    progressive_sources: dict[tuple[str, ...], list[str]],
    tech: ConfigurationTechnologiesItem,
    source_locale: configparser.ConfigParser | None,
) -> CustomTechTreeItem:
    """
    Process an entry of patch_data["technologies"]
    :param output_locale:
    :param local_unlocks:
    :param progressive_sources:
    :param tech:
    :param source_locale:
    :return: A new entry for tech-tree.lua
    """
    tech_name = tech["tech_name"]
    output_locale["technology-name"][tech_name] = tech["locale_name"]
    output_locale["technology-description"][tech_name] = tech["description"]

    new_tech: CustomTechTreeItem = {
        "name": tech_name,
        "icon": tech["icon"],
        "costs": {
            "count": tech["cost"]["count"],
            "time": tech["cost"]["time"],
            "ingredients": [(it, 1) for it in tech["cost"]["ingredients"]],
        },
        "prerequisites": tech["prerequisites"] if tech["prerequisites"] else None,
        # "fake_effects": tech["fake_effects"],
    }
    if "icon_size" in tech:
        new_tech["icon_size"] = tech["icon_size"]

    if len(tech["unlocks"]) == 1:
        new_tech["take_effects_from"] = tech["unlocks"][0]
        if source_locale is not None:
            output_locale["technology-description"][tech_name] = get_from_locale(
                source_locale, "technology-description", tech["unlocks"][0]
            )
    elif tech["unlocks"]:
        local_unlocks[tech_name] = tech["unlocks"]
        progressive_sources[tuple(tech["unlocks"])].append(tech_name)

    return new_tech


def generate_output(
    output_path: Path,
    generated_files: GeneratedFiles,
    locale: configparser.ConfigParser,
    factorio_path: Path | None,
) -> None:
    """
    Generates all files for the mod.
    :param output_path: Where to place the output
    :param generated_files: Data for generating all lua files
    :param locale: Used as template
    :param factorio_path: Source for hue shifting the images
    :return:
    """
    shutil.copytree(_TEMPLATE_PATH, output_path)
    output_path.joinpath("generated").mkdir()

    def generate_file(name: str, content: str) -> None:
        output_path.joinpath("generated", name).write_text("return " + content)

    generate_file("tech-tree.lua", wrap_array_pretty(generated_files["tech_tree"]))
    generate_file("local-unlocks.lua", wrap(generated_files["local_unlocks"]))
    generate_file("existing-tree-repurpose.lua", wrap(generated_files["existing_tree_repurpose"]))

    generate_file("starting-tech.lua", wrap_array_pretty(generated_files["starting_tech"]))
    generate_file("custom-recipes.lua", wrap_array_pretty(generated_files["custom_recipes"]))

    with output_path.joinpath("locale/en/strings.cfg").open("w") as f:
        locale.write(f, space_around_delimiters=False)

    if factorio_path is not None:
        create_hue_shifted_images(factorio_path, output_path)


def create(factorio_path: Path | None, patch_data: dict, output_folder: Path) -> None:
    output_path = output_folder.joinpath("randovania-layout")
    shutil.rmtree(output_path, ignore_errors=True)

    configuration = schema.validate(patch_data)

    original_locale: configparser.ConfigParser | None = None
    if factorio_path is not None:
        original_locale = configparser.ConfigParser()
        ensure_locale_read(
            original_locale,
            [
                factorio_path.joinpath("data/base/locale/en/base.cfg"),
                _TEMPLATE_PATH.joinpath("locale/en/strings.cfg"),
            ],
        )

    locale = configparser.ConfigParser()
    ensure_locale_read(
        locale,
        [
            _TEMPLATE_PATH.joinpath("locale/en/strings.cfg"),
        ],
    )

    progressive_sources: dict[tuple[str, ...], list[str]] = collections.defaultdict(list)
    generated_files: GeneratedFiles = {
        "tech_tree": [],
        "local_unlocks": {},
        "existing_tree_repurpose": {},
        "starting_tech": configuration["starting_tech"],
        "custom_recipes": configuration["recipes"],
    }

    for tech in configuration["technologies"]:
        generated_files["tech_tree"].append(
            process_technology(
                locale,
                generated_files["local_unlocks"],
                progressive_sources,
                tech,
                original_locale,
            )
        )

    # TODO: add the offworld research to `existing_tree_repurpose`

    for progressive_sequence, sources in progressive_sources.items():
        for i, tech_name in enumerate(progressive_sequence):
            if i == 0:
                prerequisites = sources
            else:
                prerequisites = [progressive_sequence[i - 1]]

            generated_files["existing_tree_repurpose"][tech_name] = {
                "science_pack": "impossible-science-pack",
                "prerequisites": prerequisites,
            }

    generate_output(output_path, generated_files, locale, factorio_path)
