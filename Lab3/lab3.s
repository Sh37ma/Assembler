.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
BUFLEN = 1024

.bss
.comm liczba_z_klawiatury, 1024
.comm liczba_do_wyswietlenia, 1024

.text
.global main

main:
#_____________________________________________________________________

movq $SYSREAD, %rax	#wczytanie z klawiatury
movq $STDIN, %rdi
movq $liczba_z_klawiatury, %rsi
movq $BUFLEN, %rdx
syscall

movq %rax, %r8
movq $liczba_z_klawiatury, %r10
#push %r10

call e_do_fukcji

jmp e_po_funkcji

#______________________________________________________________________

e_do_fukcji:
movq $0, %rsi
movq $0, %rdi
movq $0, %r9
movq $0, %r11
movq $0, %r12

e_fukcja:
cmp %r8, %rsi
jge e_koniec_funkcji

movb (%r10, %rsi, 1), %al

cmp $'0', %al 
je e_jest_zero
jmp e_nie_jest_zero



e_jest_zero:
inc %rdi
inc %rsi
jmp e_fukcja



e_nie_jest_zero:
#obeny adres poczatka zer
movq %rsi, %r11
sub %rdi, %r11


#czy wiecej zer
cmp %r9, %rdi
jg e_wiecej_zer
jmp e_nie_wiecej_zer

e_wiecej_zer:
movq %rdi, %r9
movq %r11, %r12

movq $0, %rdi
inc %rsi
jmp e_fukcja

e_nie_wiecej_zer:
movq $0, %rdi
inc %rsi
jmp e_fukcja



e_koniec_funkcji:

cmp $0 ,%r9
jne e_koniec

movq $0, %rdi
movq $'-', liczba_do_wyswietlenia(, %rdi, 1)
inc %rdi
movq $'1', liczba_do_wyswietlenia(, %rdi, 1)
inc %rdi
movq $'\n', liczba_do_wyswietlenia(, %rdi, 1)
movq %rdi, %r10
inc %r10
jmp e_wyswietl




e_koniec:
add $'0', %r12
movq $0, %rdi
movq %r12, liczba_do_wyswietlenia(, %rdi, 1)
inc %rdi
movq $'\n', liczba_do_wyswietlenia(, %rdi, 1)
movq %rdi, %r10
inc %r10
e_wyswietl:
#wyswietlenie tekstu z buffora
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $liczba_do_wyswietlenia, %rsi
mov %r10, %rdx
syscall



ret

#______________________________________________________________________
e_po_funkcji:












e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

