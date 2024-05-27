import numpy as np
import pytest
from factorio_randovania_mod import color_util


@pytest.mark.parametrize(
    ("rgb", "expected"),
    [
        ((255, 0, 0), (0, 1, 255)),
        ((0, 255, 0), (1 / 3, 1, 255)),
        ((0, 0, 255), (2 / 3, 1, 255)),
        ((255, 255, 255), (0, 0, 255)),
        ((0, 0, 0), (0, 0, 0)),
    ],
)
def test_rgb_to_hsv(rgb, expected):
    arr = np.array(rgb)
    result = color_util.rgb_to_hsv(arr)
    assert (result == np.array(expected)).all()
