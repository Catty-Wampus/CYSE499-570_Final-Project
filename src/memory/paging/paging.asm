[BITS 32]

section .asm

global paging_load_directory

global paging_invalidate_tlb_entry

; void paging_load_directory(uintptr_t* directory)
paging_load_directory:
    mov rax, rdi  ; Load the first argument (directory) into RAX
    mov cr3, rax  ; Load the page tables PML4 into CR3
    ret

; void paging_invalidate_tlb_entry(void* addr)
paging_invalidate_tlb_entry:
    invlpg [rdi]
    ret

; Old 32 bit version
; global enable_paging

; paging_load_directory:
    ; push ebp
    ; mov ebp, esp
    ; mov eax, [ebp+8]
    ; mov cr3, eax
    ; pop ebp
    ; ret

; enable_paging:
    ; push ebp
    ; mov ebp, esp
    ; mov eax, cr0
    ; or eax, 0x80000000
    ; mov cr0, eax
    ; pop ebp
    ; ret
