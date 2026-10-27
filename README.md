# TD Matrices — Compte rendu

INSA Centre Val de Loire — 3e année STI — Programmation C

> Version de travail mise à jour le 27 octobre 2026. Le présent compte rendu documente l’avancement connu du groupe ; les sections non encore réalisées devront être complétées avant le rendu.

## Membres du groupe

| Membre | GitHub | Travail documenté ici |
|---|---|---|
| HUYNH Van Thanh | [@huynhthanh09](https://github.com/huynhthanh09) | Exercice 1, étapes 1.a à 1.f ; tests de l’exercice 1 |

Ajouter les autres membres du binôme ou trinôme, leurs comptes GitHub et leur contribution avant le rendu final.

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
- [Éléments à compléter par le groupe](#éléments-à-compléter-par-le-groupe)

## Introduction

Ce TD porte sur le stockage et la manipulation de matrices en C. Pour l’exercice 1, la matrice est représentée par un tableau de pointeurs : chaque pointeur désigne une ligne allouée séparément. Cette représentation impose de gérer soigneusement les erreurs d’allocation et de remettre la matrice dans l’état `MATRICE_VIDE` lorsqu’une opération échoue ou après sa destruction.

## Exercice 1 — Allocation et destruction

### 1.a — Messages d’erreur

Dans `matrice.c`, les cas `MAT_ERR_DIMENSIONS` et `MAT_ERR_DEPASSEMENT` ont été ajoutés à `mat_message_erreur`. Ils renvoient respectivement `dimensions incompatibles` et `dépassement de capacité`, au lieu de tomber dans le cas par défaut. Les deux cas sont vérifiés par `test_ex1`.

### 1.b — Validité d’une matrice

La fonction de validation accepte une matrice de dimensions positives dont les champs et les coefficients sont présents. Les tests vérifient qu’une matrice `1 x 2` est valide, et que `NULL`, `MATRICE_VIDE` et une matrice à zéro ligne ne le sont pas.

### 1.c — Vérification des dimensions

`mat_allouer` vérifie d’abord que le pointeur de résultat existe, puis initialise `*res` à `MATRICE_VIDE`. Les deux dimensions doivent être comprises entre `1` et `MAT_DIM_MAX`, bornes incluses. Sinon, la fonction renvoie `MAT_ERR_ARGUMENT` et le résultat reste vide.

### 1.d — Allocation des lignes

Après validation, un tableau de `nb_lignes` pointeurs est créé avec `mat_calloc`. Chaque ligne reçoit ensuite son propre tableau de `nb_colonnes` entiers, également créé avec `mat_calloc` ; les coefficients sont donc initialisés à zéro.

Si l’allocation d’une ligne échoue, les lignes déjà obtenues sont libérées en ordre inverse, puis le tableau de pointeurs est libéré. La fonction renvoie `MAT_ERR_ALLOCATION` sans publier de matrice partiellement construite. Le mécanisme de test activé par `MAT_TEST_ALLOC` permet de provoquer ces échecs.

### 1.e — Finalisation de l’allocation

Les champs de `*res` (`coef`, `nb_lignes` et `nb_colonnes`) ne sont renseignés qu’après la réussite de toutes les allocations. La fonction renvoie alors `MAT_OK`. Un échec antérieur laisse donc le résultat dans l’état vide initialisé en 1.c.

### 1.f — Destruction

`mat_detruire` ne fait rien lorsque son argument est `NULL`. Pour une matrice allouée, elle libère chaque ligne, puis le tableau de pointeurs, et remet la structure à `MATRICE_VIDE`. Cette remise à zéro rend un second appel sans danger.

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

Le test de l’exercice 1 réussit donc les 16 vérifications, y compris les échecs d’allocation simulés. Le run GitHub Actions consulté pour le commit `7de469b` ne signale pas d’échec propre à `test_ex1`, mais le résumé détaillé Valgrind (`HEAP SUMMARY` et `All heap blocks were freed — no leaks are possible`) n’a pas été récupéré. Il reste à ajouter cette sortie réelle avant le rendu ; aucun résultat Valgrind n’est supposé ici.

### Questions de réflexion

**3.1 — Pourquoi `mat_detruire` reçoit-elle un pointeur vers `Matrice` ?**

Un pointeur permet à la fonction de modifier la structure détenue par l’appelant et de la remettre à `MATRICE_VIDE`. Avec un passage par valeur, seule une copie serait vidée ; la structure de l’appelant conserverait des pointeurs déjà libérés.

**3.2 — Combien d’allocations et de libérations sont nécessaires ?**

Pour une matrice de `n` lignes, l’allocation demande au maximum `n + 1` appels : un pour le tableau de pointeurs et un par ligne. Si l’allocation d’une ligne échoue, les lignes précédemment allouées et le tableau de pointeurs sont libérés avant le retour. À la destruction d’une matrice complète, on libère les `n` lignes puis le tableau de pointeurs, soit `n + 1` blocs.

**3.3 — Pourquoi un second appel à `mat_detruire` est-il sûr ? Que se passe-t-il avec une copie superficielle ?**

Après le premier appel, la structure est remise à `MATRICE_VIDE`, donc le second appel ne trouve plus de lignes à libérer. En revanche, une copie superficielle telle que `Matrice b = a` partage les mêmes pointeurs. Détruire les deux structures tenterait de libérer deux fois les mêmes blocs ; cette copie ne constitue pas une duplication indépendante de la matrice.

**3.4 — Pourquoi initialiser `*res` à `MATRICE_VIDE` au début de `mat_allouer` ?**

Cette initialisation garantit que chaque retour en erreur laisse un résultat dans un état connu et sûr. L’appelant peut ainsi tester ou détruire le résultat sans risquer d’utiliser des champs indéterminés ou une matrice partiellement construite.

## Déclaration de l’aide utilisée

Codex (assistant d’IA) a été utilisé pour clarifier les consignes, comprendre les diagnostics des tests et discuter de la vérification des dimensions, de l’allocation et du nettoyage en cas d’échec. Van Thanh a intégré les modifications dans le dépôt et a exécuté les commandes de compilation et les tests indiqués ci-dessus. Les autres contributions éventuelles devront être déclarées par leurs auteurs.

## Éléments à compléter par le groupe

- Ajouter les noms, comptes GitHub et contributions des autres membres.
- Compléter les exercices 2, 3 et 4 avec les explications, réponses demandées et sorties de tests correspondantes. À la date de cette version, Van Thanh indique ne pas avoir commencé l’exercice 3.
- Ajouter la sortie Valgrind réelle demandée par les consignes, dont le résumé du tas et la ligne confirmant l’absence de fuite.
- Compléter le compte rendu global des scénarios de démonstration et le bilan du groupe.
- Avant le rendu, vérifier le dépôt GitHub partagé, les contributions avec les comptes individuels, le tag `rendu`, puis déposer sur Célène le ZIP de ce tag ainsi que l’URL du dépôt et les 7 premiers caractères du commit. Échéance annoncée : lundi 2 novembre 2026 à 18 h ; rendre le dépôt public au plus tard le mardi 3 novembre 2026.