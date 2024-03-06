# Assembleur-x86_64

## 1. Prérequis

### 1.1 Obligatoire
- Système d'exploitation Linux
- Processeur avec l'architechture x86_64
### 1.2 Optionelle
- Le paquet nasm
```bash
sudo apt install nasm
```
- Le paquet binutils (nécéssaire pour la commande ld, cependant, toutes autres editeur de lien fera l'affaire)
```bash
sudo apt install binutils
```
## 2. Structure

### 2.1 Section .data
La section .data contient les définitions des variables initialisées à une ou plusieurs valeurs spécifiées.

Déclaration :
```asm
.section .data
	[nom de la variable] [directives de définition de données] [valeur]
	[nom de la variable] EQU [valeur] ; constante (64 bits)
```

Directives de définition de données :
| Nom                  | Symbole | Taille  |
|----------------------|---------|---------|
| Define byte          | DB      | 8 bits  |
| Define word          | DW      | 16 bits |
| Define doubleword    | DD      | 32 bits |
| Define quadword      | DQ      | 64 bits |
| Define extended word | DT      | 80 bits |

Exemple :
```asm
.section .data
	SAUT_LIGNE EQU 10
	msg DB 'Bon', 106, 'our', SAUT_LIGNE, 0 ; 106 correspond a la valeur ascii de j, SAUT_LIGNE(10) au saut de ligne et 0 a la valeur NULL utilisé pour fermer une chaîne
	lst DB 1, 4, 3, 5, 3
	PI DD 3.14
	PI DQ 3.141592653589793
	taille EQU $ - msg ; taille du message (8, on ne compte pas le 0)
```

### 2.2 Section .bss
La section .bss contient les déﬁnitions des variables non-initialisées, c’est à dire uniquement allouées en mémoire.

Déclaration :
```asm
.section .bss
	[nom de la variable] [directives de réservation de données] [taille]
```

Directives de réservation de données :
| Nom                   | Symbole | Taille  |
|-----------------------|---------|---------|
| Reserve byte          | resb    | 8 bits  |
| Reserve word          | resw    | 16 bits |
| Reserve doubleword    | resd    | 32 bits |
| Reserve quadword      | resq    | 64 bits |
| Reserve extended word | rest    | 80 bits |

Exemple :
```asm
.section .bss
	caractere resb 1
	tabMesure resd 100        ; tableau de 100 doubleword
	tabMesurePrecise resq 100 ; tableau de 100 quadword
```

### 2.3 Section .text
La section .text contient le code exécuté par un programme.  

Les directives de définition et reservation de données peuvent aussi servir comme spécificateur de taille.

Exemple :
```asm
SYS_EXIT equ 60 ; constante de l'appel système exit

.section .text
	global _start ; spécifie qu'on commence a _start
	_start:
		; On doit toujours appeler l'appel système exit a la fin d'un programme
		XOR RDI, RDI ; code de retour (0)
		MOV RAX, SYS_EXIT
		SYSCALL ; appel système
```

Déclaration :
```asm
SYS_EXIT equ 60 ; constante de l'appel système exit

.section .data
	msg DB 'Bon', 106, 'our', SAUT_LIGNE, 0
.section .text
	global _start ; spécifie qu'on commence a _start
	routine:
		; instruction
		RET ; retour (on reviens a la routine appelante)
	_start:
		; instruction
		MOV RAX, BYTE[msg+1] ; on bouge la valeur du deuxieme byte de msg (o) dans RAX
		MOV RDI, msg ; on bouge l'adresse de msg dans RDI

		; On doit toujours appeler l'appel système exit a la fin d'un programme
		XOR RDI, RDI ; code de retour (0)
		MOV RAX, SYS_EXIT
		SYSCALL ; appel système
```
## 3. Registre (register)

### 3.1 Registres généraux
| Nom des registres  | 64 bits | 32 bits | 16 bits | 8 bits | Description                                                                                                              |
|--------------------|---------|---------|---------|--------|--------------------------------------------------------------------------------------------------------------------------|
| Accumulateur       | RAX     | EAX     | AH      | AL     | Utilisé comme accumulateur, stockage du retour d’une routine, d’un appel système et résultat d'opérations arithmétiques. |
| Base               | RBX     | EBX     | BH      | BL     | Utilisé comme registre de base pour le stockage d'adresses mémoire.                                                      |
| Compteur           | RCX     | ECX     | CH      | CL     | Utilisé dans les boucles et pour certaines opérations spécifiques.                                                       |
| Données            | RDX     | EDX     | DH      | DL     | Utilisé dans les opérations arithmétiques et pour stocker des données temporaires.                                       |
| Source Index       | RSI     | ESI     | SI      | SIL    | Utilisé comme pointeur source pour les opérations de chaîne.                                                             |
| Destionation Index | RDI     | EDI     | DI      | DIL    | Utilisé comme pointeur destination pour les opérations de chaîne.                                                        |
| Base Pointer       | RBP     | EBP     | BP      | BPL    | Utilisé comme pointeur de base pour accéder aux données sur la pile.                                                     |
| Stack Pointer      | RSP     | ESP     | SP      | SPL    | Pointeur de pile, utilisé pour suivre l'emplacement actuel sur la pile.                                                  |
| R8                 | R8      | R8D     | R8W     | R8B    |                                                                                                                          |
| R9                 | R9      | R9D     | R9W     | R9B    |                                                                                                                          |
| R10                | R10     | R10D    | R10W    | R10B   |                                                                                                                          |
| R11                | R11     | R11D    | R11W    | R11B   |                                                                                                                          |
| R12                | R12     | R12D    | R12W    | R12B   |                                                                                                                          |
| R13                | R13     | R13D    | R13W    | R13B   |                                                                                                                          |
| R14                | R14     | R14D    | R14W    | R14B   |                                                                                                                          |
| R15                | R15     | R15D    | R15W    | R15B   |                                                                                                                          |

### 3.2 Registres de controle
| Nom des registres   | 64 bits | 32 bits | Description                                                                                                        |
|---------------------|---------|---------|--------------------------------------------------------------------------------------------------------------------|
| Instruction Pointer | RIP     |         | Contient l'adresse mémoire de l'instruction suivante à exécuter.                                                   |
| Registre d'état     |         | EFLAGS  | Contient des indicateurs de statut, tels que les indicateurs de zéro, de signe, de retenue, etc (Voir ci-dessous). |

Indicateur de statut et de controle du regsitre EFLAGS :

| Bit   | Nom                              | Symbole | Description                                                                                                              |
|-------|----------------------------------|---------|--------------------------------------------------------------------------------------------------------------------------|
| 0     | Carry Flag                       | CF      | Indique une retenue ou un emprunt lors des opérations arithmétiques.                                                     |
| 1     | Parity Flag                      | PF      | Indique la parité (pair ou impair) du résultat d'une opération.                                                          |
| 2     | Adjust Flag                      | AF      | Utilisé principalement dans les opérations BCD (Binary-Coded Decimal) pour indiquer un ajustement nécessaire.            |
| 3     | Zero Flag                        | ZF      | Indique si le résultat d'une opération est zéro.                                                                         |
| 4     | Sign Flag                        | SF      | Indique le signe du résultat d'une opération (positif ou négatif).                                                       |
| 5     | Trap Flag                        | TF      | Permet un débogage en mode trace.                                                                                        |
| 6     | Interrupt Enable Flag            | IF      | Permet ou désactive les interruptions matérielles.                                                                       |
| 7     | Direction Flag                   | DF      | Utilisé dans les opérations de chaîne pour spécifier la direction de la copie des données (vers le haut ou vers le bas). |
| 8     | Overflow Flag                    | OF      | Indique un dépassement de capacité lors des opérations arithmétiques.                                                    |
| 9-10  | Reserved, Virtual-8086 Mode Flag | RF      | Réservés, utilisés comme RF (Resume Flag) sur certaines architectures, et en mode virtuel-8086.                          |
| 11    | Nested Task Flag                 | NT      | Indique si une tâche est une tâche imbriquée (utile pour le multitâche).                                                 |
| 12    | Reserved                         |         | Réservé, sans utilisation spécifiée.                                                                                     |
| 13    | Resume Flag                      | RF      | Réservé, utilisé comme drapeau de reprise après une interruption matérielle.                                             |
| 14    | Virtual-8086 Mode Flag           | VM      | Indique si le processeur est en mode virtuel-8086.                                                                       |
| 15    | Alignment Check Flag             | AC      | Utilisé pour générer des exceptions en cas de non-alignement mémoire.                                                    |
| 16    | Virtual Interrupt Flag           | VIF     | Utilisé en mode virtuel-8086 pour émuler les interruptions.                                                              |
| 17    | Virtual Interrupt Pending Flag   | VIP     | Indique la présence d'interruptions en mode virtuel-8086.                                                                |
| 18    | Identification Flag              | ID      | Indique la disponibilité de l'instruction CPUID.                                                                         |
| 19-31 | Reserved                         |         | Réservés, sans utilisation spécifiée.                                                                                    |

### 3.3 Registres de segment
| Nom des registres | 16 bits | Description                                                   |
|-------------------|---------|---------------------------------------------------------------|
| Code Segment      | CS      | Indique le segment de code en cours d'exécution.              |
| Stack Segment     | SS      | Indique le segment de pile.                                   |
| Data Segment      | DS      | Indique le segment de données.                                |
| Extra Segment     | ES      | Utilisé comme segment additionnel pour certaines opérations.  |
| FS                | FS      | Utilisé pour accéder à des structures de données spécifiques. |
| GS                | GS      | Utilisé pour accéder à des structures de données spécifiques. |

## 4. Pile d'exécution (call stack)
La pile d'exécution est une structure de données pour gérer des sous-routines (fonctions, procédure) et suivre le flux d'exécution d'un programme.  

Elle fonctionne selon le principe de Last In, First Out (LIFO), ce qui signifie que la dernière donnée ajoutée à la pile est la première à être retirée.  

Les registres RSP et RBP délimitent le cadre de la pile. RSP correspond a l'adresse sommet de la pile (dernier élément arrivé, adresse basse) et RBP a l'adresse de fin (premier élément arrivé, adresse haute). Il est possible d'empiler (ajouter) un élément au sommet pile grâce a l'instruction push et de dépiler (retiré) l'élément au sommet de la pile grâce a l'instruction pop. Il est aussi possible d'accéder à la valeur de n'importe quel élément de la pile depuis le sommet avec ```[RSP+x*8]``` où x est égal à l'index de l'élément à récupérer (le premier élément à comme index 0). Pareillement, on peut accéder à la valeur de n'importe quel élément de la pile depuis la fin avec ```[RBP-x*8]``` où x est égal à l'index depuis la fin de l'élément à récupérer (le dernier élément à comme index 0).

Quand on appelle une fonction avec l'instruction call fonction, l'adresse de la fonction appelante est empiler, le registre RIP, registre stockant l'adresse de la prochaine instruction, prend alors la valeur de la fonction appelée. Une fois la fonction terminée, on utilise l'instruction ret pour dépiler l'adresse de la fonction appelante dans RIP pour revenir à la fonction.

## 5. Appel Système (syscall)
| Nom                    | RAX | RDI                                                  | RSI                               | RDX                | R8    | R10                    | R9       |
|------------------------|-----|------------------------------------------------------|-----------------------------------|--------------------|-------|------------------------|----------|
| read                   | 0   | descripteur de fichier                               | tampon                            | taille du tampon   |       |                        |          |
| write                  | 1   | descripteur de fichier                               | tampon                            | taille du tampon   |       |                        |          |
| open                   | 2   | nom du fichier                                       | flags                             | mode               |       |                        |          |
| close                  | 3   | descripteur de fichier                               |                                   |                    |       |                        |          |
| stat                   | 4   | nom du fichier                                       | tampon de 144 bits                |                    |       |                        |          |
| fstat                  | 5   | descripteur de fichier                               | tampon de 144 bits                |                    |       |                        |          |
| lstat                  | 6   | nom du fichier                                       | tampon de 144 bits                |                    |       |                        |          |
| poll                   | 7   | tampon de 8 bits * nombres de descripteur de fichier | nombres de descripteur de fichier | temps d'attente    |       |                        |          |
| lseek                  | 8   | descripteur de fichier                               | décalage                          | origine            |       |                        |          |
| nmap                   | 9   | adresse                                              | taille                            | protection         | flags | descripteur de fichier | décalage |
| mprotect               | 10  | adresse                                              | taille                            | protection         |       |                        |          |
| munmap                 | 11  | adresse                                              | taille                            |                    |       |                        |          |
| brk                    | 12  | adresse de fin                                       |                                   |                    |       |                        |          |
| getpid                 | 39  |                                                      |                                   |                    |       |                        |          |
| rt_sigqueueinfo        | 133 | pid                                                  | signal                            | tampon de 128 bits |       |                        |          |
| sched_getscheduler     | 145 | pid                                                  |                                   |                    |       |                        |          |
| sched_get_priority_max | 146 | politique d'ordonnancement                           |                                   |                    |       |                        |          |
| sched_get_priority_min | 147 | politique d'ordonnancement                           |                                   |                    |       |                        |          |