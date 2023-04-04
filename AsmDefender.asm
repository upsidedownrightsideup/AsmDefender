section .data

AES_key: db 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c
AES_key_size: equ $-AES_key

AES_round_const: db 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36

section .text

global _start

_start:
    ; apply SubBytes operation to state
    mov eax, 0
    .sub_bytes_loop:
    cmp eax, 16
    jge .exit
    mov bl, [eax+state]
    mov bh, 0
    mov bl, [S_box+ebx]
    mov [eax+state], bl
    inc eax
    jmp .sub_bytes_loop

    ; apply ShiftRows operation to state
    mov eax, 0
    mov ebx, 4
    mov ecx, 8
    mov edx, 12
    mov esi, [eax+state]
    mov edi, [ebx+state]
    xchg esi, edi
    mov [eax+state], esi
    mov [ebx+state], edi
    mov esi, [ecx+state]
    mov edi, [edx+state]
    xchg esi, edi
    mov [ecx+state], esi
    mov [edx+state], edi

    ; apply MixColumns operation to state
    mov eax, 0
    .mix_columns_loop:
    cmp eax, 16
    jge .exit
    mov edx, eax
    and edx, 3
    mov ecx, eax
    sub ecx, edx
    mov edi, [eax+state]
    mov esi, [ecx+state]
    shl esi, 1
    xor edi, esi
    mov esi, [eax+4+state]
    xor edi, esi
    mov esi, [eax+8+state]
    xor edi, esi
    mov esi, [eax+12+state]
    xor edi, esi
    mov [eax+state], edi
    inc eax
    jmp .mix_columns_loop

    ; apply AddRoundKey operation to state
    mov eax, 0
    .add_round_key_loop:
    cmp eax, 16
    jge .exit
    movzx ebx, byte [eax+AES_round_const+round]
    xor byte [eax+state], ebx
    inc eax
    jmp .add_round_key_loop

.exit:
    ; save state and round
    mov eax, state
    mov edx, round
    mov [output_state], eax
    mov [output_round], edx

    ; terminate program
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data

state: db 0x32, 0x88, 0x31, 0xe0, 0x43, 0x5a, 0x31, 0x37, 0xf6, 0x30, 0x98, 0x07, 0xa8, 0x8d, 0xa2
