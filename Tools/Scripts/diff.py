
import sys

def diff_words(fa, fb, offset, length):
    fa.seek(offset)
    fb.seek(offset)

    for word_number in range(length // 4):
        word_a = fa.read(4)
        word_b = fb.read(4)

        if word_a != word_b:
            yield (offset + word_number*4, word_a, word_b)

def main(args):
    try:
        filename_a = args[0]
        filename_b = args[1]
        offset = int(args[2], base = 0) & 0x01FFFFFF
        length = int(args[3], base = 0) & 0x01FFFFFF

    except IndexError:
        sys.exit(f"Usage: [python 3] {sys.argv[0]} FILE_A FILE_B OFFSET LENGTH")

    with open(filename_a, 'rb') as fa:
        with open(filename_b, 'rb') as fb:
            for offset, word_a, word_b in diff_words(fa, fb, offset, length):
                word_a_int = int.from_bytes(word_a, 'little')
                word_b_int = int.from_bytes(word_b, 'little')

                print(f"{offset + 0x08000000:08X} {word_a_int:08X} {word_b_int:08X}")

if __name__ == '__main__':
    main(sys.argv[1:])
