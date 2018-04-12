.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
SYSOPEN = 2
SYSCLOSE = 3
FREAD = 0
FWRITE = 1
plik: .ascii "plik.txt\0" # Nazwa pliku
plik2: .ascii "plik2.txt\0" # Nazwa pliku 
plikDoZapisu: .ascii "plik3.txt\0" # Nazwa pliku
BUFLEN = 1024

.bss
.comm liczba_z_pliku, 1024
.comm liczba_z_pliku_2, 1024
.comm endian, 1024
.comm endian_2, 1024
.comm liczba_po_dodaniu, 1024
.comm liczba_do_zapisu, 1024

.text
.global main

main:
#_____________________________________________________________________plik1
movq $SYSOPEN, %rax  	#numer wywołania systemowego
movq $plik, %rdi 	#nazwa pliku
movq $FREAD, %rsi   	#sposób otwarcia
movq $0, %rdx     	#prawa dostępu
syscall           	
movq %rax, %rbp     	#identyfikator otwartego pliku
 

# Odczyt z pliku 1 do bufora całej liczby
mov $SYSREAD, %rax
mov %rbp, %rdi
mov $liczba_z_pliku, %rsi
mov $1024, %rdx
syscall
sub $2, %rax            #'\n'
mov %rax, %r8 # Zapisanie ilości odczytanych bajtów do rejestru R8 

# Zamknij plik 1
mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
mov %rbp, %rdi       # Drugi parametr - ID otwartego pliku
syscall             # Wywołanie przerwania


#_____________________________________________________________________plik_2
movq $SYSOPEN, %rax     #numer wywołania systemowego
movq $plik2, %rdi        #nazwa pliku
movq $FREAD, %rsi       #sposób otwarcia
movq $0, %rdx           #prawa dostępu
syscall
movq %rax, %rbp         #identyfikator otwartego pliku


# Odczyt z pliku 2 do bufora całej liczby
mov $SYSREAD, %rax
mov %rbp, %rdi
mov $liczba_z_pliku_2, %rsi
mov $1024, %rdx
syscall
sub $2, %rax            #'\n'
mov %rax, %r10 # Zapisanie ilości odczytanych bajtów do rejestru R10

# Zamknij plik 2
mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
mov %rbp, %rdi       # Drugi parametr - ID otwartego pliku
syscall             # Wywołanie przerwania

#_____________________________________________________________

movq %r8, %rbx

movq $0, %rcx
movq $0, %rdx
movq $0, %rsi

e_czytaj_4_cyfry:	#__________________________________

movb liczba_z_pliku(, %rbx, 1), %cl
sub $48, %cl				#dekodowanie z ASCII
dec %rbx

movb liczba_z_pliku(, %rbx, 1), %ch
sub $48, %ch
dec %rbx

movb liczba_z_pliku(, %rbx, 1), %dl
sub $48, %dl                            #dekodowanie z ASCII
dec %rbx

movb liczba_z_pliku(, %rbx, 1), %dh
sub $48, %dh
dec %rbx

#%cl przesuniety o 2^0 czyli wcale
shl $2, %ch
shl $4, %dl
shl $6, %dh


or %cl, %ch
or %ch, %dl
or %dl, %dh

movb %dh, endian(, %rsi, 1)
inc %rsi

cmp $0, %rbx
jg e_czytaj_4_cyfry
#_________________________________


movq %r10, %rbx

movq $0, %rcx
movq $0, %rdx
movq $0, %rsi

e_czytaj_4_cyfry_2:       #__________________________________

movb liczba_z_pliku_2(, %rbx, 1), %cl
sub $48, %cl                            #dekodowanie z ASCII
dec %rbx

movb liczba_z_pliku_2(, %rbx, 1), %ch
sub $48, %ch
dec %rbx

movb liczba_z_pliku_2(, %rbx, 1), %dl
sub $48, %dl                            #dekodowanie z ASCII
dec %rbx

movb liczba_z_pliku_2(, %rbx, 1), %dh
sub $48, %dh
dec %rbx

#%cl przesuniety o 2^0 czyli wcale
shl $2, %ch
shl $4, %dl
shl $6, %dh


or %cl, %ch
or %ch, %dl
or %dl, %dh

movb %dh, endian_2(, %rsi, 1)
inc %rsi

cmp $0, %rbx
jg e_czytaj_4_cyfry_2
#_________________________________ Dodawanie

clc
pushfq
movq $0, %rdi

e_dodaj_liczby:
movb endian(, %rdi, 1), %al
movb endian_2(, %rdi, 1), %bl
popfq

adc %al, %bl
pushfq
movb %bl, liczba_po_dodaniu(, %rdi, 1)
inc %rdi

cmp $1024, %rdi
jle e_dodaj_liczby

#______________________________________________________ Zmiana na 16-tkowy
mov $512, %rdx  # Liczniki do pętli
mov $1025, %r9

e_zamiana_na_16:
mov liczba_po_dodaniu(, %rdx, 1), %al # Odczyt wartości
mov %al, %bl # Skopiowanie wartości do rejestru AL
mov %al, %cl # -||- CL
		# "Rozdzielenie" liczby na dwie 4 bitowe części.
		# W rejestrze BL znajdą się 4 najmniej znaczące bity.
		# W rejestrze CL 4 kolejne.
shr $4, %cl
and $0b1111, %bl
and $0b1111, %cl
add $'0', %bl # Dodanie kodów ASCII '0' do każdej z części
add $'0', %cl

# Jeśli wartość w %bl wynosi przynajmniej 10 do dadajemy warosci 7 by otrzymac odpowiedni znak ascii (A-F)
cmp $'9', %bl
jle e_kontynuuj
add $7, %bl

e_kontynuuj:
# Jak wyżej, ale dla %cl
cmp $'9', %cl
jle e_zapisz_wynik
add $7, %cl

e_zapisz_wynik:
# Zapis wartości do bufora wynikowego
# i zmniejszenie licznika pozycji w tym buforze.
mov %bl, liczba_do_zapisu(, %r9, 1)
dec %r9
mov %cl, liczba_do_zapisu(, %r9, 1)
dec %r9

# Zmniejszenie licznika pętli by wykonac dla wszystkich pozycji liczb
dec %rdx
cmp $0, %rdx
jge e_zamiana_na_16


#_____________________________________________________________________________
# Otwarcie pliku do zapisu
mov $SYSOPEN, %rax  # Pierwszy parametr - numer wywołania systemowego
mov $plikDoZapisu, %rdi # Drugi parametr - nazwa pliku
mov $FWRITE, %rsi   # Trzeci parametr - sposób otwarcia
mov $0644, %rdx     # Czwarty parametr - prawa dostępu
syscall             # Wywołanie przerwania
mov %rax, %r8       # Przeniesienia wartości zwróconej przez wywołanie
                    # - identyfikatora otwartego pliku, do rejestru R8
 
# Zapis zawartości bufora do pliku
mov $SYSWRITE, %rax
mov %r8, %rdi       # Zamiast STDOUT, podajemy id otwartego pliku
mov $liczba_do_zapisu, %rsi
mov $1024, %rdx
syscall
 
# Zamknięcie pliku
mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
mov %r8, %rdi       # Drugi parametr - ID otwartego pliku
syscall             


e_exitProgramu:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

