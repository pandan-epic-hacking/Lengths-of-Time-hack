
import sys
from datetime import date
from typing import Dict, List

def get_int(rom: bytes, offset: int, length: int) -> int:
    return int.from_bytes(rom[offset:offset+length], 'little')

FACE_TABLE_OFFSETS = [
    0x0005524]

TEXT_TABLE_PTR_OFFSETS = [
#   0x000A26C, # this one is overwritten by anti-huffman so best not check that one
    0x000A2A0]

ITEM_TABLE_PTR_OFFSETS = [
    0x0016410,
    0x0016440,
    0x0016470,
    0x00164A0,
    0x00164D0,
    0x0016500,
    0x0016530,
    0x0016570,
    0x00166D0,
    0x001671C,
    0x001678C,
    0x00167E0,
    0x001683C,
    0x00168C4,
    0x001698C,
    0x0016A10,
    0x0016AD0,
    0x0016B18,
    0x0016BB4,
    0x0016C14,
    0x0016C7C,
    0x0016D04,
    0x0016DD4,
    0x0016F0C,
    0x0016FA4,
    0x0017028,
    0x001707C,
    0x00170C8,
    0x00170F8,
    0x001727C,
    0x00172D8,
    0x001735C] # ...

ITEM_ANIM_TABLE_OFFSETS = [
    0x0078240,
    0x0058014]

ICON_TABLE_OFFSETS = [
    0x00036B4,
    0x0003788]

SYSTEM_OBJECTS_IMG_OFFSETS = [
    0x00156AC]

SOUND_ROOM_TABLE_OFFSETS = [
    0x001BC14,
    0x001BCC4,
    0x00AECA8,
    0x00AECD0,
    0x00AED2C,
    0x00AEEBC,
    0x00AF438,
    0x00AF830,
    0x00AFE30,
    0x00B0080,
    0x00B042C]

NEW_UNIT_EXP_BIN = b'\x00\xB5\xFF\x23\xE0\x7A\xC0\x21\x08\x42\x07\xD1\x60\x68\x00\x79\x04\x49\x09\x5C\x20\x7A\x88\x42\x00\xDA\x00\x23\x18\x1C\x02\xBC\x08\x47\xC0\x46'
TITLE_BACKGROUND_BIN = b'\x00\x00\x00\x06\x00\x02\x00\x00\xB8\x0D\x00\x08\x4C\x1C\x00\x08\x3D\x58\x0C\x08'
MAG_SPLIT_BIN = b'\x00\xB5\x13\x48\x86\x46\x38\x68\x00\x79\x40\x00\x12\x49\x40\x18\x40\x78\x50\x44\x00\xF8\x01\xB4\x0E\x48\x86\x46\xF8\x7A\x00\xF8\x41\x68\x3A\x30\x00\x78\x09\x79\x89\x00\x0C\x4A\x52\x18\x92\x78\x02\xBC\x76\x18\x43\x18\x93\x42\x00\xDD\x11\x1A\x38\x1C\x7A\x30\x01\x70\x01\xBC\x00\x99\x03\x91\x01\x9B\x02\x93\xC2\x46\x00\x47\xA0\xB9\x02\x08\x30\x94\x01\x08'

def get_ptr(rom: bytes, offsets: List[int]) -> int:
    ptrs = {}

    for offset in offsets:
        ptr = get_int(rom, offset, 4)

        if ptr in ptrs:
            ptrs[ptr] = ptrs[ptr] + 1

        else:
            ptrs[ptr] = 1

    mx = 0

    for ptr in ptrs:
        if mx < ptrs[ptr]:
            mx = ptrs[ptr]
            result = ptr

    return result

