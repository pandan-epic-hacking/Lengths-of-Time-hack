
	.thumb

	@ 0x36 is juna fruit, the last item effect id assigned in vanilla
	@ we also assign 0x37 to latona, as it otherwise has no item effect id assigned
	@ so the last item effect id that has a vanilla handler is 0x37

	LAST_ITEM_EFFECT_ID = 0x37

	GetUnit = 0x08019430+1
	GetItemUseEffect = 0x0801773C+1

	.global IersCanUnitUseItemHook
	.type IersCanUnitUseItemHook, function
IersCanUnitUseItemHook:
	@ hook at fe8u:08028894

	@ state:
	@  r4 = unit
	@  r5 = item

	@ get item use effect id

	mov  r0, r5 @ arg r0 = item

	ldr  r3, =GetItemUseEffect
	bl   bx_r3

	@ get IERS item effect table entry

	ldr  r3, =IersEffectTable
	lsl  r1, r0, #2
	ldr  r3, [r3, r1]

	@ if entry is null ptr, do vanilla behavior

	cmp  r3, #0
	beq  IersCanUnitUseItemHook.vanilla_effect

	@ get usability func

	ldr  r3, [r3, #0x00]

	@ if usability func is null ptr, return false

	cmp  r3, #0
	beq  IersCanUnitUseItemHook.return_false

	@ call func

	mov  r0, r4 @ arg r0 = unit
	mov  r1, r5 @ arg r1 = item

	bl   bx_r3

	@ returns 0 or non-0 in r0

IersCanUnitUseItemHook.end:
	pop  {r4-r5}
	pop  {r3}
bx_r3:
	bx   r3

IersCanUnitUseItemHook.return_false:
	mov  r0, #0
	b    IersCanUnitUseItemHook.end

IersCanUnitUseItemHook.vanilla_effect:
	cmp  r0, #0x37 @ LAST_ITEM_EFFECT_ID
	bhi  IersCanUnitUseItemHook.return_false

	ldr  r3, =IersVanillaCanUnitUseItemJt
	ldr  r0, [r3, r1]
	mov  pc, r0 @ jt doesn't hold thumb bits, so we can't use bx

	.global IersGetItemCantUseMsgidHook
	.type IersGetItemCantUseMsgidHook, function
IersGetItemCantUseMsgidHook:
	@ hook at fe8u:08028C0C

	@ state:
	@  r0 = unit
	@  r1 = item

	push {r4-r6, lr}

	mov  r5, r0 @ var r5 = unit
	mov  r6, r1 @ var r6 = item

	@ get item use effect id

	mov  r0, r1 @ arg r0 = item

	ldr  r3, =GetItemUseEffect
	bl   bx_r3

	@ get IERS item effect table entry

	ldr  r3, =IersEffectTable
	lsl  r1, r0, #2
	ldr  r3, [r3, r1]

	@ if entry is null ptr, do vanilla behavior

	cmp  r3, #0
	beq  IersGetItemCantUseMsgidHook.vanilla_effect

	@ get msgid func

	ldr  r3, [r3, #0x0C]

	@ if msgid func is null ptr, return default

	cmp  r3, #0
	beq  IersGetItemCantUseMsgidHook.return_default

	@ call func

	mov  r0, r5 @ arg r0 = unit
	mov  r1, r6 @ arg r1 = item

	bl   bx_r3

	@ returns msg id in r0

IersGetItemCantUseMsgidHook.end:
	pop  {r4-r6}
	pop  {r1}
	bx   r1

IersGetItemCantUseMsgidHook.return_default:
	ldr  r0, =0x85A
	b    IersGetItemCantUseMsgidHook.end

IersGetItemCantUseMsgidHook.vanilla_effect:
	cmp  r0, #0x37 @ LAST_ITEM_EFFECT_ID
	bhi  IersGetItemCantUseMsgidHook.return_default

	ldr  r3, =IersVanillaGetItemCantUseMsgidJt
	ldr  r0, [r3, r1]
	mov  pc, r0 @ jt doesn't hold thumb bits, so we can't use bx

	.global IersDoItemEffectHook
	.type IersDoItemEffectHook, function
IersDoItemEffectHook:
	@ hook at fe8u:08028E70

	@ state:
	@  r5 = unit
	@  r4 = item

	@ get item use effect id

	mov  r0, r4 @ arg r0 = item

	ldr  r3, =GetItemUseEffect
	bl   bx_r3

	@ get IERS item effect table entry

	ldr  r3, =IersEffectTable
	lsl  r1, r0, #2
	ldr  r3, [r3, r1]

	@ if entry is null ptr, do vanilla behavior

	cmp  r3, #0
	beq  IersDoItemEffectHook.vanilla_effect

	@ get effect func

	ldr  r3, [r3, #0x04]

	@ if effect func is null ptr, do nothing

	cmp  r3, #0
	beq  IersDoItemEffectHook.end

	@ call func

	mov  r0, r5 @ arg r0 = unit
	mov  r1, r6 @ arg r1 = item

	bl   bx_r3

IersDoItemEffectHook.end:
	pop  {r4-r5}
	pop  {r0}
	bx   r0

IersDoItemEffectHook.vanilla_effect:
	cmp  r0, #0x37 @ LAST_ITEM_EFFECT_ID
	bhi  IersDoItemEffectHook.end

	ldr  r3, =IersVanillaDoItemEffectHookJt
	ldr  r0, [r3, r1]
	mov  pc, r0 @ jt doesn't hold thumb bits, so we can't use bx

	.global IersDoItemActionHook
	.type IersDoItemActionHook, function
IersDoItemActionHook:
	@ hook at fe8u:0802FC70

	@ state:
	@  r4 = gActionData
	@  r6 = proc
	@  r8 = item iid

	@ check for nightmare because of course

	mov  r0, r8
	cmp  r0, #0xA6
	beq  IersDoItemActionHook.nightmare

	@ get item

	ldrb r0, [r4, #0x0C] @ Action::unit_id

	ldr  r3, =GetUnit
	bl   bx_r3

	ldrb r1, [r4, #0x12] @ Action::item_slot
	lsl  r1, #1
	add  r1, #0x1E
	ldrh r0, [r0, r1]

	@ get item use effect id

	@ implied @ arg r0 = item

	ldr  r3, =GetItemUseEffect
	bl   bx_r3

	@ get IERS item effect table entry

	ldr  r3, =IersEffectTable
	lsl  r1, r0, #2
	ldr  r3, [r3, r1]

	@ if entry is null ptr, do vanilla behavior

	cmp  r3, #0
	beq  IersDoItemActionHook.vanilla_effect

	@ get action func

	ldr  r3, [r3, #0x08]

	@ if action func is null ptr, do nothing

	cmp  r3, #0
	beq  IersDoItemActionHook.end

	@ call func

	mov  r0, r6 @ arg r0 = proc

	bl   bx_r3

IersDoItemActionHook.end:
	ldr  r3, =0x0802FF76+1
	bx   r3

IersDoItemActionHook.nightmare:
	ldr  r3, =0x0802FE7C+1
	bx   r3

IersDoItemActionHook.vanilla_effect:
	cmp  r0, #0x37 @ LAST_ITEM_EFFECT_ID
	bhi  IersDoItemActionHook.end

	ldr  r3, =IersVanillaDoItemActionHookJt
	ldr  r0, [r3, r1]
	mov  pc, r0 @ jt doesn't hold thumb bits, so we can't use bx

	.global IersCanUnitUseItemPrepHook
	.type IersCanUnitUseItemPrepHook, function
IersCanUnitUseItemPrepHook:
	@ hook at fe8u:08029F18

	@ state:
	@  r0 = item
	@  r4 = item
	@  r5 = unit

	@ get item use effect id

	@ implied @ arg r0 = item

	ldr  r3, =GetItemUseEffect
	bl   bx_r3

	@ get IERS item effect table entry

	ldr  r3, =IersEffectTable
	lsl  r1, r0, #2
	ldr  r3, [r3, r1]

	@ if entry is null ptr, do vanilla behavior

	cmp  r3, #0
	beq  IersCanUnitUseItemPrepHook.vanilla_effect

	@ get usability func

	ldr  r3, [r3, #0x10]

	@ if usability func is null ptr, return false

	cmp  r3, #0
	beq  IersCanUnitUseItemPrepHook.return_false

	@ call func

	mov  r0, r5 @ arg r0 = unit
	mov  r1, r4 @ arg r1 = item

	bl   bx_r3

	@ returns 0 or non-0 in r0

IersCanUnitUseItemPrepHook.end:
	pop  {r4-r5}
	pop  {r1}
	bx   r1

IersCanUnitUseItemPrepHook.return_false:
	mov  r0, #0
	b    IersCanUnitUseItemPrepHook.end

IersCanUnitUseItemPrepHook.vanilla_effect:
	cmp  r0, #0x37 @ LAST_ITEM_EFFECT_ID
	bhi  IersCanUnitUseItemPrepHook.return_false

	ldr  r3, =IersVanillaCanUnitUseItemPrepJt
	ldr  r0, [r3, r1]
	mov  pc, r0 @ jt doesn't hold thumb bits, so we can't use bx
