%include "common"

start:
    mov sp, 0
    mov r9, 1
    mov r10, 0
    mov r11, 0 ; console buffer position

    ; initialize displays
    send r10, 0x12e0    ; set the cursor position to bottom left
    send r10, 0x200a    ; set the screen color to green
    call clear_screen   ; clear the screen

    ; mov r0, input_buf
    ; mov r1, input_len
    ; mov r2, 0
    ; call scans
    ; mov r0, input_buf
    ; mov r1, 0
    ; call stoi
    ; mov r0, r1
    ; mov r4, input_buf
    ; call itos
    ; mov r0, input_buf
    ; call puts
    ; hlt

    mov r0, compile
    call puts

    ; compile commands
    mov r0, echo
    mov r1, echo_sum
    call strsum_ptr
    mov r0, help
    mov r1, help_sum
    call strsum_ptr
    mov r0, add_cmd
    mov r1, add_sum
    call strsum_ptr
    mov r0, sub_cmd
    mov r1, sub_sum
    call strsum_ptr
    mov r0, div_cmd
    mov r1, div_sum
    call strsum_ptr
    mov r0, mul_cmd
    mov r1, mul_sum
    call strsum_ptr

    call clear_screen

    ; startup
    mov r0, startup_message
    call puts
    mov r0, startup_message2
    call puts
.input_loop:
    ; input loop
    mov r0, newline
    call puts
    mov r0, input_prompt
    call puts
    ; would be better to limit the input buffer length
    ; so that we don't overflow into other memory
    mov r0, input_buf
    mov r1, input_len
    mov r2, 2
    call scans
    mov r0, newline
    call puts
    ; find out which command to call
    mov r0, input_buf
    mov r1, input_sum
    call strsum_ptr
    mov r2, [echo_sum]
    cmp [r1], r2
    je .echo
    mov r2, [help_sum]
    cmp [r1], r2
    je .help
    mov r2, [add_sum]
    cmp [r1], r2
    je .add_cmdf
    mov r2, [sub_sum]
    cmp [r1], r2
    je .sub_cmdf
    mov r2, [div_sum]
    cmp [r1], r2
    je .div_cmdf
    mov r2, [mul_sum]
    cmp [r1], r2
    je .mul_cmdf
    jmp .unknown
    hlt
    jmp start           ; allow hot reload

; Commands
.echo:
    mov r0, echo_prompt
    call puts
    mov r0, input_buf
    mov r1, input_len
    mov r2, 14
    call scans
    mov r0, newline
    call puts
    mov r0, input_buf
    call puts
    jmp .input_loop

.help:
    mov r0, help_msg
    call puts
    jmp .input_loop

.add_cmdf:
    call getab
    add r0, r1
    push r0
    mov r0, add_msg
    call puts
    pop r0
    mov r4, input_buf
    call itos
    mov r0, input_buf
    call puts
    jmp .input_loop

.sub_cmdf:
    call getab
    sub r0, r1
    push r0
    mov r0, sub_msg
    call puts
    pop r0
    mov r4, input_buf
    call itos
    mov r0, input_buf
    call puts
    jmp .input_loop

.div_cmdf:
    call getab
    call div16
    mov r0, r2
    push r3
    push r0
    mov r0, div_msg
    call puts
    pop r0
    mov r4, input_buf
    call itos
    mov r0, input_buf
    call puts
    mov r0, newline
    call puts
    mov r0, div_msg2
    call puts
    pop r0
    mov r4, input_buf
    call itos
    mov r0, input_buf
    call puts
    jmp .input_loop

.mul_cmdf:
    call getab
    call mul16
    mov r0, mul_msg
    call puts
    mov r0, r2
    mov r4, input_buf
    call itos
    mov r0, input_buf
    call puts
    jmp .input_loop

.unknown:
    mov r0, unknown_cmd
    call puts
    mov r0, input_buf
    call puts
    mov r0, unknown_cmd2
    call puts
    jmp .input_loop

; ; Divides a number by 10
; ; Very inaccurate, needs fix
; div10:
;     push r0
;     push r3
;     mov r2, 0x0100  ; initial count of how many divisors into r0 to check for
;     mov r1, 0x00A0  ; value of "divisor * r2"
;     xor r3, r3      ; result
; .top:
;     cmp r0, r1
;     jl .skip
;     ; we can fit "r2" copies of the divisor into r0, so tally them
;     add r3, r2
;     sub r0, r1
;     ; optionally can have a "jz done" here to break out of the loop
; .skip:
;     shr r1, 1
;     shr r2, 1
;     jnz .top