def get_skill_offsets(rom: bytes) -> Dict[str, int]:
    # we do it like feb do it

    pointer_infos = [
        ( "assign",  16,   b"\x01\x35\x02\x36\xF1\xE7\x00\x20\x28\x70\x29\x1C\x02\x48\x09\x1A" ),
        ( "levelup", 16+8, b"\x01\x35\x02\x36\xF1\xE7\x00\x20\x28\x70\x29\x1C\x02\x48\x09\x1A" ),
        ( "assign",  16,   b"\x29\x1C\xFF\xF7\xFA\xFF\x01\x1C\x08\x78\x00\x28\xEF\xD0\x01\x31\xFA\xE7\x00\x00" ),
        ( "levelup", 0,    b"\x0A\xD0\x1A\x78\x00\x2A\x07\xD0\x8A\x42\x01\xD0\x02\x33\xF8\xE7\x5A\x78\x22\x70\x01\x34\xF9\xE7\x00\x20\x20\x70\x31\xBC\x70\x47" ),
        ( "anime",   32,   b"\x00\x2B\x00\xD1\x06\x4B\x38\x1C\x9E\x46\x00\xF8\x05\x48\x00\x47" ),
        ( "icon",    24,   b"\x02\x40\x09\x4C\x05\x48\x00\x47\x05\x48\x00\x47\x05\x48\x00\x47" ),
        ( "icon",    8,    b"\x08\x42\x04\xD1\x12\x79\xAA\x42\x01\xD1\x01\x20\x03\xE0\x01\x34\xBF\x2C\xEA\xDD\x00\x20\x30\xBC\x02\xBC\x08\x47" ),
        ( "icon",    0,    b"\xFF\xFF\x0F\x00\x05\x49\x00\x29\x01\xD1\x03\x49\x09\x68\x00\x06\x40\x0C\x40\x18\x70\x47\x00\x00\x88\x37\x00\x08" ),
        ( "text",    16,   b"\x07\x49\x40\x00\x40\x18\x00\x88\x00\x28\x00\xD1\x06\x48\x21\x1C" ),
        ( "levelup", 0,    b"\xE4\x58\x00\x2C\x0C\xD0\x23\x78\x00\x2B\x09\xD0\x8B\x42\x01\xDD\x93\x42\x01\xDD\x02\x34\xF6\xE7\x63\x78\x33\x70\x01\x36\xF9\xE7\x00\x20\x30\x70\x71\xBC\x70\x47" ),
        ( "levelup", 0,    b"\x06\xDD\x14\x3B\x8B\x42\x01\xDD\x93\x42\x01\xDD\x02\x34\xEF\xE7\x63\x78\x33\x70\x01\x36\xF9\xE7\x0B\x4C\x43\x68\x1B\x79\x9B\x00\xE4\x58\x00\x2C\x0C\xD0\x23\x78\x00\x2B\x09\xD0\x8B\x42\x01\xDD\x93\x42\x01\xDD\x02\x34\xF6\xE7\x63\x78\x33\x70\x01\x36\xF9\xE7\x00\x20\x30\x70\x71\xBC\x70\x47" ),
        ( "levelup", 0,    b"\xF0\xE7\x02\x2B\x12\xD0\x03\x2B\x06\xD1\x0D\x48\x42\x21\x41\x5C\x20\x22\x11\x42\x0A\xD1\xE5\xE7\x04\x2B\x06\xD1\x08\x48\x14\x21\x41\x5C\x40\x22\x11\x42\x01\xD1\xDC\xE7\xDB\xE7\x63\x78\x33\x70\x01\x36\xD7\xE7\x00\x20\x30\x70\x06\xBC\xF1\xBC\x70\x47\x00\x00\xF0\xBC\x02\x02" )]

    result = {}

    for pointer_info in pointer_infos:
        found = rom.find(pointer_info[2])

        if found == -1:
            continue

        result[pointer_info[0]] = found + len(pointer_info[2]) + pointer_info[1]

    return result

