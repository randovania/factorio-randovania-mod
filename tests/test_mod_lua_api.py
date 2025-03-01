import json

from factorio_randovania_mod import mod_lua_api


def test_enable_mods_in_list_no_file(tmp_path):
    assert not mod_lua_api.enable_mods_in_list(tmp_path, {"my-mod": None})


def test_enable_mods_in_list_not_listed(tmp_path):
    tmp_path.joinpath("mod-list.json").write_text(
        json.dumps(
            {
                "mods": [],
            }
        )
    )

    assert mod_lua_api.enable_mods_in_list(tmp_path, {"my-mod": None})

    assert json.loads(tmp_path.joinpath("mod-list.json").read_text()) == {"mods": [{"name": "my-mod", "enabled": True}]}


def test_enable_mods_in_list_disabled(tmp_path):
    tmp_path.joinpath("mod-list.json").write_text(
        json.dumps(
            {
                "mods": [{"name": "my-mod", "enabled": False}],
            }
        )
    )

    assert mod_lua_api.enable_mods_in_list(tmp_path, {"my-mod": None})

    assert json.loads(tmp_path.joinpath("mod-list.json").read_text()) == {"mods": [{"name": "my-mod", "enabled": True}]}


def test_enable_mods_in_list_wrong_version(tmp_path):
    tmp_path.joinpath("mod-list.json").write_text(
        json.dumps(
            {
                "mods": [{"name": "my-mod", "enabled": True, "version": "1.0"}],
            }
        )
    )

    assert mod_lua_api.enable_mods_in_list(tmp_path, {"my-mod": "1.1"})

    assert json.loads(tmp_path.joinpath("mod-list.json").read_text()) == {
        "mods": [{"name": "my-mod", "enabled": True, "version": "1.1"}]
    }
