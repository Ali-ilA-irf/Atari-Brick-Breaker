[org 0x0100]
jmp start
level: dw 1
score: dw 0
score_location: dw 0
lives_1: dw 5
lives_location: dw 0
Walls_width: db 5, 7
colors: db 0x40, 0x20, 0x10, 0x60
msg1: db 'SCORE'
msg1_length: dw 5
msg2: db 'LIVES'
msg2_length: dw 5
msg3:db 'Welcome to Atari Breakout'
msg3_length: dw 25
msg4: db 'Press any key to continue'
msg4_length: dw 25
msg5: db 'GameOver'
msg5_length: dw 8
msg6: db 'WIN'
msg6_length: dw 3
inst: db 'Instructions'
inst_len: dw 12
inst1: db '-> for right'
inst1_len: dw 12
inst2: db '<- for left'
inst2_len: dw 11
inst3: db 'levels increase will increase the Ball speed'
inst3_len: dw 44
inst4: db 'levels increase if the score is more than 350'
inst4_len: dw 45
inst5: db 'Total Levels -> 3'
inst5_len: dw 17
inst6: db 'LEVEL '
inst6_len: dw 6
inst7: db 'Game-Over'
inst7_len: dw 9
inst8: db 'You Won'
inst8_len: dw 7
delay: dw 100,600
bricks_count: dw 0
Ball_location: dw 0
Ball_location_Permanent: dw 0
Angle_horizontal: db 0,1 ;0 means 90 and 1 means 45
Angle_Vertcial: db 0,1 ; 0 means on and 1 means off
reset: db 0
Collisions: db 0 
paddle_location_left: dw 0
paddle_location_right: dw 0
di_saver: dw 0
di_saver_2: dw 0
steeper: db 0
seed_dw: dw 1234
mainMenuTitle: db '╔════════════════════════════════════════╗', 0
mainMenuLine1: db '║                                        ║', 0
mainMenuLine2: db '║         BRICK BREAKER GAME             ║', 0
mainMenuLine3: db '║                                        ║', 0
mainMenuLine4: db '╚════════════════════════════════════════╝', 0
main_lenght: dw 42

powerup_active: db 0           ; 1 if powerup is falling
powerup_location: dw 0         ; current location of powerup
powerup_char: db 'P'          ; powerup character
powerup_attr: db 0x5F         ; magenta 'P'
powerup_speed: dw 160         ; falls by 1 row
powerup_trigger_score: dw 100 ; score at which powerup spawns
paddle_size: dw 8             ; current paddle size (default 8)
paddle_extended: db 0         ; 1 if paddle is extended
powerup_expiry_L dw 0       ; Lower 16 bits of expiry time
powerup_expiry_H dw 0       ; Higher 16 bits of expiry time
powerup_timer_on db 0       ; 1 if the 10s timer is running
start:
push word 3000h
call clrscr
call mainMenuLoop
mov ah,00h
int 16h
push word 3000h
call clrscr
call InstructionScreen
mov ah,00h
int 16h
push word 3000h
call clrscr
l11:
	call print_level
	push word 0700h
	call clrscr
	call printMap
	call Gameloop
	push word 3000h
	call clrscr
	cmp word [level],3
	jbe l11
	push word 3000h
	call clrscr
exit:
	call winOrlose
    mov ax, 4C00h
    int 21h
;-------------------------------------------------------Randomizer Funtions-----------------------------------------------
Randomizer_Walls:
    push ax
    push bx
	push cx
    mov ax, [seed_dw]    ; load seed
	imul ax ,5
    mov [seed_dw], ax    ; store updated seed
    mov cx, 2          ; range = 0..3
    xor dx, dx
    div cx               ; DX = remainder = 0..3	
	pop cx
    pop bx
    pop ax
    ret
Randomizer_colors:
    push ax
    push bx
	push cx
    mov ax, [seed_dw]    ; load seedS
    mov cx, 4            ; range = 0..3
    xor dx, dx
    div cx               ; DX = remainder = 0..3
	mov [seed_dw],ax
	pop cx
    pop bx
    pop ax
    ret
