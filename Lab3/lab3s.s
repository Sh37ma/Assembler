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

push %rbx	#dodanie na stos
push %rcx

call e_funkcja
jmp e_po_funkcji

#______________________________________________________________________

e_funkcja:
movq %rsp, %rbp

e_test:
movq $0, %rbx #zerowanie dla testowania porpawnosci pobrania ze stosu
movq $0, %rcx

movq 8(%rbp), %rcx
movq 16(%rbp), %rbx

movq %rcx, %rax     #działania
movq $5, %rdx
mul %rdx
add $7, %rax

movq %rax, %rcx     #zapisanie wyniku
dec %rbx

push %rbx	#dodanie na stos
push %rcx


cmp $0, %rbx
jle e_ret
jmp e_call

e_call:
call e_funkcja

e_ret:
add $16, %rsp
ret

#______________________________________________________________________



e_po_funkcji:
sub $168, %rsp
pop %rcx

e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

