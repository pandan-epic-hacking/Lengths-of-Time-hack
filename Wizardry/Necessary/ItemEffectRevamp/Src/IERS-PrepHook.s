
	.thumb

	@ hook at fe8u:0809CB38

	push {r4, lr}

	mov  r4, r0 @ var r4 = proc

	ldr  r0, [r4, #0x2C]
	ldr  r1, [r4, #0x30]
	lsl  r1, #1
	add  r1, #0x1E
	ldrh r0, [r0, r1]

	ldr  r3, =GetItemUseEffect
	bl   bx_r3
