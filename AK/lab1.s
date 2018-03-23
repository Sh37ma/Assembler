.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
POCZATEK = 48
KONIEC = 55

tekstN: .ascii "Niepoprawne dane\n"
tekstN_len = .-tekstN

tekstP: .ascii "Poprawne dane\n"
tekstP_len = .-tekstP

BUFLEN = 512

.bss
.comm textin, 512
.comm textout, 512

.text
.global main

main:

movq $SYSREAD, %rax	#wczytanie z klawiatury
movq $STDIN, %rdi
movq $textin, %rsi
movq $BUFLEN, %rdx
syscall

dec %rax		#'\n'
movq %rax, %rcx		#kopiuj dlugosc tekstu 
movq $0, %rdi		#licznik

jmp sprawdzPoczatek

sprawdzPoczatek:	 #sprawdz czy jest to kod ascii >= zero

	movb textin(, %rdi, 1), %bh
	cmp $POCZATEK, %bh
	jge sprawdzKoniec
        jmp koniecNiePoprawny


sprawdzKoniec:		 #sprawdz czy jest to kod ascii <= siedem
	cmp $KONIEC, %bh
	jle poprawne
	jmp koniecNiePoprawny

poprawne:		 #znak poprawny, inkrementuj licznik i sprawdz czy wszystkie znaki
	inc %rdi
	cmp %rax, %rdi
	jl sprawdzPoczatek
	
koniecPoprawny:    	  #poprawne dane-wyswietlenie komunikatu     

        movq $SYSWRITE, %rax
        movq $STDOUT, %rdi
        movq $tekstP, %rsi
        movq $tekstP_len, %rdx
        syscall
	jmp koniec

koniecNiePoprawny: #jeden ze znaków jest nie poprawny, następuje przerwanie
	     #niepoprawne dane-wyswietlenie komunikatu

	movq $SYSWRITE, %rax
	movq $STDOUT, %rdi
	movq $tekstN, %rsi
	movq $tekstN_len, %rdx
	syscall

koniec:	     #zastosowany w celu unikniecia podwojnych komunikatow
	

#konwersja z U8 na U10
#	movq $0, %rdi	#licznik
#	movq $0, %rdx	#pojemnik na nowa liczbe
#	dec %rcx
#	jmp petla
#petla:
#	movq $0, %rsi	#licznik
	
#	movq textin(, %rcx, 1), %rax
	
#	mnozenie:
	
#	cmp %rdi, %rsi
#	jge koniec2
#	mul $8
#	inc %rsi
#	jmp mnozenie




movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

