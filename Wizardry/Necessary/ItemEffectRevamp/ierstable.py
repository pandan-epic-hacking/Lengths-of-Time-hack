
import sys

def main(args):
    try:
        csv_filename = args[1]

    except IndexError:
        sys.exit(f"Usage: [python 3] {args[0]} CSV")

    with open(csv_filename, 'r') as f:
        import csv

        reader = csv.reader(f.readlines())

        head = next(reader)

        for i, row in enumerate(reader):
            if i > 0x37:
                break

            ent = row[2]

            try:
                integr = int(ent, base = 0)
                string = f"0x{integr:08X}"
            except ValueError:
                string = ent

            print(f"/* {i:02X} */ WORD {string} // {row[0]}")

if __name__ == '__main__':
    main(sys.argv)