;-------------------------------------------------------------------Printing the whole map and saveing locations----------------------------------------------
printMap:
push bp
mov bp,sp
sub sp,2
push ax
push bx
push cx
push dx
mov ax ,0xb800
mov es,ax
mov di, 4
imul di,80
mov [di_saver],di
add word [di_saver],50
shl word [di_saver],1
mov ax,[di_saver]
mov [bp-2],ax				; saving for later
add di ,4
shl di,1
mov cx,0
l1:
push di

	l2:
		mov si,Walls_width
		call Randomizer_Walls
		add si,dx
		mov cl,[si]			; width
		mov si,colors
		call Randomizer_colors
		add si,dx
		mov ah,[si] ;atribute
		mov al,20h
		add word [bricks_count],1
		l3:
		mov [es:di],ax
		add di,2
		cmp di,[di_saver]
		je skip
		loop l3
		add di,2
		cmp di,[di_saver]
		jne l2
		
skip:
pop di
add di,160
add word [di_saver],160
cmp di , 11*160
jna l1
;------------------------------------------------------------Ball---------------------------------------------------------
mov word [es:di], 0309h
mov word [Ball_location],di
mov word [Ball_location_Permanent],di

;------------------------------------------------------------------------Layout-------------------------------------------------------------
mov ax ,0 ;left

  mov bx,79;right
  shl bx ,1
  
  mov si,24	;bottom left
  imul si, 80
  shl si ,1
  mov dx,24 ;bottom right
  imul dx, 80
  add dx,79
  shl dx ,1
  
  mov cx ,4
  narrowing:
  push ax
  push bx
  push si
  push dx
  call print_squares
  pop dx
  pop si
  pop bx
  pop ax
  add ax,162
  add bx,158
  sub si,158
  sub dx,162
  loop narrowing
mov cx,4
mov di,[bp-2]
mov ax,0x3020
l4:
	push di
	push cx
	mov cx,17
	l5:
	mov [es:di],ax
	cmp cx,11
	jnb skip1
	cmp cx,7
	jna skip1
	call StraightLines
	skip1:
	add di,160
	loop l5
	pop cx
	pop di
	add di,2
	loop l4
	
;---------------------------------------------------------- msgs-----------------------------------------------------------

mov di,[bp-2]
add di,28
push di
add di,2*160
push word 0300h
push di
push word msg1
push word [msg1_length]
call print_msgs
add di,2*160
mov [score_location],di
pop di
add di,12*160
push word 0300h
push di
push word msg2
push word [msg2_length]
call print_msgs
add di,2*160
mov [lives_location],di
;--------------------------------------------------------------PrintNum---------------------------------------------
push word [score_location]
push word [score]
call printnum

push word [lives_location]
push word [lives_1]
call printnum
;--------------------------------------------------------------Paddle-----------------------------------------------
mov di,20*160
add di,46
mov ax,5020h
mov [paddle_location_left],di
mov cx ,8
rep stosw
sub di,2
mov [paddle_location_right],di
mov di,20*160
add di,8
mov word [di_saver],di
sub di,6
add di,96
mov word [di_saver_2],di
;----------------------------------------------------------popinggg---------------------------------------------------
pop DX
pop CX
pop bx
pop ax
mov sp,bp
pop bp
ret
;-----------------------------------------------------------------Layout Helper 1--------------------------------------------
StraightLines:
push di
push cx
mov ah,0x30
mov al,20h
mov cx,27
starighty:
mov [es:di],ax
add di,2
loop starighty
pop cx
pop di
ret
;-----------------------------------------------------------------Layout Helper 2--------------------------------------------

print_squares:
	push bx
	push ax
	mov di,ax
	mov ah,0x30
	mov al,20h
	squaring1:
	mov [es:di],ax
	add di,2
	cmp di,bx
	jna squaring1

	mov di,bx
	squaring2:
	mov [es:di],ax
	add di,160
	cmp di,dx
	jna squaring2
	mov di,dx
	squaring3:
	mov [es:di],ax
	sub di,2
	cmp di,si
	jnb squaring3
	mov di,si
	pop bx
	squaring4:
	mov [es:di],ax
	sub di,160
	cmp di,bx
	ja squaring4
	mov ax,bx
	pop bx
ret
;--------------------------------------------------------------Printing Msgs helper --------------------------------------------------
print_msgs:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push di
mov ax,0xb800
mov es,ax
mov cx,[bp+4]
mov si,[bp+6]
mov di,[bp+8]
mov ax,[bp+10]
sub di,4

