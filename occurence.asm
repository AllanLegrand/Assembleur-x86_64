bits 64
global _start

NULL equ 0
LF equ 10

STDIN  equ 0
STDOUT equ 1

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

section .bss
	tab resb 128
	texte resb 128

section .data
	caractere db " ", NULL
	deux_points db " : ", NULL
	saut_de_ligne db LF, NULL

	erreurAscii db "Erreur : caractère non-ASCII", LF
	terreurAscii equ $ - erreurAscii

	chiffre times 3 db NULL, NULL ; un chiffre ne peut pas dépasser 3 caractères (max=255)
	taille_chiffre equ $ - chiffre
	
section .text

_start:
	mov rax, SYS_READ ; Appel système read
	mov rdi, STDIN ; Descripteur de fichier 0 (stdin)
	mov rsi, texte ; Adresse du buffer
	mov rdx, 127 ; Taille du buffer

	syscall

	mov rcx, 0 ; Taille du texte
	call occurence

	mov byte[tab+LF], NULL ; Enlever le saut de ligne

	xor rcx, rcx ; Initialiser le compteur
	call affiche

	.exit:
		mov rax, SYS_EXIT
		xor rdi, rdi
		syscall

occurence:
	movzx rdx, byte [rsi + rcx] ; Mettre le caractère dans rdx

	cmp rdx, 128 ; Vérifier si le caractère est supérieur à 127
	jge .erreurAscii ; Si oui, terminer

	cmp rdx, NULL ; Vérifier si le caractère est nul
	je .fin ; Si oui, terminer

	lea rdi, [tab+rdx] ; Adresse de la case du tableau
	mov al, [rdi]      ; Charger la valeur de la case dans AL
	inc al             ; Incrémenter la valeur de AL
	mov [rdi], al      ; Écrire la valeur de nouveau dans la case du tableau

	inc rcx ; Incrémenter le compteur

	cmp rcx, 128 ; Vérifier si le compteur est égal à 127
	jne occurence ; Si non, boucler

	.fin:
		ret

	.erreurAscii:
		mov rsi, erreurAscii ; Adresse du texte
		mov rdx, terreurAscii ; Taille du texte
		call ecrire ; Écrire le texte
		jmp _start.exit ; Terminer

affiche:
	movzx rax, byte [tab+rcx] ; Mettre le caractère dans rdx

	cmp rax, NULL ; Vérifier si le caractère est nul
	je .boucle ; Si oui, terminer

	push rcx ; Sauvegarder le compteur

	mov byte [caractere], cl ; Mettre le caractere dans rsi
	mov rsi, caractere ; Adresse du caractère
	mov rdx, 1 ; Taille du caractère
	call ecrire ; Écrire le caractère

	mov rsi, deux_points ; Adresse du texte
	mov rdx, 3 ; Taille du texte
	call ecrire ; Écrire le texte

	pop rcx ; Restaurer le compteur
	push rcx ; Sauvegarder le compteur

	movzx rax, byte [tab+rcx] ; Mettre la valeur dans RAX
	lea rdi, [chiffre] ; Adresse du tableau de chiffres
	add rdi, taille_chiffre ; Pointeur de destination
	mov byte [rdi], NULL ; Terminer la chaîne

	mov rcx, 10 ; Base 10
	call convertisseur ; Convertir le nombre en chaîne de caractères

	mov rsi, rdi            ; Adresse de la chaîne
	mov rdx, taille_chiffre ; Taille de la chaîne
	call ecrire ; Écrire la chaîne

	call nettoyage ; Nettoyer la chaine chiffre

	mov rsi, saut_de_ligne ; Adresse du texte
	mov rdx, 1 ; Taille du texte
	call ecrire ; Écrire le texte

	pop rcx ; Restaurer le compteur

	.boucle:
		inc rcx ; Incrémenter le compteur
		cmp rcx, 128 ; Vérifier si le compteur est égal à 128
		je .fin ; Si oui, terminer
		jmp affiche ; Boucler sur le texte
	.fin:
		ret

ecrire:
	mov rax, SYS_WRITE ; Appel système write
	mov rdi, STDOUT ; Descripteur de fichier 1 (stdout)

	syscall

	ret

convertisseur:
	xor rdx, rdx      ; Remettre le registre de division à zéro
	div rcx           ; Diviser RAX par 10, quotient dans RAX, reste dans RDX
	add dl, '0'       ; Convertir le reste en caractère
	dec rdi           ; Décrémenter le pointeur de destination
	mov [rdi], dl     ; Stocker le caractère dans la chaîne

	test rax, rax     ; Vérifier si RAX est nul
	jnz convertisseur ; Si non, continuez la boucle

	ret

nettoyage:
	lea rdi, [chiffre]
	mov rcx, taille_chiffre

	.boucle:
		mov byte [rdi], NULL
		inc rdi
		loop .boucle
	ret