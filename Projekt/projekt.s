.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
POCZATEK = 48
KONIEC = 55

basisText: .ascii "Podaj podstawe:\n"
basisText_len = .-basisText

powerText: .ascii "Podaj potege:\n"
powerText_len = .-powerText

niePoprawneDane: .ascii "Podane bledne dane\n"
niePoprawneDane_len = .-niePoprawneDane

resultText: .ascii "Wynik: "
resultText_len = .-resultText

BUFLEN = 1024

.bss
.comm basis, 1024
.comm power, 1024
.comm result, 1024

.text
.global main

main:
#_____________________________________________________________________________pobranie podstawy
mov $SYSWRITE, %rax             #wyswietlenie prosby o podanie podstawy
mov $STDOUT, %rdi
mov $basisText, %rsi
mov $basisText_len, %rdx
syscall

movq $SYSREAD, %rax	        #wczytanie z klawiatury podstawy
movq $STDIN, %rdi
movq $basis, %rsi
movq $BUFLEN, %rdx
syscall
jmp e_sprawdzPoprawnoscPodstawy

#_____________________________________________sprawdz poprawnosc
e_sprawdzPoprawnoscPodstawy:
dec %rax               #'\n'
movq %rax, %rbp         #dlugosc tekstu
movq %rax, %r8         #dlugosc tekstu
movq $0, %rdi           #licznik
jmp e_czyPodstawaOdZera

e_czyPodstawaOdZera:         #sprawdz czy jest to kod ascii >= zero

        movb basis(, %rdi, 1), %bh
        cmp $'0', %bh
        jge e_czyPodstawaDoDziewieciu
        jmp e_niePoprawne


e_czyPodstawaDoDziewieciu:              #sprawdz czy jest to kod ascii <= siedem
        cmp $'9', %bh
        jle e_poprawnaPodstawa
        jmp e_niePoprawne

e_poprawnaPodstawa:                             #znak poprawny, inkrementuj licznik i sprawdz czy wszystkie znaki
        inc %rdi
        cmp %rbp, %rdi
        jl e_czyPodstawaOdZera
        jmp e_potega_spr                #liczba wpisana została poprawnie


#____________________________________________________________________________pobranie podstawy
e_potega_spr:
mov $SYSWRITE, %rax                     #wyswietlenie prozby o podanie potegi
mov $STDOUT, %rdi
mov $powerText, %rsi
mov $powerText_len, %rdx
syscall

movq $SYSREAD, %rax	                #wczytanie z klawiatury potegi
movq $STDIN, %rdi
movq $power, %rsi
movq $BUFLEN, %rdx
syscall

#_____________________________________________sprawdz poprawnosc

e_sprawdzPoprawnoscPotegi:
dec %rax                #'\n'
movq %rax, %rbp         #dlugosc tekstu
movq %rax, %r10         #dlugosc tekstu
movq $0, %rdi           #licznik
jmp e_czyPotegaOdZera

e_czyPotegaOdZera:         #sprawdz czy jest to kod ascii >= zero

        movb power(, %rdi, 1), %bh
        cmp $'0', %bh
        jge e_czyPotegaDoDziewieciu
        jmp e_niePoprawne


e_czyPotegaDoDziewieciu:                #sprawdz czy jest to kod ascii <= siedem
        cmp $'9', %bh
        jle e_poprawnaPotega
        jmp e_niePoprawne

e_poprawnaPotega:                     #znak poprawny, inkrementuj licznik i sprawdz czy wszystkie znaki
        inc %rdi
        cmp %rbp, %rdi
        jl e_czyPotegaOdZera
        jmp e_koniecSprawdzania

e_niePoprawne:            #jeden ze znaków jest nie poprawny, następuje przerwanie
                                #niepoprawne dane-wyswietlenie komunikatu

        movq $SYSWRITE, %rax
        movq $STDOUT, %rdi
        movq $niePoprawneDane, %rsi
        movq $niePoprawneDane_len, %rdx
        syscall
	jmp e_exitProgramu

