bits 64
global _start

; constante général
LF   equ 10
NULL equ 0

STDIN  equ 0
STDOUT equ 1

SYS_READ  equ 0
SYS_WRITE equ 1
SYS_EXIT  equ 60

section .bss
	entre        resb 2
	taille_entre equ $ - entre

section .data
	texte        db 'Nombre de disque (entre 1 et 100) : ',LF,NULL
	taille_texte equ $ - texte

	msg_err db 'Sasie incorrect. Veuillez saisir un nombre entre 1 et 100 :',LF,NULL
	taille_err equ $ - msg_err

	res       db  0
	fleche    db  '->',NULL
	sautLigne db  LF,NULL

section .text
_start:
	; On demande a l'utilisateur combien disque il veut mettre
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, texte
	mov rdx, taille_texte
	syscall

saisie:
	mov rdx, taille_entre
	mov rsi, entre
	mov rdi, STDOUT
	mov rax, SYS_READ
	syscall

	lea rdi, entre

	xor rax,rax
	xor rcx,rcx

	call convertisseur

	mov rcx,rax ; nombre de disque
	mov rax, 1  ; tour de début
	mov rbx, 3  ; tour de fin

	call hanoi

fin:
	; Fin du programme
	mov rax, SYS_EXIT
	xor rdi, rdi ; code de retour 0
	syscall

convertisseur:
	movzx rdx, byte [rdi + rcx] ; on charge le caractère ASCII dans rdx

	; Cas ou le nombre est entre 0 et 9
	cmp rdx, LF                 ; On verifie si on a atteint la fin de la chaîne
	je fin_conversion           ; Si oui, on termine la conversion

	; Cas ou le nombre est entre 10 et 99
	cmp rdx, NULL
	je fin_conversion

	cmp rdx, '0'      ; on verifie si le caractere est bien un chiffre
	jb message_erreur ; sinon on le renvoie sur la saisie
	cmp rdx, '9'
	ja message_erreur

	sub rdx, '0'      ; on convertie le caractère ASCII en valeur numérique
	imul rax, rax, 10 ; on mutliplie le résultat actuel par 10
	add rax, rdx      ; on ajoute la nouvelle valeur numérique

	inc rcx ; on passe au caractere suivant au caractère suivant
	jmp convertisseur

fin_conversion:
	cmp rax, NULL     ; si l'utilisateur a entre 0 
	je message_erreur ; on le renvoie sur la saisie

	ret

message_erreur:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, msg_err
	mov rdx, taille_err
	syscall

	jmp saisie



affiche_chiffre:
	; La nombre afficher se trouve dans rax
	mov byte [res], al  ; On deplace le chiffre a afficher
	add byte [res], '0' ; et on le convertie en caractere

	; On affiche la tour
	mov rax, SYS_WRITE
	mov rsi, res
	mov rdi, STDOUT
	mov rdx, 1 ; taille de 1 car 1 chiffre
	syscall

	ret

affiche_fleche:
	; Affiche une fleche ->
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, fleche
	mov rdx, 3
	syscall

	ret

saut_De_Ligne:
	; On saute de ligne
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, sautLigne
	mov rdx, 1
	syscall

	ret

hanoi:
	cmp rcx, 1
	; cas de base
	jz cas_base
	; cas recursif
	jnz cas_rec

	ret

	cas_rec:
		dec rcx  ; nbDisque-1
		push rcx ; on sauvegarde les valeurs
		push rax 
		push rbx

		mov rdx, 6   ; La tour de fin devient la tour du 
		sub rdx, rbx ; milieu dans le prochaine appelle 
		sub rdx, rax ; recursif
		mov rbx, rdx

		call hanoi

		pop rbx ; recuperation des valeurs
		pop rax
		pop rcx

		push rcx
		push rax
		push rbx

		; Affichage de la tour du début
		call affiche_chiffre
		call affiche_fleche

		pop rbx
		pop rax
		pop rcx

		push rcx
		push rax
		push rbx

		mov rax, rbx

		; Affichage de la tour de fin
		call affiche_chiffre
		call saut_De_Ligne

		pop rbx
		pop rax
		pop rcx

		mov rdx, 6   ; La tour de debut devient la tour du 
		sub rdx, rbx ; milieu dans le prochaine appelle 
		sub rdx, rax ; recursif
		mov rax, rdx

		call hanoi

		ret

	cas_base:
		; Affichage de la tour du début
		call affiche_chiffre
		call affiche_fleche

		mov rax, rbx

		; Affichage de la tour de fin
		call affiche_chiffre
		call saut_De_Ligne

		ret