cld 
next_character:
lodsb
stosw
loop next_character
pop di
pop DX
pop CX
pop bx
pop ax
mov sp,bp
pop bp
ret 8
;----------------------------------------------------------Printing Paddle-----------------------------------------------
print_Paddle:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push di
push si

mov ah,50h
mov al,20h
mov cx,6
mov di,[paddle_location_left]
mov si,[paddle_location_right]
l9:
mov [es:di],ax
add di,2
cmp di,si
jna l9

pop si
pop di
pop DX
pop CX
pop bx
pop ax
mov sp,bp
pop bp
ret 
;-------------------------------------------------------------------Main Gameloop------------------------------------------------
Gameloop:
l10:

	mov cx, [delay]   
	Delay1:
	call read_input
    mov dx, [delay+2]  
	Delay2:
	call read_input
    dec dx
    jnz Delay2
    dec cx
    jnz Delay1
call Ball_update
call read_input

call update_powerup
call check_powerup_timer
call read_input
call Update_Board
cmp word [lives_1],0
je GameOver
push word [level]
call checkLevel
pop cx
cmp cx,[level]
jne return1
cmp word [bricks_count],0
ja Gameloop
jmp return1
GameOver:
mov word [level],5
return1:
ret
;-------------------------------------------------------------------------Ball Reset-------------------------------------
isreset:
cmp byte[reset],1
jne return6
mov di,[Ball_location]
mov word [es:di],0720h
mov di,[Ball_location_Permanent]
mov word [es:di],0309h
mov word [Ball_location],di
mov byte[Angle_horizontal],0
mov byte[Angle_horizontal+1],1
mov byte[Angle_Vertcial],0
mov byte[Angle_Vertcial+1],1
mov byte[reset],0
call reset_paddle_size
mov byte [powerup_active], 0

return6:
ret
;--------------------------------------------------------------------Updating Scoreboard --------------------------------------------
Update_Board:
push byte 03h
push word [score_location]
push word [score]
call printnum
push byte 03h
push word [lives_location]
push word [lives_1]
call printnum
ret
;------------------------------------------------------------------Ball updation ------------------------------------------------------
Ball_update:
push bp
mov bp,sp
sub sp,4
push ax
push bx
push cx
push dx
push di
again:
call update_possition_Ball
call Detect_collision
call isreset
cmp byte [Collisions],1
je again
mov di,[Ball_location]
mov word [es:di],0720h
mov di,[bp-2]
mov word [es:di],0309h
mov word [Ball_location],di

pop di
pop dx
pop cx
pop bx
pop ax
mov sp,bp
pop bp
ret


update_possition_Ball:
cmp byte [Angle_Vertcial],1
jne downs
call up_lnr
jmp return3
downs:
call down_lnr
return3:
ret
;-------------------------------------movement Function--------------------------------------
up_lnr:
cmp byte [Angle_horizontal],1
jne next_check1
mov di,[Ball_location]
sub di,162
mov [bp-2],di

cmp byte [steeper],1
jne return4
sub word [bp-2],2

return4:
ret

next_check1:
mov di,[Ball_location]
sub di,158
mov [bp-2],di

cmp byte [steeper],1
jne return4
add word [bp-2],2

jmp return4

down_lnr
cmp byte [Angle_horizontal],1
jne next_check2
mov di,[Ball_location]
add di,158
mov [bp-2],di


cmp byte [steeper],1
jne return5
sub word [bp-2],2


return5:
ret
next_check2:
mov di,[Ball_location]
add di,162
mov [bp-2],di
cmp byte [steeper],1
jne return5
add word [bp-2],2

jmp return5
;-------------------------------------------detect Collisions-----------------------------------
Detect_collision:
mov di,[bp-2]
	xor dx,dx
    mov ax, di
    mov bx, 160          
    div bx              

    mov bx, ax           
    mov cx, 2           
    mov ax, dx
	xor dx,dx	
    div cx             

    mov cx, ax
	mov ax,[es:di]
	cmp ah,50h
	je near Collision_with_Paddel	
	cmp ah,07h
	je up
	cmp ah,30h
	je up
	
	call Collision_with_brick
	jmp return2
up:	cmp bx, 3
	ja down
	mov byte [Collisions],1
	mov byte[Angle_Vertcial+1],1
	mov byte[Angle_Vertcial],0
	ret
