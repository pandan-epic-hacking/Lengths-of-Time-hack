
CACHE_DIR := .cache_dir
$(shell mkdir -p $(CACHE_DIR) > /dev/null)

# ====================
# = TOOL DEFINITIONS =
# ====================

# arm-none-eabi toolchain definitions

TOOLCHAIN ?= $(DEVKITARM)
export PATH := $(TOOLCHAIN)/bin:$(PATH)

PREFIX := arm-none-eabi-

CPP     := $(PREFIX)cpp
AS      := $(PREFIX)as
CC      := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy

# making sure we are using python 3

ifeq ($(shell python -c 'import sys; print(int(sys.version_info[0] > 2))'),1)
  PYTHON3 := python
else
  PYTHON3 := python3
endif

# EA and tools definitions

EA_DIR ?= Tools/EventAssembler

EA                := $(EA_DIR)/ColorzCore
EA_DEP            := $(EA_DIR)/ea-dep
LYN               := $(EA_DIR)/Tools/lyn
COMPRESS          := $(EA_DIR)/Tools/compress
PNG2DMP           := $(EA_DIR)/Tools/Png2Dmp
PARSEFILE         := $(EA_DIR)/Tools/ParseFile
PORTRAITFORMATTER := $(EA_DIR)/Tools/PortraitFormatter

# script tool definitions

BASE_INFO    := $(PYTHON3) Tools/Scripts/base_info.py
C2EA         := $(PYTHON3) Tools/PyTools/NMM2CSV/c2ea.py
TEXT_PROCESS := $(PYTHON3) Tools/PyTools/text-process-classic.py

# other

CLIB_DIR := Tools/CLib

# ===============
# = MAIN TARGET =
# ===============

FE8U_GBA := fe8u.gba
BASE_GBA := base.gba
HACK_GBA := hack.gba

MAIN_EVENT := Main.event

hack: $(HACK_GBA)
base: $(BASE_GBA)

.PHONY: hack base

MAIN_DEPENDS := $(shell $(EA_DEP) $(MAIN_EVENT) -I $(EA_DIR) --add-missings)

$(HACK_GBA): $(BASE_GBA) $(MAIN_EVENT) $(MAIN_DEPENDS)
	cp -f $(BASE_GBA) $(HACK_GBA)
	$(EA) A FE8 -input:$(MAIN_EVENT) -output:$(HACK_GBA) --nocash-sym || rm -f $(HACK_GBA)

# ==================
# = OBJECTS & DMPS =
# ==================

LYN_REFERENCE := $(CLIB_DIR)/reference/FE8U-20190316.o

# OBJ to event
%.lyn.event: %.o $(LYN_REFERENCE)
	$(LYN) $< $(LYN_REFERENCE) > $@

# OBJ to DMP rule
%.dmp: %.o
	$(OBJCOPY) -S $< -O binary $@

# ========================
# = ASSEMBLY/COMPILATION =
# ========================

# Setting C/ASM include directories up
INCLUDE_DIRS := Wizardry/Include $(CLIB_DIR)/include
INCFLAGS     := $(foreach dir, $(INCLUDE_DIRS), -I "$(dir)")

# setting up compilation flags
ARCH    := -mcpu=arm7tdmi -mthumb -mthumb-interwork
CFLAGS  := $(ARCH) $(INCFLAGS) -Wall -O2 -mtune=arm7tdmi -ffreestanding -mlong-calls
ASFLAGS := $(ARCH) $(INCFLAGS)

# defining dependency flags
CDEPFLAGS = -MMD -MT "$*.o" -MT "$*.asm" -MF "$(CACHE_DIR)/$(subst /,_,$*).d" -MP
SDEPFLAGS = --MD "$(CACHE_DIR)/$(subst /,_,$*).d"

# ASM to OBJ rule
%.o: %.s
	$(AS) $(ASFLAGS) $(SDEPFLAGS) -I $(dir $<) $< -o $@

# C to ASM rule
# I would be fine with generating an intermediate .s file but this breaks dependencies
%.o: %.c
	$(CC) $(CFLAGS) $(CDEPFLAGS) -g -c $< -o $@

# C to ASM rule
%.asm: %.c
	$(CC) $(CFLAGS) $(CDEPFLAGS) -S $< -o $@ -fverbose-asm

# Avoid make deleting objects it thinks it doesn't need anymore
# Without this make may fail to detect some files as being up to date
.PRECIOUS: %.o;

-include $(wildcard $(CACHE_DIR)/*.d)

# ==============
# = HOOK LISTS =
# ==============

WIZARDRY_EVENT := Wizardry/Wizardry.event

HOOKLISTS := Wizardry/HookLists.event
HOOKLISTS_SCRIPT := Wizardry/HookLists.lua

HOOKLISTS_INPUTS := $(shell $(EA_DEP) $(WIZARDRY_EVENT) -I $(EA_DIR))
HOOKLISTS_INPUTS := $(filter-out $(HOOKLISTS), $(filter %.event, $(HOOKLISTS_INPUTS)))

$(HOOKLISTS): $(HOOKLISTS_SCRIPT) $(HOOKLISTS_INPUTS)
	lua $(HOOKLISTS_SCRIPT) $(HOOKLISTS_INPUTS) > $(HOOKLISTS) || rm -f $(HOOKLISTS)

# ==========================
# = GRAPHICS & COMPRESSION =
# ==========================

# PNG to 4bpp rule
%.4bpp: %.png
	$(PNG2DMP) $< -o $@

# PNG to gbapal rule
%.gbapal: %.png
	$(PNG2DMP) $< -po $@ --palette-only

# Anything to lz rule
%.lz: %
	$(COMPRESS) $< $@

# ========
# = TEXT =
# ========

# Variable listing all text files in the writans directory
# The text installer depends on them (in case there was any change)
# (Too lazy to code a dependency thingy for that too)
WRITANS_ALL_TEXT    := $(wildcard Writans/*.txt)

# Main input text file
WRITANS_TEXT_MAIN   := Writans/TextMain.txt

# textprocess outputs
WRITANS_INSTALLER   := Writans/Text.event
WRITANS_DEFINITIONS := Writans/TextDefinitions.event

# Make text installer and definitions from text
$(WRITANS_INSTALLER) $(WRITANS_DEFINITIONS): $(WRITANS_TEXT_MAIN) $(WRITANS_ALL_TEXT)
	$(TEXT_PROCESS) $(WRITANS_TEXT_MAIN) --installer $(WRITANS_INSTALLER) --definitions $(WRITANS_DEFINITIONS) --parser-exe $(PARSEFILE)

# ==========
# = TABLES =
# ==========

# Convert CSV+NMM to event
%.event: %.csv %.nmm
	echo | $(C2EA) -csv $*.csv -nmm $*.nmm -out $*.event $(BASE_GBA) > /dev/null

# =================
# = BASE ROM DATA =
# =================

BASE_INFO_EVENT := BaseInfo.event
FE8U_CODE_BIN   := Fe8uCode.dmp

$(BASE_INFO_EVENT): $(BASE_GBA) Tools/Scripts/base_info.py
	$(BASE_INFO) $< > $@

$(FE8U_CODE_BIN): $(FE8U_GBA)
	head -c "$$((0xD74C8))" $< > $@
