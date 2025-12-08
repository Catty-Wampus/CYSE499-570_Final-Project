[BITS 32]

global _start
extern kernel_main

; Segment Selectors
LONG_MODE_CODE_SEGMENT equ 0x08
LONG_MODE_DATA_SEGMENT equ 0x10 

_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; 32 bit stack and base pointers are initialized
    ; These registers will later be extended for 64 bit mode
    mov ebp, 0x00200000
    mov esp, ebp

    ; Load the global descriptor table (GDT)
    lgdt [gdt_descriptor]

    ; Enable Physical Address Extension by setting bit 5
    ; This is what allows the kernel to utilize more than 4 GB of memory
    ; This also allows us to switch the paging scheme from two levels in 32 bit to four levels in 64 bit
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Setup the page tables
    mov eax, PML4_Table
    mov cr3, eax

    ; This section is what enables long mode 
    ; Setting bit 8, also known as the long mode enable (LME) bit, tells processor to enter long mode
    mov ecx, 0xC0000080 
    rdmsr               
    or eax, 0x100  
    wrmsr   

    ; Enable paging by setting the paging bit 31
    ; However, instructions still in 32 bit until jmp
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; This line is performing a far jump to 64 bit, or long mode
    ; Processor loads code segment with LONG_MODE_CODE_SEGMENT, which is 0x18
    ; Processor then loads instruction pointer register with the long_mode_entry
    jmp LONG_MODE_CODE_SEGMENT:long_mode_entry

[BITS 64]
long_mode_entry:

    ; Segment registers are not initialized with long mode information
    mov ax, LONG_MODE_DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; This is where the stack and pointers are changed from 32 bit to 64 bit
    ; This is why the registers change from e to r
    mov rsp, 0x00200000
    mov rbp, rsp
    
    ; This is where the main() function in kernel.c is called
    jmp kernel_main

    jmp $


; Global descriptor table (GDT)
align 8 
gdt: 
    ; Null descriptor (required)
    dq 0x0000000000000000 

    ; 64 bit code segment descriptor    
    ; This 16 bit value stores maximum offset for the segment
    dw 0x0000 
    
    ; This defines the starting address for the segment
    dw 0x0000 
    db 0x00
    
    ; Binary form of access byte is 10011010
    db 0x9A
    
    ; Binary form of flag byte is 10100000
    db 0xA0
    
    ; Last part of the base address
    db 0x00

    ; 64 bit data segment descriptor
    ; This 16 bit value stores maximum offset for the segment
    dw 0x0000
    
    ; This defines the starting address for the segment
    dw 0x0000
    db 0x00
    
    ; Binary form of access byte is 10010010
    db 0x92
    
    ; Flag byte
    ; Bit 5, which is long mode bit, should be set to zero for data segment
    db 0x00
    
    ; Remainder of base address
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt -1 ; Size of GDT minus 1
    dd gdt              ; Base address of GDT

align 4096

; Page map level 4
PML4_Table:

    ; The first entry points to page directory pointer table
    ; 0x03 sets status flag for bit 0 (Present) and bit 1 (Read/Write)
    dq PDPT_TABLE + 0x03
    
    ; The other entries are set to null
    times 511 dq 0 

align 4096

; Page Directory Pointer Table
PDPT_TABLE:

    ; The first entry points to page directory
    ; 0x03 sets status flag for bit 0 (Present) and bit 1 (Read/Write)
    dq PD_Table + 0x03
    
    ; The other entries are set to null
    times 511 dq 0 

align 4096

; Page Directory
PD_Table:

    ; The first entry points to page table
    ; 0x03 sets status flag for bit 0 (Present) and bit 1 (Read/Write)
    dq PT_Table + 0x03
    
    ; All other entries set to null
    times 511 dq 0
    
align 4096
PT_Table:

    ; This is the starting address in the page table
    %assign addr 0x0000000
    
    ; This is the number of pages
    %rep 512
    
        ; Address is incremented by 4096 for the next page
        dq addr + 0x03
        %assign addr addr + 0x1000    
    %endrep