down:
	cmp bx,21
	jb left
	sub word [lives_1],1
	    ; Play beep for "Hit Wall" - 500Hz, 150ms
    mov ax, 500
    mov cx, 150
    call beep
	mov byte[reset],1
downy:
	mov byte[Collisions],1
	mov byte[Angle_Vertcial+1],0
	mov byte[Angle_Vertcial],1

	ret
left:
	cmp cx,3
	ja right
	mov byte [Collisions],1
	mov byte[Angle_horizontal+1],1
	mov byte[Angle_horizontal],0
	ret
right:
	cmp cx,50
	jb return2
	mov byte [Collisions],1
	mov byte[Angle_horizontal+1],0
	mov byte[Angle_horizontal],1
	ret
return2:
mov byte [Collisions],0
ret

Collision_with_brick:
    call update_score
    push ax
    ; Play beep for "Score Gain" - 1000Hz, 100ms
    mov ax, 1000
    mov cx, 100
    call beep
    pop ax

    ; Scan right logic (unchanged)
    mov bx, di
    mov al, 20h
    cld
    mov di, bx
    mov cx, 10
scan_r1:
    scasw
    jnz space_right_found
    loop scan_r1
    
space_right_found:
    mov dx, bx
    sub di, 4
    mov bx, di
    mov di, dx

    ; Scan left logic (unchanged)
    mov al, 20h
    std
    mov cx, 10
scan_l:
    scasw
    jnz space_left_found
    loop scan_l
        
space_left_found:
    add di, 4
    mov dx, di          ; DX now holds the starting location of the brick
    push bx 
    push dx
    call print_spaces   ; The brick is erased here
    
    sub word [bricks_count], 1
    
    ; ---------------- NEW SPAWN LOGIC STARTS HERE ----------------
    ; Check if we should spawn a powerup at this brick's location (DX)
    
    cmp byte [powerup_active], 1   ; If a powerup is already falling, don't spawn another
    je .skip_spawn
    
    mov ax, [score]
    cmp ax, [powerup_trigger_score] ; Check if score reached the target
    jb .skip_spawn
    
    ; --- SPAWN THE POWERUP ---
    mov [powerup_location], dx      ; Set location to where the brick was (DX)
    mov byte [powerup_active], 1    ; Activate it
    
    ; Draw the 'P' immediately
    mov al, [powerup_char]
    mov ah, [powerup_attr]
    mov di, dx
    mov [es:di], ax
    
    ; Increase the requirement for the next powerup
    add word [powerup_trigger_score], 100 
    
.skip_spawn:
    ; ---------------- NEW SPAWN LOGIC ENDS HERE ----------------

    mov byte [Collisions], 1
    mov byte [steeper], 0
    cmp byte [Angle_Vertcial], 1
    jne meow

    mov byte [Angle_Vertcial+1], 1
    mov byte [Angle_Vertcial], 0
    ret
meow:
    mov byte [Angle_Vertcial+1], 0
    mov byte [Angle_Vertcial], 1
    ret
;---------------------------------------collision with padel-----------------------------
Collision_with_Paddel:
mov di,[bp-2]
mov byte[steeper],0
mov ax ,[paddle_location_left]
mov bx,[paddle_location_right]
add ax,2
sub bx,2
cmp di,ax
je downys
cmp di,bx
je downys
jmp downy
downys
mov byte [steeper],1
jmp downy

;----------------------------------------------------------------Update color based on color---------------------------
update_score:
red:
cmp ah,40h
jne green
add word [score],15
ret
green:
cmp ah,20h
jne blue
add word [score],10
ret
blue:
cmp ah ,10h
jne orange
add word [score],5
ret
orange:
add word [score],2
ret

;-------------------------------------------------------------Helper For erasing locations----------------------------------------
print_spaces:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push ds
push es
push di
mov di,[bp+4]
mov si,[bp+6]

mov ax,0720h
l7:
mov [es:di],ax
add di,2
cmp di,si
jna l7
pop di
pop es
pop ds
pop dx
pop cx
pop bx
pop ax
pop bp
ret 4

;--------------------------------------------------------------------------For moving Paddle -------------------------------------------------
read_input:
    mov ah,01h        ; check if a key is available
    int 16h
    jz no_key         

    mov ah,00h        
    int 16h           

    cmp ah,4Bh        
    je paddle_left

    cmp ah,4Dh        
    je paddle_right
	jmp no_key
