
import sys

def iter_all_words(f):
    while True:
        word = f.read(4)

        if word == b'':
            break

        yield int.from_bytes(word, 'little')

def iter_word_offsets(f, value):
    return (i*4 for i, x in enumerate(iter_all_words(f)) if x == value)

def main(args):
    try:
        filename = args[0]
        value = int(args[1], base = 0)

    except IndexError:
        sys.exit(f"Usage: [python 3] {sys.argv[0]} ROM VALUE")

    with open(filename, 'rb') as f:
        for offset in iter_word_offsets(f, value):
            print(f"{offset:07X}")

if __name__ == '__main__':
    main(sys.argv[1:])