def main(args: List[str]) -> None:
    try:
        rom_filename = args[0]

    except IndexError:
        sys.exit(f"Usage: [python 3] {sys.argv[0]} ROM")

    with open(rom_filename, 'rb') as f:
        rom = f.read()

    text_table_offset = get_ptr(rom, TEXT_TABLE_PTR_OFFSETS) & 0x1FFFFFF
    item_table_offset = get_ptr(rom, ITEM_TABLE_PTR_OFFSETS) & 0x1FFFFFF
    level_cap_table_offset = get_int(rom, rom.find(NEW_UNIT_EXP_BIN) + len(NEW_UNIT_EXP_BIN), 4) & 0x1FFFFFF
    item_anim_table_offset = get_ptr(rom, ITEM_ANIM_TABLE_OFFSETS) & 0x1FFFFFF
    face_table_offset = get_ptr(rom, FACE_TABLE_OFFSETS) & 0x1FFFFFF
    icon_table_offset = get_ptr(rom, ICON_TABLE_OFFSETS) & 0x1FFFFFF
    system_objects_img_offset = get_ptr(rom, SYSTEM_OBJECTS_IMG_OFFSETS) & 0x1FFFFFF
    sound_room_table_offset = get_ptr(rom, SOUND_ROOM_TABLE_OFFSETS) & 0x1FFFFFF

    skill_offsets = get_skill_offsets(rom)

    char_skill_table_offset = get_int(rom, skill_offsets['assign'], 4) & 0x1FFFFFF
    class_skill_table_offset = get_int(rom, skill_offsets['assign'] + 4, 4) & 0x1FFFFFF
    class_levelup_skill_table_offset = get_int(rom, skill_offsets['levelup'], 4) & 0x1FFFFFF
    char_levelup_skill_table_offset = get_int(rom, skill_offsets['levelup'] + 4, 4) & 0x1FFFFFF

    title_background_pool_offset = rom.find(TITLE_BACKGROUND_BIN) + len(TITLE_BACKGROUND_BIN)

    title_background_img_offset = get_int(rom, title_background_pool_offset+0, 4) & 0x1FFFFFF
    title_background_pal_offset = get_int(rom, title_background_pool_offset+4, 4) & 0x1FFFFFF
    title_background_tsa_offset = get_int(rom, title_background_pool_offset+8, 4) & 0x1FFFFFF

    mag_split_pool_offset = rom.find(MAG_SPLIT_BIN) + len(MAG_SPLIT_BIN)

    mag_split_char_table_offset = get_int(rom, mag_split_pool_offset+0, 4) & 0x1FFFFFF
    mag_split_class_table_offset = get_int(rom, mag_split_pool_offset+4, 4) & 0x1FFFFFF

    print(f"// generated by {sys.argv[0]} on {date.today()}")
    print("")

    print("#ifndef SetSymbolDefined")
    print("  #define SetSymbolDefined")
    print("  #define SetSymbol(name, val) \"PUSH; ORG (val); name :; POP\"")
    print("#endif")

    print("")

    def set_symbol_str(name: str, value: int) -> str:
        return f"SetSymbol({name}, ${value:07X})"

    print(set_symbol_str("BaseTextTable", text_table_offset))
    print(set_symbol_str("BaseItemTable", item_table_offset))
    print(set_symbol_str("BaseLevelCapTable", level_cap_table_offset))
    print(set_symbol_str("BaseItemAnimTable", item_anim_table_offset))
    print(set_symbol_str("BaseCharacterSkillTable", char_skill_table_offset))
    print(set_symbol_str("BaseClassSkillTable", class_skill_table_offset))
    print(set_symbol_str("BaseCharacterLevelUpSkillTable", char_levelup_skill_table_offset))
    print(set_symbol_str("BaseClassLevelUpSkillTable", class_levelup_skill_table_offset))
    print(set_symbol_str("BaseFaceTable", face_table_offset))
    print(set_symbol_str("BaseIconTable", icon_table_offset))
    print(set_symbol_str("BaseSystemObjectsImg", system_objects_img_offset))
    print(set_symbol_str("BaseSoundRoomTable", sound_room_table_offset))
    print(set_symbol_str("BaseTitleScreenBackgroundImg", title_background_img_offset))
    print(set_symbol_str("BaseTitleScreenBackgroundPal", title_background_pal_offset))
    print(set_symbol_str("BaseTitleScreenBackgroundTm", title_background_tsa_offset))
    print(set_symbol_str("BaseMagSplitCharacterTable", mag_split_char_table_offset))
    print(set_symbol_str("BaseMagSplitClassTable", mag_split_class_table_offset))

if __name__ == '__main__':
    main(sys.argv[1:])