;     ; copy result into r1 and remainder in r2
;     mov r2, r0
;     mov r1, r3
;     pop r3
;     pop r0
;     ret

getab:
    mov r0, prompt_a
    call puts
    mov r0, input_buf
    mov r1, input_len
    mov r2, 2
    call scans
    mov r0, input_buf
    mov r1, 0
    call stoi
    push r1

    mov r0, newline
    call puts

    mov r0, prompt_b
    call puts
    mov r0, input_buf
    mov r1, input_len
    mov r2, 2
    call scans
    mov r0, input_buf
    mov r1, 0
    call stoi
    pop r0

    push r0
    mov r0, newline
    call puts
    pop r0

    ret

; Functions
clear_screen:
    ; send 24 line feeds
    send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	send r10, 0x3000
	ret

; Divides r0 by r1
; r2 - result
; r3 - remainder
div16:
    push r0

    mov r2, 0
    mov r3, 0
.loop:
    cmp r0, r1
    jl .lower
.greater:
    sub r0, r1
    add r2, 1
    jmp .loop
.lower:
    mov r3, r0

    pop r0
    ret

; Multiplies r0 by r1
; r2 - result
mul16:
    push r1
    mov r2, 0
.loop:
    cmp r1, 0
    je .end
    add r2, r0
    sub r1, 1
    jmp .loop
.end:
    pop r1
    ret


; Converts a zero terminated string to an integer
; r0 - string buffer
; r1 - output integer
stoi:
    push r2
    push r3
.loop:
    mov r2, [r0]
    jz .end
    ; multiply r1 by 10
    shl r1, 1
    mov r3, r1
    shl r1, 2
    add r1, r3

    sub r2, 48
    add r1, r2
    add r0, 1
    jmp .loop
.end:
    pop r3
    pop r2
    ret

getc:
    wait r9
    js getc
    bump r9
.sync_loop:
    recv [r0], r9
    ;cmp [r0], 0
    jz .sync_loop
    bump r9
    ret

; Convert an integer to a zero terminated string
; r0 - integer
; r4 - string buffer
itos:
    push r1
    push r2
    push r3
    push r5
    cmp r0, 0
    je .zero
    mov r1, 0
    mov r2, 0
    mov r5, 0
.loop:
    cmp r0, 0
    je .build_string
    mov r1, 10
    call div16
    mov r0, r2
    add r3, 48
    push r3
    add r5, 1
    jmp .loop
.build_string:
    cmp r5, 0
    je .end
    pop [r4]
    add r4, 1
    sub r5, 1
    jmp .build_string
.zero:
    mov [r4], 48
    add r4, 1
.end:
    mov [r4], 0
    pop r5
    pop r3
    pop r2
    pop r1
    ret

; Gets a zero-terminated string from the keyboard
; Returns length read in r12
; r2 - input offset
gets:
    mov r12, 0
    push r3
    mov r3, 0
    ;mov r3, 0x1000
    ;push r2
    ;add r2, 0xAF
    ;or r3, r2
    ;pop r2
.loop:
    call getc
    cmp [r0], 13
    je .end
    cmp [r0], 8
    je .backspace
    add r12, 1
    send r10, [r0]
    add r0, 1
    jmp .loop
.backspace:
    cmp r12, 0
    je .loop
    sub r12, 1
    mov r3, 0x1200
    push r2
    add r2, 0x00e0
    add r2, r12
    or r3, r2
    pop r2
    send r10, r3
    send r10, 0x0000
    send r10, r3
    sub r11, 1
    mov [r0], 0
    sub r0, 1
    jmp .loop
.end:
    pop r3
    mov [r0], 0
    add r12, 1
    ret

; Gets a zero-terminated string from the keyboard
; r0 points to input buffer
; r1 points to input buffer length
scans:
    push r12
    call gets
    mov [r1], r12
    pop r12

; Returns the length of a zero-terminated string (length includes zero)
; r0 points to string
; r1 is length
strlen:
    push r2
    mov r1, 0
.loop:
    mov r2, [r0]
    add r1, 1
    add r0, 1
    cmp r2, 0
    jne .loop
.end:
    pop r2
    ret

; Returns the length of a zero-terminated string (length includes zero)
; r0 points to string
; r1 points to length
strlen_ptr:
    push r2
.loop:
    mov r2, [r0]
    add [r1], 1
    add r0, 1
    cmp r2, 0
    jne .loop