e_koniecSprawdzania:            #liczba wpisana została poprawnie
#_________________________zamiana podstawy na liczbe

movq %r8, %rdi
dec %rdi		#liczymy od 0

mov $1, %rsi		#8^0 czyli 1
mov $0, %r12		#pojemnik na wynik

e_mnozenie:

cmp $0, %rdi	
jl e_zakonczenieMnozenia
mov $0, %rax			#zerowanie rax
mov basis(, %rdi, 1), %al	#odczyt ostatniej liczby
sub $48, %al			#z ascii na liczbe

mul %rsi			#mnozenie rax przed aktualna potege 8-ki	
add %rax, %r12			#dodanie do naszego wyniku

mov %rsi, %rax			#zwiekszenie potegi *8
mov $10, %rbx
mul %rbx
mov %rax, %rsi

dec %rdi			#zmniejszamy licznik, by przejsc do kolejnego znaku
jmp e_mnozenie 

#______________
e_zakonczenieMnozenia:

#__________________________________________zamiana potegi na liczbe
movq %r10, %rdi
dec %rdi		#liczymy od 0

mov $1, %rsi		#8^0 czyli 1
mov $0, %r13		#pojemnik na wynik

e_mnozenie2:

cmp $0, %rdi	
jl e_zakonczenieMnozenia2
mov $0, %rax			#zerowanie rax
mov power(, %rdi, 1), %al	#odczyt ostatniej liczby
sub $48, %al			#z ascii na liczbe

mul %rsi			#mnozenie rax przed aktualna potege 8-ki	
add %rax, %r13			#dodanie do naszego wyniku

mov %rsi, %rax			#zwiekszenie potegi *8
mov $10, %rbx
mul %rbx
mov %rax, %rsi

dec %rdi			#zmniejszamy licznik, by przejsc do kolejnego znaku
jmp e_mnozenie2

#______________
e_zakonczenieMnozenia2:

e_algorymt:

movq $1, %rdi                   #wynik
                                # %r12 podstawa
petla:
movq %r13, %rbx                 #potega
and $0b1, %rbx

cmp $1, %rbx
je e_mulResult
jmp e_mulBasis


e_mulResult:

movq %rdi, %rax
mul %r12
movq %rax, %rdi


e_mulBasis:
movq %r12, %rax
mul %r12
movq %rax, %r12
		

shr $1, %r13

cmp $0, %r13
jg petla




#______________________________________________________________________________________________
e_konwertujWynik:			#zapis liczby z rejestru do kodu ascii w buforze U10 na U6

mov %rdi, %rax		#przygotowanie do dzielenia
mov $10, %rbx		
movq $0, %rsi
jmp e_dzielenie

#________________
e_dzielenie:			#dzielenie rax przez rbx, wynik do rax a reszta do rdx
mov $0, %rdx
div %rbx
add $'0', %rdx		        #dodanie kodu zera by było ascii
push %rdx
inc %rsi

cmp $0, %rax
jne e_dzielenie

#_________________________________________
movq $0, %rbx
mov $0, %rcx

e_odwracanie:
pop %rbx
movb %bl, result(, %rcx, 1)
inc %rcx
dec %rsi

cmp $0, %rsi
jg e_odwracanie
#_________________________________________

movb $'\n', result(, %rcx, 1)


e_wyswietl_wynik:
mov $SYSWRITE, %rax             #wyswietlenie napisu "wynik"
mov $STDOUT, %rdi
mov $resultText, %rsi
mov $resultText_len, %rdx
syscall

mov $SYSWRITE, %rax             #wyswietlenie prozby o podanie potegi
mov $STDOUT, %rdi
mov $result, %rsi
mov $BUFLEN, %rdx
syscall
jmp e_exitProgramu

e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