printing:
	call print_Paddle
no_key:
    ret




paddle_left:
mov di,[di_saver]
cmp word [paddle_location_left],di
jbe no_key
push word [paddle_location_right]
push word [paddle_location_left]
call print_spaces
sub word [paddle_location_left],2
sub word [paddle_location_right],2
jmp printing

paddle_right:
mov di,[di_saver_2]
cmp word [paddle_location_right],di
jae no_key
push word [paddle_location_right]
push word [paddle_location_left]
call print_spaces
add word [paddle_location_left],2
add word [paddle_location_right],2
jmp printing









;--------------------------------------------------------------------------Other -----------------------------------------------------

printnum:
    push bp
    mov  bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di

    mov  ax, 0xb800
    mov  es, ax
    mov  ax, [bp+4]
	mov di,[bp+6]
	mov  bx, 10
    mov  cx, 0
	cmp ax,10
	jb convert_loop
	sub di,2


convert_loop:
    mov  dx, 0
    div  bx
    add  dl, 30h
    push dx
    inc  cx
    cmp  ax, 0
    jnz  convert_loop
print_loop:
    pop  bx
    mov  dh, [bp+8]
	mov dl,bl
    mov  [es:di], dx
    add  di, 2
    loop print_loop
    pop  di
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    pop  es
    pop  bp
    ret 6
clrscr:
	push bp
	mov bp,sp
  push es
  push ax
  push di
  mov ax, 0xb800
  mov es, ax
	mov ax , [bp+4]  ; ES -> video mem
	mov al,20h
  mov di, 0                ; DI -> start (top-left)
nextloc:
  mov  [es:di], ax ; write space + attribute
  add di, 2
  cmp di, 4000
  jne nextloc
  pop di
  pop ax
  pop es
  pop bp
  ret 2


;----------------------------------------------------------------------------------Phool waghera----------------------------------------------------------
HomeScreen:
    push ax
    push bx
    push cx
    push dx
    push es
    push di

    mov ax, 0xB800
    mov es, ax
    xor di, di                ; start of video memory

	mov di, 11*160
    add di,27*2       ; row 10, col 20
	mov ah, 0x3E
	mov al,20h
    push ax
    push di
    push word msg3              ; "Atari Breakout"
    push word [msg3_length]

    call print_msgs

    ; Skip 2 lines
    add di, 5*160
	mov ah,0xb4
    push ax
    push di
    push word msg4              ; "Atari Breakout"
    push word [msg4_length]
	call print_msgs
	
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

InstructionScreen:
    push ax
    push bx
    push cx
    push dx
    push es
    push di

    mov ax, 0xB800
    mov es, ax
    xor di, di

    mov di, 9*160
	add di,	33*2      ; row 24, col 10
	mov ah,0x3E
	mov al,20h
	push ax
    push di
    push word inst            
    push word [inst_len]
    call print_msgs
	add di,2*160
	sub di , 13*2
    push ax
    push di
    push word inst1             
    push word [inst1_len]
    call print_msgs
	add di,160
	push ax
    push di
    push word inst2              
    push word [inst2_len]
    call print_msgs
	add di,160
	push ax
    push di
    push word inst3              
    push word [inst3_len]
    call print_msgs
	add di,160
	push ax
    push di
    push word inst4              
    push word [inst4_len]
    call print_msgs
	add di,160
	push ax
    push di
    push word inst5              
    push word [inst5_len]
    call print_msgs
	
	
	add di,3*160
	mov ah,0xb4
    push ax
    push di
    push word msg4              ; "Atari Breakout"
    push word [msg4_length]
	 call print_msgs
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
	
	
	print_level:
	push ax
    push bx
    push cx
    push dx
    push es
    push di
	mov di,11*160
	add di,37*2
	mov ah,0x3E
	mov al,20h
	push ax
    push di
    push word inst6              
    push word [inst6_len]
    call print_msgs
	add di,[inst6_len]
	add di,[inst6_len]
	sub di,4
	push byte 3Eh
	push di
	push word [level]
	call printnum
	
	pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
	mov ah,00h
	int 16h
    ret
	