.end:
    pop r2
    ret

; Returns the sum of the string
; r0 points to string
; r1 is the sum of the string
strsum:
    push r2
    mov r1, 0
.loop:
    mov r2, [r0]
    add r1, r2
    add r0, 1
    cmp r2, 0
    jne .loop
.end:
    pop r2
    ret

; Returns the sum of the string
; r0 points to string
; r1 is the sum of the string
strsum_ptr:
    push r2
    mov [r1], 0
.loop:
    mov r2, [r0]
    add [r1], r2
    add r0, 1
    cmp r2, 0
    jne .loop
.end:
    pop r2
    ret

;
; IGNORE ALL OF THIS IT'S JUST MY TESTING
;

; ; Frees a zero-terminated string from memory
; ; r0 - zero-terminated string to free
; ; doesn't have many advantages over just leaving it in memory
; freestr:
;     cmp [r0], 0
;     je .end
;     mov [r0], 0
;     jmp freestr
; .end:
;     ret

; ;
; ; Compares two strings
; ; Parameters:
; ;  r0 - string buffer 1
; ;  r1 - string buffer 1 length
; ;  r2 - string buffer 2
; ;  r3 - string buffer 2 length
; ;
; ; Too slow to actually use in development
; cmp_string:
;     push r4
;     push r5
;     push r8
;     mov r8, 0
;     mov r4, 0
;     mov r5, 0
;     jmp .loop
; .loop:
;     cmp r8, r1
;     jge .al0
;     mov r4, [r0+r8]
;     jmp .step2
; .al0:
;     mov r4, 0
; .step2:
;     cmp r8, r3
;     jge .bl0
;     mov r5, [r2+r8]
;     jmp .step3
; .bl0:
;     mov r5, 0
; .step3:
;     cmp r4, r5
;     jne .neq
;     add r8, 1
;     cmp r8, r1
;     je .eq
;     jmp .loop
; .eq:
;     mov r0, 1
;     jmp .done
; .neq:
;     mov r0, [r0+r8]
;     mov r2, [r2+r8]
;     mov r0, 0
;     jmp .done
; .done:
;     pop r8
;     pop r5
;     pop r4
;     ret

;
; YOU CAN STOP IGNORING HERE
;

; Writes zero-terminated strings to the terminal.
; r0 points to buffer to write from.
; r10 is terminal port address.
puts:
    push r1
    push r2
    mov r2, 0
.loop:
    mov r1, [r0]
    jz .exit
    add r0, 1
    add r11, 1
    cmp r1, 1
    je .newline
    send r10, r1
    mov r2, r11
    and r2, 31
    ;cmp r2, 0
    jnz .loop
.newline:
    send r10, 0x3000
    send r10, 0x12e0
    mov r11, 0
    jmp .loop
.exit:
    pop r2
    pop r1
    ret

; Strings
startup_message: dw "Welcome to TPT OS!", 1, 0
startup_message2: dw "Type help to see available commands.", 1, 0
newline: dw 1, 0
input_prompt: dw "> ", 0

compile: dw "Compiling commands...", 1, 0
unknown_cmd: dw "Unknown command '", 0
unknown_cmd2: dw "'.", 0

; Commands
echo: dw "echo", 0
echo_prompt: dw "Text to echo: ", 0
echo_sum: dw 0
help: dw "help", 0
help_msg: dw "echo     Prints text to the terminal.", 1, "help     Shows this message.", 1, "add      Adds two numbers.", 1, "sub      Subtracts two numbers.", 1, "mul      Multiplies two numbers.", "div      Divides two numbers.", 0 
help_sum: dw 0
add_cmd: dw "add", 0
add_msg: dw "a+b=", 0
add_sum: dw 0
sub_cmd: dw "sub", 0
sub_msg: dw "a-b=", 0
sub_sum: dw 0
div_cmd: dw "div", 0
div_msg: dw "a/b=", 0
div_msg2: dw "a%b=", 0
div_sum: dw 0
mul_cmd: dw "mul", 0
mul_msg: dw "a*b=", 0
mul_sum: dw 0

prompt_a: dw "a=", 0
prompt_b: dw "b=", 0

true: dw "true", 0

; Buffers
char_ptr: dw 0, 0
input_len: dw 0
input_sum: dw 0
; This must be the last thing defined in memory because otherwise
; it will overflow into other parts of the memory as it doesn't
; have a size limit.
input_buf: dw 0