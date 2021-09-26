
	.thumb

	.global PostActionHook
	.type   PostActionHook, function

	@ replace MaybeRunPostActionEvents with PostActionHook

PostActionHook:
	push  {r4, r5, lr}

	@ r5 = return address for called functions
	adr   r5, lop
	add   r5, #1

	@ r4 = function list iterating pointer
	ldr   r4, =PostActionFuncList

	@ lop needs to be aligned for the adr above to work properly
	.align
lop:
	ldr   r0, [r4]
	add   r4, #4

	cmp   r0, #0
	beq   end

	mov   lr, r5
	bx    r0

end:
	pop   {r4, r5}
	pop   {r0}
	mov   lr, r0

	ldr   r3, =MaybeRunPostActionEvents
	bx    r3