;--------------------------------------------------------------------------For new levels n shit----------------------------------------------------------------
	checkLevel:
	cmp word [score],350
	jbe return7
	mov word [score],0
	add word [level],1
	sub word [delay+2],150
	  mov word [powerup_trigger_score], 100
    mov byte [powerup_active], 0
    call reset_paddle_size
	return7:
	ret
	
	winOrlose:
	cmp word [level],5
	je lose
	mov di,11*160
	add di,37*2
	mov ah,0x3E
	mov al,20h
	push ax
    push di
    push word inst8              
    push word [inst8_len]
    call print_msgs
	jmp return8
	lose:
	mov di,11*160
	add di,36*2
	mov ah,0x3E
	mov al,20h
	push ax
    push di
    push word inst7              
    push word [inst7_len]
    call print_msgs
	    ; Play beep for "Game Over" - 200Hz, 400ms
    mov ax, 200
    mov cx, 400
    call beep
	return8:
	ret
	
	

beep:
    push dx
    push bx

    mov bx, ax          ; frequency
    cmp bx, 37          ; min frequency
    jae .freq_ok
    mov bx, 37
.freq_ok:

    mov ax, 11180
    cwd
    idiv bx             ; ax = 1193180 / bx
    mov bx, ax

    ; program PIT channel 2
    mov al, 0B6h
    out 43h, al
    mov al, bl
    out 42h, al
    mov al, bh
    out 42h, al

    ; turn on speaker
    in al, 61h
    or al, 03h
    out 61h, al

    ; delay for duration
    push cx
    mov ax, cx
    call delay_ms
    pop cx

    ; turn off speaker
    in al, 61h
    and al, 0FCh
    out 61h, al

    pop bx
    pop dx
    ret

delay_ms:
    push cx
    push dx
    mov cx, ax
.loop:
    mov dx, 1193       ; approx 1ms per iteration
.delay:
    dec dx
    jnz .delay
    loop .loop
    pop dx
    pop cx
    ret


setCursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

mainMenuLoop:

      ; Draw title box with GREEN color
    mov dh, 9
    mov dl, 20
    call setCursor
    mov si, mainMenuTitle
    mov bl, 0x3A           ; Bright GREEN
    call printStringColor
    mov dh, 10
    mov dl, 20
    call setCursor
    mov si, mainMenuLine1
    mov bl, 0x3A            ; Bright GREEN
    call printStringColor
    mov dh, 11
    mov dl, 20
    call setCursor
    mov si, mainMenuLine2
    mov bl, 0x3E            ; Bright WHITE (for title text)
    call printStringColor
    mov dh, 12
    mov dl, 20
    call setCursor
    mov si, mainMenuLine3
    mov bl, 0x3A            ; Bright GREEN
    call printStringColor
    mov dh, 13
    mov dl, 20
    call setCursor
    mov si, mainMenuLine4
    mov bl, 0x3A            ; Bright GREEN
    call printStringColor
	mov dh,25
	mov dl,0
	call setCursor
	ret
	
	
	
	printStringColor:
    ; SI = string pointer
    ; BL = color
printColorLoop:
    lodsb
    cmp al, 0
    je printColorDone
    ; Print character with color
    mov ah, 0x09
    mov bh, 0
    mov cx, 1
    int 0x10
    ; Move cursor one position right
    mov ah, 0x03
    mov bh, 0
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    jmp printColorLoop
printColorDone:
    ret
	
	
	;----------------------------------------------Power UPS ----------------------------------------------
	check_powerup_spawn:
    push ax
    push bx
    push dx
    
    ; Check if powerup already active
    cmp byte [powerup_active], 1
    je .no_spawn
    
    ; Check if score >= next trigger score
    mov ax, [score]
    cmp ax, [powerup_trigger_score]
    jb .no_spawn
    
    ; Spawn powerup
    call spawn_powerup
    
    ; Update trigger for next powerup (add 100)
    add word [powerup_trigger_score], 100
    
.no_spawn:
    pop dx
    pop bx
    pop ax
    ret

;-------------- POWERUP: Spawn at random brick location --------------
spawn_powerup:
    push ax
    push bx
    push cx
    push di
    
    ; Find a random brick to spawn from
    mov cx, 20  ; Try 20 times to find a brick
    
.find_brick:
    call get_random_brick_location
    cmp di, 0
    jne .brick_found
    loop .find_brick
    
    ; If no brick found, spawn at top center
    mov di, 4*160 + 40*2
    
