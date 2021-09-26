
	.thumb

	UNIT_FATIGUE_OFFSET = 0x3B

	.global CanUnitBeFatigued
	.type   CanUnitBeFatigued, function

CanUnitBeFatigued:
	@ arg r0 = unit
	@ returns 0 if given unit is exempt from being fatigued

	@ check for null ptr
	cmp   r0, #0
	beq   CanUnitBeFatigued.return_false

	@ check faction
	ldrb  r1, [r0, #0x0B] @ Unit->id
	lsr   r1, #6
	bne   CanUnitBeFatigued.return_false

	@ var r1 = pid
	ldr   r1, [r0, #0x00] @ Unit->pinfo
	ldrb  r1, [r1, #0x04] @ PInfo->id

	@ var r3 = list addr
	ldr   r3, =FatigueExemptCharList

CanUnitBeFatigued.lop:
	@ var r2 = *list++
	ldrb  r2, [r3]
	add   r3, #1

	@ check for terminating byte
	cmp   r2, #0
	beq   CanUnitBeFatigued.return_true

	@ compare pid
	cmp   r2, r1
	bne   CanUnitBeFatigued.lop

CanUnitBeFatigued.return_false:
	mov   r0, #0
	bx    lr

CanUnitBeFatigued.return_true:
	mov   r0, #1
	bx    lr

	.pool

	.global AddUnitFatigue
	.type   AddUnitFatigue, function

AddUnitFatigue:
	@ arg r0 = unit, arg r1 = amount
	@ increment unit's fatigue counter by amount

	push  {r0, r1, lr}

	@ implied @ arg r0 = unit

	bl    CanUnitBeFatigued

	@ r2 = unit, r3 = amount
	pop   {r2, r3}

	cmp   r0, #0
	beq   AddUnitFatigue.end

	mov   r1, #UNIT_FATIGUE_OFFSET

	ldrb  r0, [r2, r1] @ Unit->fatigue
	add   r0, r3

	@ check for max fatigue (99)
	cmp   r0, #99
	blt   AddUnitFatigue.write_back

	mov   r0, #99

AddUnitFatigue.write_back:
	strb  r0, [r2, r1] @ Unit->fatigue

AddUnitFatigue.end:
	pop   {r3}
bx_r3:	bx    r3

	.pool

	.global GetUnitFatigue
	.type   GetUnitFatigue, function

GetUnitFatigue:
	mov   r1, #UNIT_FATIGUE_OFFSET
	ldsb  r0, [r0, r1]

	bx    lr

	.global GetUnitDisplayFatigue
	.type   GetUnitDisplayFatigue, function

GetUnitDisplayFatigue:
	push  {r0, lr}

	@ implied @ arg r0 = unit

	bl    CanUnitBeFatigued

	pop   {r1}

	cmp   r0, #0
	beq   GetUnitDisplayFatigue.return_ff

	mov   r0, #UNIT_FATIGUE_OFFSET
	ldsb  r0, [r1, r0]

	b     GetUnitDisplayFatigue.end

GetUnitDisplayFatigue.return_ff:
	mov   r0, #0xFF

GetUnitDisplayFatigue.end:
	pop   {r1}
	bx    r1

	.global IsUnitFatigued
	.type   IsUnitFatigued, function

IsUnitFatigued:
	mov   r2, #UNIT_FATIGUE_OFFSET
	ldsb  r1, [r0, r2]

	@ r2 = Unit->max_hp
	ldrb  r2, [r0, #0x12] @ Unit->max_hp

	cmp   r1, r2
	bgt   IsUnitFatigued.return_true

IsUnitFatigued.return_false:
	mov   r0, #0
	bx    lr

IsUnitFatigued.return_true:
	mov   r0, #1
	bx    lr

	.pool

	.global IncreaseFatigueAfterAction
	.type   IncreaseFatigueAfterAction, function

IncreaseFatigueAfterAction:
	push  {lr}

	ldr   r3, =gActionData
	ldrb  r0, [r3, #0x11] @ Action->id

	cmp   r0, #2 @ ACTION_COMBAT
	beq   IncreaseFatigueAfterAction.combat

	cmp   r0, #3 @ ACTION_STAFF
	beq   IncreaseFatigueAfterAction.staff

	cmp   r0, #4 @ ACTION_REFRESH
	beq   IncreaseFatigueAfterAction.regular

	cmp   r0, #6 @ ACTION_STEAL
	beq   IncreaseFatigueAfterAction.regular

	cmp   r0, #7 @ ACTION_SUMMON
	beq   IncreaseFatigueAfterAction.regular

IncreaseFatigueAfterAction.end:
	pop   {r0}
	bx    r0

IncreaseFatigueAfterAction.combat:
	ldr   r0, =gBattleTarget
	ldrb  r0, [r0, #0x0B]

	@ bl GetUnit
	ldr   r3, =GetUnit
	bl    bx_r3

	@ implied    @ arg r0 = unit
	mov   r1, #1 @ arg r1 = amount

	bl    AddUnitFatigue

	@ fallthrough

IncreaseFatigueAfterAction.regular:
	ldr   r0, =gBattleActor
	ldrb  r0, [r0, #0x0B]

	@ bl GetUnit
	ldr   r3, =GetUnit
	bl    bx_r3

	@ implied    @ arg r0 = unit
	mov   r1, #1 @ arg r1 = amount

	bl    AddUnitFatigue

	b     IncreaseFatigueAfterAction.end

IncreaseFatigueAfterAction.staff:
	ldr   r0, =gBattleActor
	ldrb  r0, [r0, #0x0B]

	@ bl GetUnit
	ldr   r3, =GetUnit
	bl    bx_r3

	push  {r0}

	@ r1 = action item slot
	ldr   r3, =gActionData
	ldrb  r1, [r3, #0x12] @ Action->item_slot

	@ r0 = Unit->item[Action->item_slot]
	lsl   r1, #1
	add   r1, #0x1E
	ldrh  r0, [r0, r1]

	@ implied @ arg r0 = item

	@ bl GetItemRequiredExp
	ldr   r3, =GetItemRequiredExp
	bl    bx_r3

	@ implied @ arg r0 = exp

	@ bl GetWeaponLevelFromExp
	ldr   r3, =GetWeaponLevelFromExp
	bl    bx_r3

	mov   r1, r0 @ arg r1 = amount
	pop   {r0}   @ arg r0 = unit

	bl    AddUnitFatigue

	b     IncreaseFatigueAfterAction.end

	.pool

	.global FatiguePrepScreenHook
	.type   FatiguePrepScreenHook, function

FatiguePrepScreenHook:
	@ jump to hack at                       0x080957F8+1
	FatiguePrepScreenHook.return_location = 0x08095800+1

	@ state:
	@ - r4 = unit

	ldr   r0, [r4, #0x0C]

	mov   r1, #1
	lsl   r1, #21 @ r1 = UNIT_FLAG_WAS_UNDEPLOYED

	tst   r0, r1
	bne   FatiguePrepScreenHook.reset_fatigue

	mov   r0, #UNIT_FATIGUE_OFFSET
	ldrb  r0, [r4, r0] @ Unit->fatigue

	ldrb  r1, [r4, #0x12] @ Unit->max_hp

	cmp   r0, r1
	ble   FatiguePrepScreenHook.return_false

FatiguePrepScreenHook.return_true:
	mov   r0, #1

	ldr   r3, =FatiguePrepScreenHook.return_location
	bx    r3

FatiguePrepScreenHook.reset_fatigue:
	@ note that LOBYTE(r1) == 0
	mov   r2, #UNIT_FATIGUE_OFFSET
	strb  r1, [r4, r2]

FatiguePrepScreenHook.return_false:
	mov   r0, #0

	ldr   r3, =FatiguePrepScreenHook.return_location
	bx    r3

	.pool
