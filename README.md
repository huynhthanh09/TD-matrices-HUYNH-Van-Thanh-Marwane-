# TD Matrices — Compte rendu

INSA Centre Val de Loire — 3e année STI — Programmation C

> Version de travail mise à jour le 27 octobre 2026. Cette version documente la contribution connue de Van Thanh à l’exercice 1. Le compte rendu du groupe reste à compléter avec les autres membres et les exercices restants.

## Membres du groupe

| Membre | GitHub | Travail documenté ici |
|---|---|---|
| HUYNH Van Thanh | [@huynhthanh09](https://github.com/huynhthanh09) | Exercice 1, étapes 1.a à 1.f ; tests de l’exercice 1 |

Ajouter les autres membres du binôme ou trinôme, leurs comptes GitHub et leurs contributions avant le rendu final.

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
- [Déclaration de l’aide utilisée](#déclaration-de-laide-utilisée)
- [Éléments restant à compléter par le groupe](#éléments-restant-à-compléter-par-le-groupe)

## Introduction

Ce TD porte sur le stockage et la manipulation de matrices en C. Pour l’exercice 1, une matrice est représentée par un tableau de pointeurs : chaque pointeur désigne une ligne allouée séparément. Cette représentation demande de vérifier les dimensions, de traiter les échecs d’allocation et de remettre la matrice dans l’état `MATRICE_VIDE` après sa destruction ou lorsqu’une allocation échoue.

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

Si `res` vaut `NULL`, la fonction renvoie aussi `MAT_ERR_ARGUMENT`. Pour des dimensions invalides, elle renvoie `MAT_ERR_ARGUMENT` et `*res` reste égal à `MATRICE_VIDE`, car aucune allocation n’a encore eu lieu.

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

La remise à zéro rend un second appel sans danger, car la structure ne contient plus de pointeurs vers les blocs libérés.

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

Les 16 vérifications de `test_ex1` ont réussi, y compris les échecs d’allocation simulés. Le run GitHub Actions du commit `7de469b` ne signalait pas d’échec propre à `test_ex1`, mais le résumé détaillé Valgrind demandé (`HEAP SUMMARY` et `All heap blocks were freed — no leaks are possible`) n’a pas été récupéré. Il faudra ajouter la sortie réelle de Valgrind avant le rendu ; aucun résultat n’est inventé ici.

### Questions de réflexion

**3.1 — Pourquoi `mat_detruire` reçoit-elle un pointeur vers `Matrice` ?**

Le pointeur permet à `mat_detruire` de modifier la structure détenue par l’appelant et de la remettre à `MATRICE_VIDE`. Avec un passage par valeur, seule une copie locale serait vidée ; la structure de l’appelant conserverait des pointeurs vers des blocs déjà libérés.

**3.2 — Combien d’allocations et de libérations sont nécessaires ?**

Pour une matrice de `n` lignes, l’allocation demande au maximum `n + 1` allocations réussies : une pour le tableau de pointeurs et une pour chaque ligne. Si l’allocation d’une ligne échoue, les lignes obtenues auparavant et le tableau de pointeurs sont libérés avant le retour. À la destruction d’une matrice complète, on libère les `n` lignes puis le tableau de pointeurs, soit `n + 1` blocs.

**3.3 — Pourquoi un second appel à `mat_detruire` est-il sûr ? Que se passe-t-il avec une copie superficielle ?**

Après le premier appel, la matrice est remise à `MATRICE_VIDE`, donc le second appel ne trouve plus de lignes à libérer. En revanche, une copie superficielle telle que `Matrice b = a` partage les mêmes pointeurs. Détruire les deux structures tenterait de libérer deux fois les mêmes blocs, ce qui entraîne un comportement indéfini.

**3.4 — Pourquoi initialiser `*res` à `MATRICE_VIDE` au début de `mat_allouer` ?**

Cette initialisation garantit que chaque retour en erreur laisse un résultat dans un état connu et sûr. L’appelant peut tester ou détruire ce résultat sans utiliser des champs indéterminés ni une matrice partiellement construite.

## Déclaration de l’aide utilisée

Codex (assistant d’IA) a été utilisé pour clarifier les consignes, examiner les diagnostics des tests et discuter de la vérification des dimensions, de l’allocation et du nettoyage en cas d’échec. Van Thanh a intégré les modifications dans le dépôt et a exécuté les commandes de compilation et les tests indiqués dans ce compte rendu. Chaque autre membre devra déclarer l’aide qu’il a reçue pour sa propre contribution.

## Éléments restant à compléter par le groupe

- Ajouter les autres membres du binôme ou trinôme, leurs comptes GitHub et leurs contributions.
- Rédiger les parties des exercices 2, 3 et 4, avec les explications, réponses demandées et résultats de tests correspondants. Van Thanh indique ne pas avoir commencé l’exercice 3.
- Ajouter la sortie réelle de Valgrind avec le résumé du tas et la confirmation d’absence de fuite.
- Compléter les scénarios de démonstration et le bilan global du groupe.
- Avant le rendu, créer le tag `rendu` sur le commit final et pousser ce tag. Déposer sur Célène le ZIP du dépôt au tag `rendu`, l’adresse du dépôt GitHub et les 7 premiers caractères du commit. Date limite annoncée : lundi 2 novembre 2026 à 18 h. Le dépôt GitHub doit être public au plus tard le mardi 3 novembre 2026.