
	.thumb

	.include "mss_defs.s"

	.global MSS_page1
	.type MSS_page1, function

MSS_page1:
	page_start

	@ r5 = gStatScreen (addr)
	@ r7 = gStatScreen.text
	@ r8 = gStatScreen.unit

	draw_textID_at 13, 3,  textID = 0x4FE, colour = 3 @ str
	draw_textID_at 13, 5,  textID = 0x4FF, colour = 3 @ mag
	draw_textID_at 13, 7,  textID = 0x4EC, colour = 3 @ skl
	draw_textID_at 13, 9,  textID = 0x4ED, colour = 3 @ spd
	draw_textID_at 13, 11, textID = 0x4EE, colour = 3 @ lck
	draw_textID_at 13, 13, textID = 0x4EF, colour = 3 @ def
	draw_textID_at 13, 15, textID = 0x4F0, colour = 3 @ res

	b NoRescue

	.pool

NoRescue:
	@ r0 = gStatScreen (addr) - 1
	sub  r0, r5, #1

	@ r1 = unit->id
	mov  r1, r8
	ldrb r1, [r1, #0x0B]

	@ goto Label2 if unit faction is blue
	mov  r2, #0xC0
	tst  r1, r2
	beq  Label2

	@ unset bit 0 if non blue (don't display growth)
	ldrb r1, [r0]
	mov  r2, #1
	bic  r1, r2
	strb r1, [r0]

Label2:
	ldrb r0, [r0]
	mov  r1, #1
	tst  r0, r1
	beq  ShowStats
	b    ShowGrowths

ShowStats:
	b		ShowStats2

ShowGrowths:
	ldr r0, =Growth_Getter_Table
	str r0, [sp, #0x0C]

	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#4]		@str growth getter
	draw_growth_at 18, 3
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#8]		@mag growth getter
	draw_growth_at 18, 5
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#12]		@skl growth getter
	draw_growth_at 18, 7
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#16]		@spd growth getter
	draw_growth_at 18, 9
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#20]		@luk growth getter
	draw_growth_at 18, 11
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#24]		@def growth getter
	draw_growth_at 18, 13
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0,#28]		@res growth getter
	draw_growth_at 18, 15
	ldr		r0,[sp,#0xC]
	ldr		r0,[r0]			@hp growth getter (not displaying because there's no room atm)
	draw_growth_at 18, 17
	draw_textID_at 13, 17, textID=0x4E9

	b		NextColumn

	.pool

ShowStats2:
	b		ShowStats3

NextColumn:
	draw_textID_at 21, 3, 0x4f6 @move
	draw_move_bar_with_getter_at 24, 3


	draw_textID_at 21, 5, textID=0x4f7 @con
	draw_con_bar_with_getter_at 24, 5


	draw_textID_at 21, 7, textID=0x4f8 @aid
	draw_number_at 25, 7, 0x80189B8, 2 @aid getter
	draw_aid_icon_at 26, 7

	ldr  r0, =lFatigueMsg
	ldrh r0, [r0]
	draw_textID_at 21, 9 @Fatigue label text

	ldr r0, =GetUnitDisplayFatigue
	mov lr, r0
	mov r0, r8
	.short 0xF800
	draw_number_at 25, 9

	draw_status_text_at 21, 11

	draw_textID_at 21, 13, textID=0x4f1 @affin
	draw_affinity_icon_at 24, 13

	ldr  r0, =lTalkMsg
	ldrh r0,[r0]
	draw_talk_text_at 21, 15

	b skipliterals

	.pool

ShowStats3:
	draw_str_bar_at 16, 3
	draw_mag_bar_at 16, 5
	draw_skl_bar_at 16, 7
	draw_spd_bar_at 16, 9
	draw_luck_bar_at 16, 11
	draw_def_bar_at 16, 13
	draw_res_bar_at 16, 15

	blh DrawBWLNumbers

	b NextColumn

	.pool

skipliterals:
	ldr		r0,=StatScreenStruct
	sub		r0,#0x2
	ldrb	r0,[r0]
	cmp		r0,#0x0
	beq		DoNotUpdate
	ldr		r0,=BgBitfield
	ldrb	r1,[r0]
	mov		r2,#0x5
	orr		r1,r2
	strb	r1,[r0]
	ldr		r0,=CopyToBG
	mov		r14,r0
	ldr		r0,=gBmFrameTmap0
	ldr		r1,=Const_2022D40
	mov		r2,#0x12
	mov		r3,#0x12
	.short	0xF800
	ldr		r0,=CopyToBG
	mov		r14,r0
	ldr		r0,=Const_200472C
	ldr		r1,=Const_2023D40
	mov		r2,#0x12
	mov		r3,#0x12
	.short	0xF800
	ldr		r0,=StatScreenStruct
	sub		r0,#0x2
	mov		r1,#0x0
	strb	r1,[r0]
	b DoNotUpdate

	.pool

DoNotUpdate:
	page_end

	.pool

lFatigueMsg:
	.short SS_FatigueText
lTalkMsg:
	.short SS_TalkText

	.include "GetTalkee.s"