.brick_found:
    mov [powerup_location], di
    mov byte [powerup_active], 1
    
    ; Draw powerup
    mov al, [powerup_char]
    mov ah, [powerup_attr]
    mov [es:di], ax
    
    pop di
    pop cx
    pop bx
    pop ax
    ret

;-------------- POWERUP: Get random brick location --------------
get_random_brick_location:
    push ax
    push bx
    push cx
    
    ; Generate random row (4-10)
    call Randomizer_Walls
    add dx, 4
    mov ax, dx
    mov bx, 160
    mul bx
    mov di, ax
    
    ; Generate random column (4-50)
    call Randomizer_Walls
    mov ax, dx
    add ax, 10
    shl ax, 1
    add di, ax
    
    ; Check if there's a brick here
    mov ax, [es:di]
    cmp ah, 0x40  ; red
    je .is_brick
    cmp ah, 0x20  ; green
    je .is_brick
    cmp ah, 0x10  ; blue
    je .is_brick
    cmp ah, 0x60  ; orange
    je .is_brick
    
    ; Not a brick
    xor di, di
    jmp .done
    
.is_brick:
    ; di already contains the location
    
.done:
    pop cx
    pop bx
    pop ax
    ret

;-------------- POWERUP: Update position (make it fall) --------------
update_powerup:
    push ax
    push bx
    push di
    
    cmp byte [powerup_active], 0
    je .no_update
    
    mov di, [powerup_location]  ; Save old location
    
    ; Calculate next position
    mov bx, di
    add bx, [powerup_speed]     ; bx = next position
    
    ; Check attribute at next position BEFORE moving
    mov ax, [es:bx]             ; Reads character into AL and Attribute into AH
    
    ; --- FIX START ---
    ; Removed 'mov ah, al' so AH still holds the color attribute
    ; --- FIX END ---
    
    ; Check if next position is paddle (magenta 0x50)
    cmp ah, 0x50
    je .caught
    
    ; Check if next position is cyan boundary (0x30)
    cmp ah, 0x30
    je .hit_boundary
    
    ; Check if went off screen (row 22)
    push dx
    mov ax, bx
    mov dx, 0
    push bx
    mov bx, 160
    div bx
    pop bx
    pop dx
    cmp ax, 22
    jae .deactivate
    
    ; Safe to move - erase old position
    mov word [es:di], 0x0720
    
    ; Move to new position
    mov di, bx
    mov [powerup_location], di
    
    ; Draw at new position
    mov al, [powerup_char]
    mov ah, [powerup_attr]
    mov [es:di], ax
    
    jmp .no_update
    
.caught:
    ; Erase at current position before activating
    mov word [es:di], 0x0720
    call activate_powerup
    ; Play sound for catching powerup
    push ax
    push cx
    mov ax, 1500
    mov cx, 150
    call beep
    pop cx
    pop ax
    jmp .deactivate
    
.hit_boundary:
    ; Hit cyan boundary - just vanish without moving
    mov word [es:di], 0x0720  ; Erase at current position
    jmp .deactivate
    
.deactivate:
    mov byte [powerup_active], 0
    
.no_update:
    pop di
    pop bx
    pop ax
    ret

;-------------- POWERUP: Check collision with paddle --------------
check_powerup_collision:
    push bx
    push cx
    push di
    
    mov di, [powerup_location]
    
    ; Get row of powerup
    mov ax, di
    mov bx, 160
    xor dx, dx
    div bx
    mov cx, ax  ; cx = row
    
    ; Check if on paddle row (20)
    cmp cx, 20
    jne .no_collision
    
    ; Check column
    mov ax, di
    xor dx, dx
    mov bx, 160
    div bx
    mov ax, dx  ; ax = offset in row
    shr ax, 1   ; convert to column
    
    mov bx, [paddle_location_left]
    xor dx, dx
    push ax
    mov ax, bx
    mov bx, 160
    div bx
    mov bx, dx
    shr bx, 1   ; left column
    pop ax
    
    mov cx, [paddle_location_right]
    xor dx, dx
    push ax
    mov ax, cx
    mov cx, 160
    div cx
    mov cx, dx
    shr cx, 1   ; right column
    pop ax
    
    cmp ax, bx
    jb .no_collision
    cmp ax, cx
    ja .no_collision
    
    ; Collision detected!
    mov al, 1
    jmp .done
    
