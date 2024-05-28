import argparse

from PIL import Image


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_path")
    parser.add_argument("output_path")
    args = parser.parse_args()

    img = Image.open(args.input_path)
    height = img.size[1]
    crop = img.crop((0, 0, height, height))

    left = height
    for mipmap in range(3):
        d = 2 ** (mipmap + 1)
        smaller = crop.resize((height // d, height // d))

        img.paste(smaller, (left, 0))
        left += smaller.size[0]

    img.save(args.output_path)


if __name__ == "__main__":
    main()
