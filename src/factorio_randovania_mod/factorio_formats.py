import enum
import typing

import construct


class DictAdapter(construct.Adapter):
    def _decode(self, obj: construct.ListContainer, context: construct.Container, path: str) -> construct.Container:
        result: construct.Container = construct.Container()
        last = {}
        for i, item in enumerate(obj):
            key = item.key
            if key in result:
                raise construct.ConstructError(f"Key {key} found twice in object", path)
            last[key] = i
            result[key] = item.value
        return result

    def _encode(self, obj: construct.Container, context: construct.Container, path: str) -> construct.ListContainer:
        return construct.ListContainer(construct.Container(key=type_, value=item) for type_, item in obj.items())


class ErrorWithMessage(construct.Construct):
    def __init__(self, message, error=construct.ExplicitError):
        super().__init__()
        self.message = message
        self.flagbuildnone = True
        self.error = error

    def _parse(self, stream, context, path):
        message = construct.evaluate(self.message, context)
        raise self.error(f"Error field was activated during parsing with error {message}", path=path)

    def _build(self, obj, stream, context, path):
        message = construct.evaluate(self.message, context)
        raise self.error(f"Error field was activated during building with error {message}", path=path)

    def _sizeof(self, context, path):
        raise construct.SizeofError("Error does not have size, because it interrupts parsing and building", path=path)


class PropertyTreeTypeEnum(enum.IntEnum):
    NONE = 0
    BOOL = 1
    NUMBER = 2
    STRING = 3
    LIST = 4
    DICTIONARY = 5
    SIGNED_INTEGER = 6
    UNSIGNED_INTEGER = 7


PropertyTreeType = construct.Enum(construct.Int8ul, PropertyTreeTypeEnum)


def _python_value_to_tree_type(value: typing.Any) -> str:
    if value is None:
        return PropertyTreeTypeEnum.NONE.name
    if isinstance(value, bool):
        return PropertyTreeTypeEnum.BOOL.name
    if isinstance(value, str):
        return PropertyTreeTypeEnum.STRING.name
    if isinstance(value, float):
        return PropertyTreeTypeEnum.NUMBER.name
    if isinstance(value, list):
        return PropertyTreeTypeEnum.LIST.name
    if isinstance(value, dict):
        return PropertyTreeTypeEnum.DICTIONARY.name
    if isinstance(value, int):
        if value > 2**63:
            return PropertyTreeTypeEnum.UNSIGNED_INTEGER.name
        else:
            return PropertyTreeTypeEnum.SIGNED_INTEGER.name
    raise construct.ConstructError(f"Unsupported type: {value}")


SpaceOptimizedUInt = construct.Select(
    construct.FocusedSeq(
        "val",
        "val" / construct.Int8ul,
        "check" / construct.Check(construct.this.val < 255),
    ),
    construct.FocusedSeq(
        "val",
        "magic" / construct.Const(255, construct.Int8ul),
        "val" / construct.Int32ul,
    ),
)

PropertyString = construct.FocusedSeq(
    "value",
    empty=construct.Rebuild(construct.Flag, lambda ctx: ctx == ""),
    value=construct.If(construct.this.empty == False, construct.PascalString(SpaceOptimizedUInt, "utf-8")),
)

_property_type_value = {
    PropertyTreeTypeEnum.NONE.name: construct.Pass,
    PropertyTreeTypeEnum.BOOL.name: construct.Flag,
    PropertyTreeTypeEnum.NUMBER.name: construct.Double,
    PropertyTreeTypeEnum.STRING.name: PropertyString,
    PropertyTreeTypeEnum.SIGNED_INTEGER.name: construct.Int64sl,
    PropertyTreeTypeEnum.UNSIGNED_INTEGER.name: construct.Int64ul,
}

PropertyTree = construct.FocusedSeq(
    "value",
    "type"
    / construct.Rebuild(
        PropertyTreeType,
        lambda ctx: _python_value_to_tree_type(ctx.value),
    ),
    construct.Const(False, construct.Flag),
    "value"
    / construct.Switch(
        construct.this.type,
        _property_type_value,
        ErrorWithMessage(lambda ctx: f"Unknown type: {ctx.type}"),
    ),
)

_property_type_value[PropertyTreeTypeEnum.LIST.name] = construct.PrefixedArray(
    construct.Int32ul,
    construct.FocusedSeq(
        "value",
        construct.Const("", PropertyString),
        "value" / PropertyTree,
    ),
)
_property_type_value[PropertyTreeTypeEnum.DICTIONARY.name] = DictAdapter(
    construct.PrefixedArray(
        construct.Int32ul,
        construct.Struct(
            key=PropertyString,
            value=PropertyTree,
        ),
    )
)

ModSettings = construct.Struct(
    "game_version"
    / construct.Struct(
        main=construct.Int16ul,
        major=construct.Int16ul,
        minor=construct.Int16ul,
        developer=construct.Int16ul,
    ),
    construct.Const(False, construct.Flag),
    "tree" / PropertyTree,
)
