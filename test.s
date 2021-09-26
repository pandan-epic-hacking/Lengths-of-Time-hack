
    @ replaced
    mov  r5, #0x50
    add  r5, r7
    ldrb r0, [r5]
    mov  r4, #0x28
    add  r4, r7
    ldrb r6, [r4, r0]

    cmp  r6, #0
    beq  bad_end

    ldr  r3, =0x0802C132
    bx   r3

bad_end:
    ldr  r3, =0x0802C112
    bx   r3