.no_collision:
    xor al, al
    
.done:
    pop di
    pop cx
    pop bx
    ret

;-------------- POWERUP: Activate effect (extend paddle) --------------
;-------------- POWERUP: Activate effect (extend paddle) --------------
activate_powerup:
    push ax
    push di
    push cx
    push dx                 ; Save DX as well
    
    ; Already extended?
    cmp byte [paddle_extended], 1
    je .reset_timer_only    ; If already extended, just reset the 10s timer
    
    ; Extend paddle by 4 (2 on each side)
    mov byte [paddle_extended], 1
    add word [paddle_size], 4
    
    ; Redraw paddle
    mov di, [paddle_location_left]
    sub di, 4  ; extend left by 2 chars
    mov [paddle_location_left], di
    
    mov di, [paddle_location_right]
    add di, 4  ; extend right by 2 chars
    mov [paddle_location_right], di
    
    ; Check boundaries (Your existing boundary logic)
    mov ax, [di_saver]
    cmp word [paddle_location_left], ax
    jae .left_ok
    mov [paddle_location_left], ax
.left_ok:
    mov ax, [di_saver_2]
    cmp word [paddle_location_right], ax
    jbe .right_ok
    mov [paddle_location_right], ax
.right_ok:
    call print_Paddle

.reset_timer_only:
    ; --- NEW: SET 10 SECOND TIMER ---
    mov ah, 00h
    int 1Ah                 ; Get System Time (CX:DX = Clock Ticks)
    
    add dx, 182             ; Add ~10 seconds (18.2 ticks * 10 = 182)
    adc cx, 0               ; Add carry to high word if DX overflowed
    
    mov [powerup_expiry_L], dx
    mov [powerup_expiry_H], cx
    mov byte [powerup_timer_on], 1
    ; --------------------------------
    
    pop dx
    pop cx
    pop di
    pop ax
    ret


;-------------- POWERUP: Reset paddle size (call when losing life) --------------
reset_paddle_size:
    push ax
    push bx             ; Save BX register
    push di
    
    cmp byte [paddle_extended], 0
    je .not_extended
    
    ; --- FIX: ERASE THE EXTENDED PARTS ON SCREEN ---

    ; 1. Erase Left Wing (Current Left to Current Left + 2)
    mov ax, [paddle_location_left]
    mov bx, ax
    add bx, 2           ; End address for left wing
    push bx             ; Push End (Arg2 for print_spaces)
    push ax             ; Push Start (Arg1 for print_spaces)
    call print_spaces

    ; 2. Erase Right Wing (Current Right - 2 to Current Right)
    mov bx, [paddle_location_right]
    mov ax, bx
    sub ax, 2           ; Start address for right wing
    push bx             ; Push End
    push ax             ; Push Start
    call print_spaces

    ; --- END FIX ---
    
    ; Now safely shrink the paddle logic
    mov byte [paddle_extended], 0
    sub word [paddle_size], 4
    
    ; Update pointers to the new smaller size
    mov di, [paddle_location_left]
    add di, 4
    mov [paddle_location_left], di
    
    mov di, [paddle_location_right]
    sub di, 4
    mov [paddle_location_right], di
    
.not_extended:
    pop di
    pop bx              ; Restore BX register
    pop ax
    ret
	
	;-------------- POWERUP: Check if 10 seconds passed --------------
check_powerup_timer:
    push ax
    push cx
    push dx
    
    cmp byte [powerup_timer_on], 0
    je .done_timer
    
    ; Get current system time
    mov ah, 00h
    int 1Ah                 ; Returns CX:DX
    
    ; Compare High Word (CX)
    cmp cx, [powerup_expiry_H]
    jb .done_timer          ; Current Time < Expiry (High) -> Not done
    ja .time_up             ; Current Time > Expiry (High) -> Time Up
    
    ; Compare Low Word (DX) (only if High words are equal)
    cmp dx, [powerup_expiry_L]
    jb .done_timer          ; Current Time < Expiry (Low) -> Not done
    
.time_up:
    ; Time is up! Reset paddle
    call reset_paddle_size
    mov byte [powerup_timer_on], 0  ; Turn off timer
    
.done_timer:
    pop dx
    pop cx
    pop ax
    ret