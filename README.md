# Assembleur-x86_64

## 1. Prérequis
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
## 2. Structure
### 2.1 Section .data
La section .data contient les définitions des variables initialisées à une ou plusieurs valeurs spécifiées.
Déclaration :
```asm
.section .data
```
### 2.2 Section .bss
La section .bss contient les déﬁnitions des variables non-initialisées, c’est à dire uniquement allouées en mémoire.
Déclaration :
```asm
.section .bss
```
### 2.3 Section .text
La section .text contient le code exécuté par un programme.
Déclaration :
```asm
.section .text
```
## 3. Registre (register)
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
## 4 Appel Système (syscall)
| Nom   | RAX | RDI                    | RSI                | RDX              | R8 | R10 | R9 |
|-------|-----|------------------------|--------------------|------------------|----|-----|----|
| read  | 0   | descripteur de fichier | tampon             | taille du tampon |    |     |    |
| write | 1   | descripteur de fichier | tampon             | taille du tampon |    |     |    |
| open  | 2   | nom du fichier         | flags              | mode             |    |     |    |
| close | 3   | descripteur de fichier |                    |                  |    |     |    |
| stat  | 4   | descipteur de fichier  | tampon de 144 bits |                  |    |     |    |