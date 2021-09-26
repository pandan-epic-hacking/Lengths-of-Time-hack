
import sys

def main(args):
    try:
        name = args[0]

    except IndexError:
        sys.exit(f"Usage: [python 3] {sys.argv[0]} NAME")

    for line in map(str.rstrip, sys.stdin):
        offset = int(line, base = 16)

        print(f"ORG ${offset:07X}")
        print(f"    POIN {name}")

if __name__ == '__main__':
    main(sys.argv[1:])
