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

Dans `mat_message_erreur` (`matrice.c`), les codes `MAT_ERR_DIMENSIONS` et `MAT_ERR_DEPASSEMENT` n’avaient pas de `case` : ils tombaient dans le cas par défaut et renvoyaient « erreur inconnue ». Je les ai ajoutés sur le modèle des autres cas :

```c
case MAT_ERR_DIMENSIONS:  return "dimensions incompatibles";
case MAT_ERR_DEPASSEMENT: return "dépassement de capacité";
```

Ces messages seront réutilisés par `main.c`, par exemple pour l’addition de deux matrices de tailles différentes. `test_ex1` vérifie que les deux messages sont différents de « erreur inconnue ».

### 1.b — Validité d’une matrice

`mat_est_valide` renvoie `1` si les quatre conditions suivantes sont vraies, `0` sinon : `m` n’est pas `NULL`, `m->coef` n’est pas `NULL`, `1 <= nb_lignes <= MAT_DIM_MAX` et `1 <= nb_colonnes <= MAT_DIM_MAX`.

```c
return m != NULL
    && m->coef != NULL
    && m->nb_lignes >= 1 && m->nb_lignes <= MAT_DIM_MAX
    && m->nb_colonnes >= 1 && m->nb_colonnes <= MAT_DIM_MAX;
```

L’opérateur `&&` s’arrête dès qu’une condition est fausse. Le test `m != NULL` est donc placé en premier : on ne lit jamais `m->coef` quand `m` vaut `NULL`. Les tests vérifient qu’une matrice `1 x 2` est valide, et que `NULL`, `MATRICE_VIDE` et une matrice à zéro ligne ne le sont pas.

### 1.c — Vérification des dimensions

Les lignes vérifiant `res` et initialisant `*res` à `MATRICE_VIDE` étaient fournies. J’ai ajouté le contrôle des deux dimensions : elles doivent être comprises entre `1` et `MAT_DIM_MAX`, bornes incluses.

```c
if (nb_lignes < 1 || nb_lignes > MAT_DIM_MAX
    || nb_colonnes < 1 || nb_colonnes > MAT_DIM_MAX)
    return MAT_ERR_ARGUMENT;
```

En cas de dimension invalide, la fonction renvoie `MAT_ERR_ARGUMENT` et `*res` reste à `MATRICE_VIDE`, car aucune allocation n’a encore eu lieu.

### 1.d — Allocation des lignes

Le tableau de `nb_lignes` pointeurs était fourni. J’ai écrit l’allocation de chaque ligne avec `mat_calloc`, donc tous les coefficients valent `0` :

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

Si l’allocation de la ligne `i` échoue, je