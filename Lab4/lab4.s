.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
BUFLEN = 1024


.data
format_number: .asciz "%d %f %lf"      # int float double
format_printf: .asciz "%f \n"          # double \n

.bss
.comm liczbaInt, 4    #int
.comm liczbaFloat, 4    #float
.comm liczbaDouble, 8    #double

.text
.global main

main:
#scanf(&liczbaX, "%d");
mov $0, %rax        # 
mov $format_number, %rdi # format w jakim ma zostać zapisany wynik w buforze
mov $liczbaInt, %rsi  # adres bufora do które zapisany ma zostać wynik
mov $liczbaFloat, %rdx 
mov $liczbaDouble, %rcx  

call scanf          # Wywołanie funkcji scanf z biblioteki stdio.h
e_test:

mov $2, %rax # 
mov $0, %rdi # 
mov $0, %rcx # 
mov liczbaInt(, %rcx, 4), %edi 
movss liczbaFloat, %xmm0 
movsd liczbaDouble, %xmm1
call f          #
//cvtps2pd %xmm3, %xmm3 


#
# Wyświetlenie wyniku z użyciem funkcji printf
#
mov $1, %rax 
mov $format_printf, %rdi 
sub $8, %rsp 
call printf  
add $8, %rsp 

e_test2:


e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall



