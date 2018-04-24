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
movq $7, %rbx  #licznik


call e_funkcja
jmp e_po_funkcji

#______________________________________________________________________

e_funkcja:


movq %rcx, %rax     #działania
movq $5, %rdx
mul %rdx
add $7, %rax

movq %rax, %rcx     #zapisanie wyniku
dec %rbx


cmp $0, %rbx
jle e_ret
jmp e_call

e_call:
call e_funkcja

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

