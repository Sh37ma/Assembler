.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
BUFLEN = 1024

.bss
.comm liczba_do_wyswietlenia, 1024

.text
.global main

main:
#_____________________________________________________________________

movq $-2, %rcx   #wynik
movq $2, %rbx  #licznik
#push %r10

call e_do_fukcji
jmp e_po_funkcji

#______________________________________________________________________

e_do_fukcji:

e_fukcja:
#pop %rbx    #argument
#pop %rcx    #wynik


movq %rcx, %rax     #działania
movq $7, %rdx
mul %rdx
add $5, %rax

movq %rax, %rcx     #przygotownie wartosci na stos
dec %rbx


cmp $0, %rbx
jle e_ret
jmp e_call

e_call:
#push %rcx
#push %rbx
call e_do_fukcji
e_ret:
ret

#______________________________________________________________________
e_po_funkcji:




add $'0', %rcx
movq $0, %rdi
movq %rcx, liczba_do_wyswietlenia(, %rdi, 1)
inc %rdi
movq $'\n', liczba_do_wyswietlenia(, %rdi, 1)

#wyswietlenie tekstu z buffora
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $liczba_do_wyswietlenia, %rsi
mov %r10, %rdx
syscall








e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

