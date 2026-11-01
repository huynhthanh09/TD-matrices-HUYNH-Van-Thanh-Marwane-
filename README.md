# TD Matrices — Compte rendu

INSA Centre Val de Loire — 3e année STI — Programmation C

> Version pour le rendu du lundi 2 novembre 2026. Ce compte rendu documente les exercices 1 à 4 de la bibliothèque de matrices, leurs tests et leur vérification mémoire avec Valgrind.

## Membres du groupe

| Membre | GitHub | Travail documenté ici | Résultat des tests |
|---|---|---|---|
| HUYNH Van Thanh | [@huynhthanh09](https://github.com/huynhthanh09) | Exercice 1, étapes 1.a à 1.f (`matrice.c`, `matrice_alloc.c`) ; exercice 3, étapes 3.a à 3.h (`matrice_calcul.c`) ; réponses aux questions Q3.1 à Q3.4 et Q5.1 à Q5.4 | `test_ex1` : 16 / 16 ; `test_ex3` : 14 / 14, Valgrind sans fuite |
| Marwane Laanaya | [@LnyMarwane](https://github.com/LnyMarwane) | Exercice 2 (`matrice_io.c`) ; exercice 4 (`main.c`) ; réponses aux questions Q4.1 à Q4.4 et Q6.1 à Q6.3 | `test_ex2` : 14 / 14, Valgrind sans fuite ; `demo_matrices` : scénarios de l’exercice 4 |

### Avancement par exercice

| Exercice | Fichier(s) | Responsable | État | Test |
|---|---|---|---|---|
| 1 — Allocation et destruction | `matrice.c`, `matrice_alloc.c` | Van Thanh | Terminé | `test_ex1` : 16 / 16, Valgrind sans fuite |
| 2 — Entrées-sorties | `matrice_io.c` | Marwane | Terminé | `test_ex2` : 14 / 14, Valgrind sans fuite |
| 3 — Calcul matriciel | `matrice_calcul.c` | Van Thanh | Terminé | `test_ex3` : 14 / 14, Valgrind sans fuite |
| 4 — Démonstration complète | `main.c` | Marwane | Terminé | 10 scénarios vérifiés, Valgrind sans fuite |

## Sommaire

- [Introduction](#introduction)
- [Exercice 1 — Allocation et destruction](#exercice-1--allocation-et-destruction)
  - [1.a — Messages d’erreur](#1a--messages-derreur)
  - [1.b — Validité d’une matrice](#1b--validité-dune-matrice)
  - [1.c — Vérification des dimensions](#1c--vérification-des-dimensions)
  - [1.d — Allocation des lignes](#1d--allocation-des-lignes)
  - [1.e — Finalisation de l’allocation](#1e--finalisation-de-lallocation)
  - [1.f — Destruction](#1f--destruction)
  - [Tests et vérification mémoire](#tests-et-vérification-mémoire)
  - [Questions de réflexion](#questions-de-réflexion)
- [Exercice 2 — Lecture, écriture et affichage](#exercice-2--lecture-écriture-et-affichage)
  - [Étapes 2.a à 2.f](#étapes-2a-à-2f)
  - [Tests de l’exercice 2](#tests-de-lexercice-2)
  - [Questions de l’exercice 2](#questions-de-lexercice-2)
- [Exercice 3 — Calcul matriciel](#exercice-3--calcul-matriciel)
  - [3.a — Dimensions de l’addition](#3a--dimensions-de-laddition)
  - [3.b — Allocation du résultat de l’addition](#3b--allocation-du-résultat-de-laddition)
  - [3.c — Somme en long long](#3c--somme-en-long-long)
  - [3.d — Transfert du résultat de l’addition](#3d--transfert-du-résultat-de-laddition)
  - [3.e — Dimensions de la multiplication](#3e--dimensions-de-la-multiplication)
  - [3.f — Allocation du résultat du produit](#3f--allocation-du-résultat-du-produit)
  - [3.g — Somme des produits](#3g--somme-des-produits)
  - [3.h — Transfert du résultat du produit](#3h--transfert-du-résultat-du-produit)
  - [Tests de l’exercice 3](#tests-de-lexercice-3)
  - [Questions de l’exercice 3](#questions-de-lexercice-3)
- [Exercice 4 — Démonstration complète](#exercice-4--démonstration-complète)
  - [4.a à 4.d — Parties complétées](#4a-à-4d--parties-complétées)
  - [Scénarios de test](#scénarios-de-test)
  - [Vérification mémoire de l’exercice 4](#vérification-mémoire-de-lexercice-4)
  - [Questions de l’exercice 4](#questions-de-lexercice-4)
- [Bilan du groupe](#bilan-du-groupe)
- [Déclaration de l’aide utilisée](#déclaration-de-laide-utilisée)
- [Éléments restant à compléter par le groupe](#éléments-restant-à-compléter-par-le-groupe)

## Introduction

Ce TD porte sur le stockage et la manipulation de matrices en C. Une matrice est représentée par un tableau de pointeurs : chaque pointeur désigne une ligne allouée séparément. Cette représentation demande de vérifier les dimensions, de traiter les échecs d’allocation et de remettre la matrice dans l’état `MATRICE_VIDE` après sa destruction ou lorsqu’une opération échoue. L’exercice 2 ajoute la lecture, l’écriture et l’affichage d’une matrice dans un fichier texte. L’exercice 3 ajoute l’addition et la multiplication de deux matrices, avec contrôle des dimensions et détection des dépassements de capacité.

## Exercice 1 — Allocation et destruction

### 1.a — Messages d’erreur

Dans `mat_message_erreur` (`matrice.c`), les codes `MAT_ERR_DIMENSIONS` et `MAT_ERR_DEPASSEMENT` n’avaient pas de `case` : ils tombaient dans le cas par défaut et renvoyaient « erreur inconnue ». Je les ai ajoutés sur le modèle des autres cas :

```c
case MAT_ERR_DIMENSIONS:  return "dimensions incompatibles";
case MAT_ERR_DEPASSEMENT: return "dépassement de capacité";
```

Ces messages seront réutilisés par `main.c`, par exemple pour l’addition de deux matrices de tailles différentes. `test_ex1` vérifie que les deux messages ne renvoient pas « erreur inconnue ».

### 1.b — Validité d’une matrice

`mat_est_valide` renvoie `1` si les quatre conditions suivantes sont vraies, `0` sinon : `m` n’est pas `NULL`, `m->coef` n’est pas `NULL`, `1 <= nb_lignes <= MAT_DIM_MAX` et `1 <= nb_colonnes <= MAT_DIM_MAX`.

```c
return m != NULL
    && m->coef != NULL
    && m->nb_lignes >= 1 && m->nb_lignes <= MAT_DIM_MAX
    && m->nb_colonnes >= 1 && m->nb_colonnes <= MAT_DIM_MAX;
```

L’opérateur `&&` évalue les conditions de gauche à droite et s’arrête dès que l’une est fausse. Le test `m != NULL` est donc placé avant les accès à `m->coef` et aux dimensions. Les tests vérifient qu’une matrice `1 x 2` est valide, et que `NULL`, `MATRICE_VIDE` et une matrice à zéro ligne ne le sont pas.

### 1.c — Vérification des dimensions

Les lignes vérifiant `res` et initialisant `*res` à `MATRICE_VIDE` étaient fournies. J’ai ajouté le contrôle des deux dimensions : elles doivent être comprises entre `1` et `MAT_DIM_MAX`, bornes incluses.

```c
if (nb_lignes < 1 || nb_lignes > MAT_DIM_MAX
    || nb_colonnes < 1 || nb_colonnes > MAT_DIM_MAX)
    return MAT_ERR_ARGUMENT;
```

Si `res` vaut `NULL`, la fonction renvoie aussi `MAT_ERR_ARGUMENT`. Pour des dimensions invalides, elle renvoie `MAT_ERR_ARGUMENT` et `*res` reste égal à `MATRICE_VIDE`, car aucune allocation n’a encore eu lieu. Ce contrôle est placé avant le premier `calloc` : sans lui, une dimension négative serait convertie en un très grand `size_t` par `(size_t)nb_lignes`.

### 1.d — Allocation des lignes

Le tableau de `nb_lignes` pointeurs était fourni. J’ai écrit l’allocation de chaque ligne avec `mat_calloc`, donc tous les coefficients sont initialisés à `0` :

```c
for (int i = 0; i < nb_lignes; i++) {
    coef[i] = mat_calloc((size_t)nb_colonnes, sizeof *coef[i]);
    if (coef[i] == NULL) {
        for (int k = i - 1; k >= 0; k--)
            free(coef[k]);
        free(coef);
        return MAT_ERR_ALLOCATION;
    }
}
```

Si l’allocation de la ligne `i` échoue, les lignes déjà allouées sont libérées en ordre inverse, puis le tableau de pointeurs est libéré. La fonction renvoie `MAT_ERR_ALLOCATION`. Le résultat `*res` reste vide : la matrice n’est publiée qu’après la réussite de toutes les allocations. Le mode `MAT_TEST_ALLOC` permet aux tests de simuler ces échecs.

### 1.e — Finalisation de l’allocation

Quand le tableau de pointeurs et toutes les lignes ont été alloués, les trois champs du résultat sont renseignés et la fonction renvoie `MAT_OK` :

```c
res->coef = coef;
res->nb_lignes = nb_lignes;
res->nb_colonnes = nb_colonnes;
return MAT_OK;
```

Ces affectations sont faites après la boucle d’allocation : si une allocation échoue avant cela, `*res` reste dans l’état vide établi au début de `mat_allouer`.

### 1.f — Destruction

`mat_detruire` ne fait rien si son argument est `NULL`. Si `m->coef` n’est pas `NULL`, la fonction libère chaque ligne, puis le tableau de pointeurs. Elle remet ensuite toute la structure à `MATRICE_VIDE` :

```c
if (m->coef != NULL) {
    for (int i = 0; i < m->nb_lignes; i++)
        free(m->coef[i]);
    free(m->coef);
}

*m = MATRICE_VIDE;
```

Les lignes sont libérées avant le tableau qui contient leurs adresses : dans l’ordre inverse, on perdrait l’accès aux lignes. La remise à zéro rend un second appel sans danger, car la structure ne contient plus de pointeurs vers les blocs libérés.

### Tests et vérification mémoire

Compilation et exécution réalisées sous Windows avec GCC :

```powershell
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex1.c matrice.c matrice_alloc.c -o test_ex1.exe
.\test_ex1.exe
```

Sortie obtenue :

```text
=== Exercice 1 : matrice.c ===
[OK]    (1.a) message pour MAT_ERR_DIMENSIONS
[OK]    (1.a) message pour MAT_ERR_DEPASSEMENT
[OK]    (1.b) une matrice 1 x 2 est valide
[OK]    (1.b) NULL n'est pas valide
[OK]    (1.b) MATRICE_VIDE n'est pas valide
[OK]    (1.b) une matrice de 0 ligne n'est pas valide
=== Exercice 1 : matrice_alloc.c ===
[OK]    (1.c) mat_allouer refuse 0 ligne
[OK]    (1.c) mat_allouer refuse -2 colonnes
[OK]    (1.c) mat_allouer refuse une dimension > MAT_DIM_MAX
[OK]    (1.e) mat_allouer(&m, 3, 4) renvoie MAT_OK
[OK]    (1.e) m a 3 lignes et 4 colonnes
[OK]    (1.d) tous les coefficients valent 0
[OK]    (1.f) apres mat_detruire, m est vide
[OK]    (1.f) un second mat_detruire est sans danger
[OK]    (1.f) mat_detruire(NULL) ne plante pas
=== Exercice 1 : echecs d'allocation simules ===
[OK]    (1.d) chaque echec renvoie MAT_ERR_ALLOCATION et laisse *res vide

Bilan : 16 / 16 verifications reussies.
```

Les 16 vérifications de `test_ex1` ont réussi, y compris les échecs d’allocation simulés.

Valgrind n’existant pas sous Windows, la vérification mémoire a été réalisée sous Linux (Ubuntu 22.04 dans WSL2, Valgrind 3.18.1), sur les fichiers de l’exercice 1 de ce dépôt (`matrice.c`, `matrice_alloc.c`), avec les commandes suivantes :

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex1.c matrice.c matrice_alloc.c -o /tmp/test_ex1
valgrind --leak-check=full /tmp/test_ex1
```

Extrait du rapport (après les 16 lignes `[OK]`) :

```text
==1088== HEAP SUMMARY:
==1088==     in use at exit: 0 bytes in 0 blocks
==1088==   total heap usage: 11 allocs, 11 frees, 1,228 bytes allocated
==1088==
==1088== All heap blocks were freed -- no leaks are possible
==1088==
==1088== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Les 11 allocations correspondent à 11 libérations : aucune fuite et aucune erreur mémoire, y compris dans les scénarios d’échec d’allocation simulés.

### Questions de réflexion

**Q3.1 — Pourquoi `mat_detruire` reçoit-elle un pointeur vers `Matrice` ?**

Le pointeur permet à `mat_detruire` de modifier la structure détenue par l’appelant et de la remettre à `MATRICE_VIDE`. Avec un passage par valeur, seule une copie locale serait vidée ; la structure de l’appelant conserverait des pointeurs vers des blocs déjà libérés.

**Q3.2 — Combien d’allocations et de libérations sont nécessaires ?**

Pour une matrice de `n` lignes et `p` colonnes, il faut `n + 1` appels à `calloc` : un pour le tableau de pointeurs et un pour chacune des `n` lignes. Le nombre de colonnes `p` n’influence pas le nombre d’appels, seulement la taille de chaque ligne. À la destruction d’une matrice complète, on appelle `free` `n + 1` fois : les `n` lignes, puis le tableau de pointeurs.

Si la `k`-ième allocation échoue, les `k − 1` allocations précédentes ont réussi et `mat_allouer` doit libérer ces `k − 1` blocs. Pour `k = 1`, l’échec porte sur le tableau de pointeurs et il n’y a rien à libérer. Pour `k ≥ 2`, c’est la ligne `i = k − 2` qui échoue : on libère les `k − 2` lignes obtenues, puis le tableau de pointeurs, soit `k − 1` libérations.

**Q3.3 — Pourquoi un second appel à `mat_detruire` est-il sûr ? Que se passe-t-il avec une copie superficielle ?**

Après le premier appel, la matrice est remise à `MATRICE_VIDE`, donc le second appel ne trouve plus de lignes à libérer. En revanche, une copie superficielle telle que `Matrice b = a` partage les mêmes pointeurs. Détruire les deux structures tenterait de libérer deux fois les mêmes blocs, ce qui entraîne un comportement indéfini.

**Q3.4 — Pourquoi initialiser `*res` à `MATRICE_VIDE` au début de `mat_allouer` ?**

Cette initialisation garantit que chaque retour en erreur laisse un résultat dans un état connu et sûr, y compris lorsque l’erreur vient d’une dimension invalide, détectée avant toute allocation. L’appelant peut tester ou détruire ce résultat sans utiliser des champs indéterminés ni une matrice partiellement construite.

## Exercice 2 — Lecture, écriture et affichage

### Étapes 2.a à 2.f

`matrice_io.c` contient trois fonctions publiques (`mat_afficher`, `mat_ecrire`, `mat_lire`) et la fonction interne `lire_entier`, fournie, qui lit un entier en détectant les lettres, les nombres trop grands et la fin de fichier. Aucune fonction du module n’ouvre ni ne ferme de fichier : c’est l’appelant qui le fait (règle R7).

#### 2.a — Affichage

Le nom et les dimensions étaient déjà affichés. J’ai ajouté deux boucles imbriquées : chaque coefficient est affiché sur 8 caractères (`" %8d"`), ce qui aligne les colonnes, puis un saut de ligne termine chaque ligne de la matrice.

```c
for (int i = 0; i < m->nb_lignes; i++) {
    for (int j = 0; j < m->nb_colonnes; j++)
        printf(" %8d", m->coef[i][j]);
    printf("\n");
}
```

Le test `test_ex2` affiche la matrice `M` sur quatre lignes alignées (de 1 à 12) pour une vérification visuelle.

#### 2.b — Écriture au format canonique

La première ligne (les dimensions) était fournie. J’ai écrit les coefficients : le premier de chaque ligne avec `"%d"`, les suivants avec `" %d"` (un espace devant), pour n’avoir aucun espace en fin de ligne, puis un saut de ligne après chaque ligne, y compris la dernière.

```c
for (int i = 0; i < m->nb_lignes; i++) {
    for (int j = 0; j < m->nb_colonnes; j++) {
        int nb_caracteres_ecrits = fprintf(f, j == 0 ? "%d" : " %d", m->coef[i][j]);
        if (nb_caracteres_ecrits < 0)
            return MAT_ERR_ECRITURE;
    }
    if (fputc('\n', f) == EOF)
        return MAT_ERR_ECRITURE;
}
```

Chaque écriture est vérifiée : `fprintf` renvoie un nombre négatif en cas d’erreur et `fputc` renvoie `EOF`, ce qui donne `MAT_ERR_ECRITURE`. Le `fflush` final était fourni. Le test `(2.b) le fichier contient exactement le format attendu` compare le fichier octet par octet avec `4 3\n1 2 3\n4 5 6\n7 8 9\n10 11 12\n`.

#### 2.c — Dimensions lues

Les deux dimensions sont déjà lues par du code fourni. J’ai ajouté le contrôle de leur valeur :

```c
if (nb_lignes < 1 || nb_lignes > MAT_DIM_MAX
    || nb_colonnes < 1 || nb_colonnes > MAT_DIM_MAX)
    return MAT_ERR_FORMAT;
```

On renvoie `MAT_ERR_FORMAT` et non `MAT_ERR_ARGUMENT` : les paramètres de la fonction sont corrects, c’est le contenu du fichier qui est faux. Le contrôle est placé avant l’allocation, donc un fichier aberrant (par exemple `-2 3` ou `0 3`) ne provoque jamais de demande de mémoire démesurée. Les tests `(2.c) dimension nulle` et `(2.c) dimension negative` le vérifient.

#### 2.d — Matrice locale

```c
Matrice tmp;
err = mat_allouer(&tmp, nb_lignes, nb_colonnes);
if (err != MAT_OK)
    return err;
```

On remplit `tmp`, une variable locale, et non `*res` directement : si une erreur survient au milieu du fichier, l’appelant ne reçoit jamais une matrice à moitié remplie (réponse à Q4.1). Si `mat_allouer` échoue, elle a elle-même nettoyé et laissé `tmp` vide : il n’y a rien à libérer, on renvoie son code (`MAT_ERR_ALLOCATION`). `*res` reste égal à `MATRICE_VIDE`, établi au début de la fonction. Le test `(2.d) mat_lire renvoie MAT_ERR_ALLOCATION proprement` simule l’échec de chacune des trois allocations d’une matrice `2 x 2`.

#### 2.e — Lecture des coefficients

```c
for (int i = 0; i < nb_lignes; i++) {
    for (int j = 0; j < nb_colonnes; j++) {
        err = lire_entier(f, &tmp.coef[i][j]);
        if (err != MAT_OK) {
            mat_detruire(&tmp);
            return err;
        }
    }
}
```

Exactement `nb_lignes x nb_colonnes` entiers sont lus, sans utiliser `feof` : les dimensions suffisent à savoir combien de valeurs lire. Si une lecture échoue (coefficient manquant, donnée non numérique, entier trop grand pour un `int`), `lire_entier` renvoie `MAT_ERR_FORMAT` ; il faut alors rendre la mémoire de `tmp` avec `mat_detruire(&tmp)` avant de renvoyer l’erreur, sinon Valgrind signalerait une fuite. Les trois tests de fichiers incorrects correspondants (`(2.e) coefficient manquant`, `donnee non numerique`, `entier trop grand pour un int`) et le test des espaces et sauts de ligne en trop vérifient cette étape.

#### 2.f — Transfert du résultat

```c
*res = tmp;
return MAT_OK;
```

Tout a réussi : la propriété de la mémoire est transférée à l’appelant (règle R2), qui devra appeler `mat_detruire`. Les tests `(2.f) mat_lire relit le fichier : MAT_OK` et `(2.e) la matrice relue est identique` valident l’aller-retour écriture puis lecture.

### Tests de l’exercice 2

Compilation (sans aucun avertissement) et exécution réalisées sous Windows avec GCC :

```powershell
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex2.c matrice.c matrice_alloc.c matrice_io.c -o test_ex2.exe
.\test_ex2.exe
```

Sortie obtenue :

```text
=== Exercice 2 : affichage (verification visuelle) ===
M (4 x 3) :
        1        2        3
        4        5        6
        7        8        9
       10       11       12
(2.a) Vous devez voir ci-dessus 4 lignes : 1 2 3 / 4 5 6 / 7 8 9 / 10 11 12
=== Exercice 2 : ecriture ===
[OK]    ouverture de test_ex2_sortie.txt en ecriture
[OK]    (2.b) mat_ecrire renvoie MAT_OK
[OK]    (2.b) le fichier contient exactement le format attendu
[OK]    (2.b) mat_ecrire refuse une matrice vide
=== Exercice 2 : relecture ===
[OK]    (2.f) mat_lire relit le fichier : MAT_OK
[OK]    (2.e) la matrice relue est identique
[OK]    (2.e) espaces et sauts de ligne en trop sont toleres
=== Exercice 2 : fichiers incorrects ===
[OK]    (2.c) fichier vide
[OK]    (2.c) dimension nulle
[OK]    (2.c) dimension negative
[OK]    (2.e) coefficient manquant
[OK]    (2.e) donnee non numerique
[OK]    (2.e) entier trop grand pour un int
=== Exercice 2 : echec d'allocation simule ===
[OK]    (2.d) mat_lire renvoie MAT_ERR_ALLOCATION proprement

Bilan : 14 / 14 verifications reussies.
Pensez a verifier l'absence de fuite : valgrind --leak-check=full ./test_ex2
```

Les 14 vérifications de `test_ex2` ont réussi : affichage, écriture au format canonique, relecture, six fichiers incorrects et échec d’allocation simulé. Vérification mémoire : réalisée sous Linux (Ubuntu 22.04 dans WSL2, Valgrind 3.18.1), sur les fichiers de ce dépôt :

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex2.c matrice.c matrice_alloc.c matrice_io.c -o /tmp/test_ex2
valgrind --leak-check=full /tmp/test_ex2
```

Extrait du rapport (après les lignes `[OK]`) :

```text
==1123== HEAP SUMMARY:
==1123==     in use at exit: 0 bytes in 0 blocks
==1123==   total heap usage: 51 allocs, 51 frees, 60,728 bytes allocated
==1123==
==1123== All heap blocks were freed -- no leaks are possible
==1123==
==1123== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Les 51 allocations correspondent à 51 libérations, y compris dans les scénarios de fichiers incorrects et d’échec d’allocation simulé, où `mat_lire` doit détruire sa matrice locale `tmp`.

### Questions de l’exercice 2

**Q4.1 — Pourquoi `mat_lire` remplit-elle d’abord une matrice locale avant de l’affecter à `*res` ?**

`mat_lire` remplit d’abord une matrice locale avant de l’affecter à `*res`, afin de respecter la règle R3 de la bibliothèque : si une fonction échoue, le paramètre de sortie `*res` doit rester dans un état sûr (`MATRICE_VIDE`), sans fuite de mémoire. Si la lecture échoue au milieu du fichier, seule la matrice locale est détruite ; l’appelant ne reçoit jamais une matrice à moitié remplie.

**Q4.2 — La lecture vérifie-t-elle que chaque ligne de la matrice est sur sa propre ligne de texte ? Est-ce gênant ?**

Non. `mat_lire` appelle `lire_entier`, qui utilise `fscanf` avec `%31s` puis `strtol` : elle consomme les entiers les uns après les autres. En C, les fonctions de lecture formatée de la bibliothèque standard traitent les espaces, les tabulations et les sauts de ligne (`\n`) comme de simples séparateurs. La mise en forme du fichier n’est donc pas gênante.

Le principe « tolérant en lecture, strict en écriture » se justifie ainsi : en écriture, le format canonique (un seul espace, pas d’espace final, un saut de ligne par ligne) garantit un fichier prévisible, que n’importe quel programme peut relire ; en lecture, la tolérance sur les blancs évite de rejeter un fichier valide modifié à la main, tandis que la rigueur sur le contenu (dimensions entre 1 et `MAT_DIM_MAX`, exactement `n x p` entiers représentables par un `int`) protège la bibliothèque contre les données invalides.

**Q4.3 — Comment exploiter la position du flux après `mat_lire` pour stocker deux matrices dans un même fichier ?**

Pour écrire deux matrices dans le même fichier, il suffit d’appeler `mat_ecrire` pour la première, puis, sans fermer le fichier, `mat_ecrire` pour la seconde. Les deux blocs de texte se succèdent naturellement.

Pour les relire, on effectue deux appels successifs à `mat_lire` sur le même pointeur de fichier `f` :

```c
Matrice m1 = MATRICE_VIDE, m2 = MATRICE_VIDE;

/* 1. Lecture de la première matrice */
if (mat_lire(f, &m1) != MAT_OK) {
    /* gestion de l'erreur */
}

/* 2. Le flux est déjà positionné juste après le dernier coefficient de m1 :
 *    on peut lire la seconde matrice directement. */
if (mat_lire(f, &m2) != MAT_OK) {
    mat_detruire(&m1);   /* ne pas oublier de nettoyer m1 si m2 échoue */
    /* gestion de l'erreur */
}
```

**Q4.4 — Pourquoi `mat_ecrire` appelle-t-elle `fflush` avant de renvoyer `MAT_OK` ? Cela dispense-t-il l’appelant de tester `fclose` ?**

Les fonctions d’écriture comme `fprintf` ou `fputc` n’écrivent pas immédiatement dans le fichier. Pour des raisons de performance, les données sont d’abord stockées dans une mémoire tampon (le buffer). Le contenu n’est réellement transmis au système que lorsque le tampon est plein, ou lors de la fermeture du fichier. En appelant `fflush(f)` à la fin, on force le vidage immédiat du tampon. Si ce vidage échoue, `fflush` renvoie `EOF`, ce qui permet à `mat_ecrire` de détecter l’erreur sur le moment et de renvoyer `MAT_ERR_ECRITURE` au lieu de valider faussement l’écriture.

Cela ne dispense pas de tester `fclose`. Même si `fflush` a réussi, l’appelant qui a ouvert le fichier avec `fopen` doit tester le retour de `fclose(f)`, car cette fonction effectue elle aussi un dernier vidage du tampon et libère les ressources associées au fichier. Sur certains systèmes ou certains supports (réseau, clé USB), les erreurs d’écriture définitives ne sont remontées qu’à la fermeture.

## Exercice 3 — Calcul matriciel

L’exercice 3 complète `matrice_calcul.c` avec deux fonctions : `mat_additionner` (étapes 3.a à 3.d) et `mat_multiplier` (étapes 3.e à 3.h). Elles suivent la même démarche :

1. vérifier que les dimensions permettent l’opération ;
2. allouer le résultat dans une variable **locale** `r`, sans toucher à `*res` ;
3. calculer chaque coefficient en `long long` et refuser tout résultat qui ne tient pas dans un `int` ;
4. seulement à la fin, quand tout a réussi, transférer `r` dans `*res`.

Ainsi l’appelant ne reçoit jamais un résultat à moitié calculé, et en cas d’échec `*res` reste égal à `MATRICE_VIDE`. La fonction fournie `verifier_parametres` refuse `res == NULL` ainsi que `res == a` ou `res == b`, met `*res` à l’état vide et vérifie que `a` et `b` sont valides avec `mat_est_valide`. La fonction fournie `tient_dans_int` indique si une valeur `long long` peut être rangée dans un `int`. Les matrices `a` et `b` ne sont jamais modifiées (paramètres `const`).

### 3.a — Dimensions de l’addition

Deux matrices ne peuvent être additionnées que si elles ont exactement les mêmes dimensions. Dans `mat_additionner`, j’ai ajouté après l’appel à `verifier_parametres` :

```c
if (a->nb_lignes != b->nb_lignes || a->nb_colonnes != b->nb_colonnes)
    return MAT_ERR_DIMENSIONS;
```

Il suffit qu’une seule des deux dimensions diffère pour refuser l’opération, d’où l’opérateur `||`. On compare bien les lignes entre elles et les colonnes entre elles, et non le nombre total de coefficients : une matrice `2 x 3` et une matrice `3 x 2` ont six coefficients chacune mais ne s’additionnent pas. Les accès à `a->nb_lignes` et `b->nb_lignes` sont sûrs, car `verifier_parametres` a déjà vérifié la validité de `a` et `b`. À ce stade, `*res` est toujours vide.

### 3.b — Allocation du résultat de l’addition

Le résultat a les mêmes dimensions que `a`. La variable `r` était déjà déclarée à `MATRICE_VIDE` ; j’ai ajouté l’allocation juste après :

```c
Matrice r = MATRICE_VIDE;
err = mat_allouer(&r, a->nb_lignes, a->nb_colonnes);
if (err != MAT_OK)
    return err;
```

`err` est déjà déclarée en début de fonction, il ne faut donc pas la redéclarer. Si `mat_allouer` échoue, elle a elle-même nettoyé et laissé `r` vide : il n’y a rien à libérer, on propage simplement le code d’erreur (`MAT_ERR_ALLOCATION`). Le test `(3.b) le resultat possede sa propre memoire` vérifie que `r` ne partage aucune mémoire avec `a` ou `b`.

### 3.c — Somme en long long

Dans la double boucle fournie sur `(i, j)`, j’ai remplacé la ligne provisoire `long long s = 0;` par :

```c
long long s = (long long)a->coef[i][j] + b->coef[i][j];
```

La conversion `(long long)` s’applique au premier opérande ; le second est alors promu automatiquement, et l’addition se fait en `long long`. Sans cette conversion, la somme de deux `int` serait calculée en `int` et pourrait déborder avant même d’être testée. Deux `int` de 32 bits ont toujours une somme qui tient dans un `long long` de 64 bits. Le code fourni teste ensuite la valeur avec `tient_dans_int(s)` : si elle ne tient pas dans un `int`, on détruit `r` (`mat_detruire(&r)`) et on renvoie `MAT_ERR_DEPASSEMENT`. Le test `(3.c) INT_MAX + 1 : MAT_ERR_DEPASSEMENT` vérifie ce cas.

### 3.d — Transfert du résultat de l’addition

Tout a réussi : le résultat est transféré à l’appelant. J’ai supprimé les deux lignes provisoires (`mat_detruire(&r);` et `return MAT_ERR_LECTURE;`) et les ai remplacées par :

```c
*res = r;
return MAT_OK;
```

Cette affectation transfère la propriété de la mémoire : `res->coef` pointe désormais vers les lignes allouées pour `r`. On ne libère donc pas `r` ici ; c’est l’appelant qui devra appeler `mat_detruire(res)`. La variable locale `r` disparaît à la fin de la fonction sans qu’aucune mémoire soit perdue. Le test `(3.d) (2 x 3) + (2 x 3) : MAT_OK` et le test `(3.c) a + b est correct` valident l’addition complète.

### 3.e — Dimensions de la multiplication

Le produit `a x b` n’est défini que si le nombre de colonnes de `a` est égal au nombre de lignes de `b` :

```c
if (a->nb_colonnes != b->nb_lignes)
    return MAT_ERR_DIMENSIONS;
```

Ce n’est pas la même condition que pour l’addition : on compare ici les colonnes de `a` aux lignes de `b`. Par exemple `(2 x 3) x (2 x 3)` est refusé, comme `A x A` pour toute matrice `A` non carrée. Le test `(3.e) (2 x 3) x (2 x 3) : MAT_ERR_DIMENSIONS` vérifie ce cas.

### 3.f — Allocation du résultat du produit

Si `a` est de taille `n x p` et `b` de taille `p x q`, le produit est de taille `n x q` : il a le nombre de lignes de `a` et le nombre de colonnes de `b`.

```c
Matrice r = MATRICE_VIDE;
err = mat_allouer(&r, a->nb_lignes, b->nb_colonnes);
if (err != MAT_OK)
    return err;
```

L’erreur classique serait d’écrire `a->nb_colonnes` pour la seconde dimension. Le test `(3.f) (3 x 2) x (2 x 3) donne une matrice 3 x 3` détecte cette erreur, et le test `(3.f) echec d'allocation` vérifie qu’un échec de `mat_allouer` renvoie `MAT_ERR_ALLOCATION` en laissant `r` (donc `*res`) vide.

### 3.g — Somme des produits

Chaque coefficient du produit est `c(i,j) = somme sur k de a(i,k) × b(k,j)`. Dans la boucle fournie, la variable `s` est remise à `0` pour chaque couple `(i, j)`. J’ai écrit la boucle sur `k` :

```c
for (int k = 0; k < a->nb_colonnes; k++) {
    long long p = (long long)a->coef[i][k] * b->coef[k][j];
    if ((p > 0 && s > LLONG_MAX - p)
        || (p < 0 && s < LLONG_MIN - p)) {
        mat_detruire(&r);
        return MAT_ERR_DEPASSEMENT;
    }
    s += p;
}
```

- `k` va de `0` à `a->nb_colonnes - 1`, qui vaut aussi `b->nb_lignes - 1` grâce au contrôle de l’étape 3.e.
- Le produit `p` est calculé en `long long` (le produit de deux `int` y tient toujours).
- Le `if` vérifie, **avant** d’ajouter `p`, que `s + p` ne dépassera pas les bornes d’un `long long` : le calcul de l’accumulateur ne provoque donc jamais de dépassement non défini.
- En cas de dépassement, `r` a déjà été allouée : il faut la rendre avec `mat_detruire(&r)` avant de renvoyer `MAT_ERR_DEPASSEMENT`.
- Une fois la somme terminée, le code fourni teste `tient_dans_int(s)` avant de ranger `(int)s` dans `r.coef[i][j]`.

Le test `(3.g) a x c = (58 64 / 139 154)` vérifie le calcul sur l’exemple de l’énoncé (`c11 = 1·7 + 2·9 + 3·11 = 58`), et le test `(3.g) 2 x 10^10 depasse INT_MAX` vérifie la détection d’un résultat qui ne tient pas dans un `int`.

### 3.h — Transfert du résultat du produit

Comme en 3.d, j’ai remplacé les deux lignes provisoires de la fin de `mat_multiplier` par :

```c
*res = r;
return MAT_OK;
```

Seules les deux lignes situées juste après le commentaire `(3.h)` ont été remplacées ; les `mat_detruire(&r)` situés dans les boucles, avant les `return MAT_ERR_DEPASSEMENT`, sont du code correct et restent en place. Le test `(3.h) (2 x 3) x (3 x 2) : MAT_OK` valide le cas nominal.

### Tests de l’exercice 3

Compilation et exécution réalisées sous Windows avec GCC, sans aucun avertissement :

```powershell
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c -o test_ex3.exe
.\test_ex3.exe
```

Sortie obtenue :

```text
=== Exercice 3 : addition ===
[OK]    (3.a) (2 x 3) + (3 x 2) : MAT_ERR_DIMENSIONS
[OK]    (3.d) (2 x 3) + (2 x 3) : MAT_OK
[OK]    (3.c) a + b est correct
[OK]    a et b n'ont pas ete modifiees
[OK]    (3.b) le resultat possede sa propre memoire
[OK]    (3.c) INT_MAX + 1 : MAT_ERR_DEPASSEMENT
=== Exercice 3 : multiplication ===
[OK]    (3.e) (2 x 3) x (2 x 3) : MAT_ERR_DIMENSIONS
[OK]    (3.h) (2 x 3) x (3 x 2) : MAT_OK
[OK]    (3.g) a x c = (58 64 / 139 154)
[OK]    (3.f) (3 x 2) x (2 x 3) donne une matrice 3 x 3
[OK]    a et c n'ont pas ete modifiees
[OK]    (3.g) 2 x 10^10 depasse INT_MAX : MAT_ERR_DEPASSEMENT
=== Exercice 3 : cas particuliers ===
[OK]    resultat = entree refuse, a reste intacte
[OK]    (3.f) echec d'allocation : MAT_ERR_ALLOCATION, r vide

Bilan : 14 / 14 verifications reussies.
Pensez a verifier l'absence de fuite : valgrind --leak-check=full ./test_ex3
```

Les 14 vérifications de `test_ex3` ont réussi : addition, multiplication, refus des dimensions incompatibles, détection des dépassements, non-modification des entrées, refus de `res` égal à une entrée et échec d’allocation simulé.

Vérification mémoire : Valgrind n’existant pas sous Windows, elle a été réalisée sous Linux (Ubuntu 22.04 dans WSL2, Valgrind 3.18.1), sur les fichiers de ce dépôt, avec les commandes suivantes :

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g -DMAT_TEST_ALLOC test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c -o /tmp/test_ex3
valgrind --leak-check=full /tmp/test_ex3
```

Extrait du rapport (après les 14 lignes `[OK]`) :

```text
==1078== HEAP SUMMARY:
==1078==     in use at exit: 0 bytes in 0 blocks
==1078==   total heap usage: 37 allocs, 37 frees, 1,412 bytes allocated
==1078==
==1078== All heap blocks were freed -- no leaks are possible
==1078==
==1078== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Les 37 allocations correspondent à 37 libérations : aucune fuite et aucune erreur mémoire, y compris dans les chemins d’erreur (dépassement de capacité, dimensions incompatibles, échecs d’allocation simulés) où `mat_detruire(&r)` doit rendre la matrice locale avant de renvoyer le code d’erreur.

### Questions de l’exercice 3

**Q5.1 — Le paramètre `const Matrice *a` empêche-t-il d’écrire `a->coef[0][0] = 7;` ? Que protège exactement ce `const` ? Que faudrait-il changer pour que le compilateur refuse cette affectation ?**

Non, cette instruction est acceptée par le compilateur. Le `const` de `const Matrice *a` protège la structure pointée : on ne peut pas écrire `a->nb_lignes = 3;` ni `a->coef = NULL;`, car les champs de la structure sont en lecture seule. Mais `coef` est de type `int **` : ce qui devient constant, c’est le pointeur `coef` lui-même, pas les `int *` qu’il contient ni les `int` vers lesquels ils pointent. `a->coef[0][0] = 7;` modifie un entier situé dans un bloc alloué à part, atteint en suivant deux pointeurs : le `const` ne se propage pas à travers les pointeurs (il est « superficiel »).

Pour que le compilateur refuse cette affectation, il faudrait déclarer le champ avec `const` à tous les niveaux, par exemple `const int *const *coef;`. Le prix à payer est que le code qui remplit la matrice (`mat_allouer`, `mat_lire`, `mat_additionner`, `mat_multiplier`) ne pourrait plus écrire dans `coef[i][j]` sans conversion explicite ou sans type distinct pour l’écriture. Dans notre bibliothèque, l’intégrité des entrées repose donc sur le fait que le code ne les modifie pas, et le test « a et b n’ont pas été modifiées » le vérifie.

**Q5.2 — Pourquoi refuse-t-on l’appel `mat_additionner(&a, &b, &a)` alors que, mathématiquement, `a ← a + b` a un sens ? Que se passerait-il avec notre implémentation si on l’acceptait ?**

Parce que `res` est un paramètre de sortie dont le contenu antérieur est ignoré et écrasé, et que notre implémentation construit un résultat dans une nouvelle matrice. Si `res == a`, la première chose que fait `verifier_parametres` (`*res = MATRICE_VIDE`) vide aussi `a` : `a` perd ses pointeurs, sa mémoire n’est plus accessible (fuite), et la vérification `mat_est_valide(a)` qui suit échoue, puisque `a` est devenue vide. Même sans cette remise à zéro, l’affectation finale `*res = r` remplacerait les pointeurs de `a` par ceux de `r` sans libérer l’ancienne mémoire de `a`, donc encore une fuite. Pour la multiplication, calculer en place serait même faux : écrire `c(i,j)` détruirait des coefficients de `a` dont les calculs suivants ont encore besoin.

Pour obtenir `a ← a + b`, on appelle `mat_additionner(&a, &b, &r)` avec une matrice `r` distincte, puis on libère l’ancienne `a` avec `mat_detruire(&a)`, on transfère le résultat (`a = r;`) et on remet `r` à `MATRICE_VIDE` pour ne pas la détruire deux fois.

**Q5.3 — Combien de multiplications d’entiers effectue `mat_multiplier` pour des matrices `n x p` et `p x q` ? Combien pour deux matrices `1000 x 1000` ?**

Le résultat a `n × q` coefficients, et chacun est une somme de `p` produits : `mat_multiplier` effectue donc `n × p × q` multiplications. Pour deux matrices `1000 x 1000`, cela fait `1000 × 1000 × 1000 = 10^9`, soit un milliard de multiplications (et autant d’additions). Le coût est cubique : doubler la taille des matrices multiplie le temps de calcul par huit.

**Q5.4 — Pourquoi ne suffit-il pas de calculer `int s = a + b;` puis de tester `s < a` pour détecter un dépassement ?**

Parce que le dépassement a déjà eu lieu au moment du test, et qu’en C le dépassement d’un entier **signé** est un comportement indéfini : le résultat n’est pas garanti. Le compilateur est en droit de supposer qu’il n’arrive jamais et peut donc supprimer le test `s < a` lors de l’optimisation. De plus, ce test n’a de sens que pour `b >= 0` : si `b` est négatif, `s < a` est le résultat normal de l’addition et ne signale aucun dépassement. L’astuce du « test après coup » ne fonctionne de façon fiable que pour les entiers non signés, dont le débordement est défini (arithmétique modulaire).

C’est pourquoi la bibliothèque calcule d’abord la somme dans un type plus large (`long long`), où elle ne peut pas déborder pour deux `int`, puis teste avec `tient_dans_int` si le résultat rentre dans un `int`. Une autre solution correcte serait de tester avant d’additionner, par exemple `b > INT_MAX - a` pour `b > 0`.

## Exercice 4 — Démonstration complète

`main.c` assemble les quatre modules : le programme `demo_matrices` lit deux matrices depuis des fichiers, calcule leur somme ou leur produit, affiche les trois matrices et enregistre le résultat. Les trois matrices sont initialisées à `MATRICE_VIDE` (règle R1) et toute erreur saute à l’étiquette `nettoyage`, point de sortie unique où chaque matrice est détruite exactement une fois. Les fonctions `charger` et `sauvegarder`, qui ouvrent et ferment les fichiers (règle R7), étaient fournies.

### 4.a à 4.d — Parties complétées

```c
/* 4.a : affichage de A et B */
mat_afficher("A", &a);
mat_afficher("B", &b);

/* 4.b : calcul du résultat */
MatErreur err = addition ? mat_additionner(&a, &b, &r)
                         : mat_multiplier(&a, &b, &r);
if (err != MAT_OK) {
    fprintf(stderr, "Erreur : calcul impossible : %s ",
            mat_message_erreur(err));
    fprintf(stderr, "(A : %d x %d, B : %d x %d)\n",
            a.nb_lignes, a.nb_colonnes, b.nb_lignes, b.nb_colonnes);
    goto nettoyage;
}

/* 4.c : affichage de R */
mat_afficher((addition ? "R = A + B" : "R = A x B"), &r);

/* 4.d : succès */
printf("Résultat enregistré dans \"%s\".\n", argv[4]);
statut = EXIT_SUCCESS;
```

Une première version de l’étape 4.b passait `stdout` et des chaînes de caractères à la place des entiers dans le second `fprintf` : le compilateur signalait trois avertissements `-Wformat`, et les dimensions affichées dans les scénarios 3 et 4 étaient fausses. L’appel a été corrigé comme ci-dessus ; le programme compile désormais sans aucun avertissement.

### Scénarios de test

Compilation sans aucun avertissement, puis exécution sous Windows avec GCC :

```powershell
gcc -std=c11 -Wall -Wextra -Wpedantic -g main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c -o demo_matrices.exe
```

| # | Commande | Résultat observé | Code de sortie |
|---|---|---|---|
| 1 | `add A.txt B.txt R.txt` | affiche A, B et `R = A + B (4 x 3)` ; `R.txt` créé au format canonique | 0 |
| 2 | `mul A.txt C.txt R.txt` | `R = A x B (4 x 2)` : `193 -36 / 37 22 / 65 78 / -10 17` | 0 |
| 3 | `add A.txt C.txt R.txt` | « dimensions incompatibles (A : 4 x 3, B : 3 x 2) » | 1 |
| 4 | `mul A.txt B.txt R.txt` | « dimensions incompatibles (A : 4 x 3, B : 4 x 3) » | 1 |
| 5 | `add absent.txt B.txt R.txt` | « impossible d’ouvrir "absent.txt" : No such file or directory » | 1 |
| 6 | `add invalide.txt B.txt R.txt` | « lecture de "donnees/invalide.txt" : fichier mal formé » | 1 |
| 7 | `add tronque.txt B.txt R.txt` | « lecture de "donnees/tronque.txt" : fichier mal formé » | 1 |
| 8 | `add A.txt B.txt dossier_inexistant/R.txt` | A, B et R affichées, puis « impossible de créer "dossier_inexistant/R.txt" : No such file or directory » | 1 |
| 9 | échec d’allocation | simulé dans `test_ex2` (2.d) et `test_ex3` (3.f) : code `MAT_ERR_ALLOCATION`, aucune fuite | — |
| 10 | aucun argument | message `Usage : ... <add\|mul> <fichier_A> <fichier_B> <fichier_R>` | 1 |

Les fichiers `A.txt`, `B.txt`, `C.txt`, `invalide.txt` et `tronque.txt` sont dans le dossier `donnees/`. Les scénarios 3 et 4 affichent d’abord A et B, puis le message d’erreur sur `stderr`. Les accents du message (« mal formé », « créer ») s’affichent mal dans une console PowerShell dont la page de codes n’est pas UTF-8 (`chcp 65001` corrige l’affichage) ; le fichier source est bien enregistré en UTF-8.

Relecture du fichier produit par le programme lui-même (critère final de l’énoncé) : le fichier `R.txt` du scénario 1 est relu comme A et comme B.

```powershell
.\demo_matrices.exe add donnees/A.txt donnees/B.txt R.txt
.\demo_matrices.exe add R.txt R.txt R2.txt
```

Le second appel lit `R.txt` sans erreur, affiche A et B identiques (`26 50 87 / 19 38 17 / 52 96 19 / 10 23 7`), calcule `R = A + B` = `52 100 174 / 38 76 34 / 104 192 38 / 20 46 14` (chaque coefficient est doublé), enregistre `R2.txt` et se termine avec le code de sortie `0`. Le format canonique écrit par `mat_ecrire` est donc bien relu par `mat_lire`.

### Vérification mémoire de l’exercice 4

Réalisée sous Linux (Ubuntu 22.04 dans WSL2, Valgrind 3.18.1) sur le scénario 1 (succès) et sur le scénario 8 (échec de l’enregistrement : sortie par `goto nettoyage` alors que `r` est déjà allouée) :

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c -o /tmp/demo
valgrind --leak-check=full /tmp/demo add donnees/A.txt donnees/B.txt /tmp/R.txt
valgrind --leak-check=full /tmp/demo add donnees/A.txt donnees/B.txt /tmp/khong_co/R.txt
```

```text
Scénario 1 (succès) :
==1110== HEAP SUMMARY:
==1110==     in use at exit: 0 bytes in 0 blocks
==1110==   total heap usage: 22 allocs, 22 frees, 14,968 bytes allocated
==1110== All heap blocks were freed -- no leaks are possible
==1110== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)

Scénario 8 (échec de l'enregistrement) :
==1111== HEAP SUMMARY:
==1111==     in use at exit: 0 bytes in 0 blocks
==1111==   total heap usage: 21 allocs, 21 frees, 10,872 bytes allocated
==1111== All heap blocks were freed -- no leaks are possible
==1111== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Dans les deux cas, toutes les allocations sont libérées : les trois matrices `a`, `b` et `r` sont détruites au point de sortie unique `nettoyage`.

### Questions de l’exercice 4

**Q6.1 — Pourquoi le message d’erreur est-il affiché par `main.c` (ou ses fonctions `static`) et non par `mat_lire` ?**

Une bibliothèque doit rester générique et réutilisable : si `mat_lire` écrivait directement sur `stderr`, un programme à interface graphique réutilisant la bibliothèque afficherait ses messages dans une console invisible, ou perturberait son affichage. La bibliothèque se contente donc de renvoyer un code d’erreur, et c’est le programme appelant qui décide comment le présenter (console, boîte de dialogue, journal) grâce à `mat_message_erreur`.

**Q6.2 — Pourquoi le résultat de `fclose` est-il testé dans `sauvegarder` mais pas dans `charger` ?**

En écriture, les données passent par un tampon et ne sont parfois définitivement écrites qu’à la fermeture ; des erreurs critiques (disque plein, clé USB débranchée, droits manquants) peuvent n’y apparaître qu’à ce moment, donc il faut tester `fclose` pour être sûr que le fichier est complet. En lecture, rien n’est modifié sur le support et la matrice est déjà entièrement en mémoire : un échec de `fclose` n’altère pas les données chargées, et le tester est beaucoup moins important.

**Q6.3 — Dans le scénario 8, le calcul a réussi mais l’enregistrement a échoué. Combien de matrices faut-il libérer ?**

Trois : `a`, `b` et `r`. Le calcul a réussi, donc `r` a bien été allouée avant l’échec de l’enregistrement. Le point de sortie unique `nettoyage` appelle `mat_detruire` sur les trois, et c’est sans danger pour celles qui seraient restées vides (règle R6). Valgrind le confirme : 21 allocations, 21 libérations.

## Bilan du groupe

| Élément | Résultat |
|---|---|
| `test_ex1` (exercice 1) | 16 / 16, Valgrind sans fuite (11 allocs, 11 frees) |
| `test_ex2` (exercice 2) | 14 / 14, Valgrind sans fuite (51 allocs, 51 frees) |
| `test_ex3` (exercice 3) | 14 / 14, Valgrind sans fuite (37 allocs, 37 frees) |
| `demo_matrices` (exercice 4) | 10 scénarios traités ; Valgrind sans fuite sur le succès (22 / 22) et sur l’échec d’enregistrement (21 / 21) |
| Compilation | aucun avertissement avec `-std=c11 -Wall -Wextra -Wpedantic` |

Difficultés rencontrées : l’affichage des dimensions dans le message d’erreur de `main.c` (arguments de `fprintf` incorrects, détectés par les avertissements du compilateur puis corrigés) ; le travail à deux sur le même dépôt, où un `git push` refusé (`fetch first`) a été résolu avec `git pull --rebase origin main` ; et l’exécution de Valgrind, absent de Windows, que nous avons lancé sous Linux dans WSL2.

## Déclaration de l’aide utilisée

Codex (assistant d’IA) a été utilisé pour clarifier les consignes, examiner les diagnostics des tests et discuter de la vérification des dimensions, de l’allocation et du nettoyage en cas d’échec. Claude (assistant d’IA) a été utilisé pour relire le code de l’exercice 1, pour rédiger le code de `matrice_calcul.c` (exercice 3, étapes 3.a à 3.h) à partir des indications de l’énoncé, pour repérer et corriger l’erreur d’affichage des dimensions dans `main.c` (étape 4.b), et pour aider à rédiger et mettre en forme ce compte rendu. Van Thanh a copié ce code dans le dépôt, l’a compilé et testé (`test_ex3` : 14 / 14), et a exécuté lui-même les commandes de compilation, de test et de vérification Valgrind des exercices 1 à 4 indiquées dans ce compte rendu (Ubuntu 22.04 sous WSL2). *À compléter par Marwane Laanaya : l’aide reçue pour les exercices 2 et 4.*

## Éléments restant à compléter par le groupe

- Marwane : compléter la déclaration de l’aide utilisée (exercices 2 et 4).
- Avant le rendu, créer le tag `rendu` sur le commit final et pousser ce tag. Déposer sur Célène le ZIP du dépôt au tag `rendu`, l’adresse du dépôt GitHub et les 7 premiers caractères du commit. Date limite annoncée : lundi 2 novembre 2026 à 18 h. Le dépôt GitHub doit être public au plus tard le mardi 3 novembre 2026.