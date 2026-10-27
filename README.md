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

Si l’allocation de la ligne `i` échoue, je libère les lignes `0` à `i - 1` déjà obtenues, puis le tableau de pointeurs, et je renvoie `MAT_ERR_ALLOCATION`. Aucune fuite n’est possible et `*res` reste vide. Le test avec `-DMAT_TEST_ALLOC` fait échouer chaque allocation tour à tour et le vérifie.

### 1.e — Finalisation de l’allocation

Quand toutes les allocations ont réussi, je remplis `*res` en dernier :

```c
res->coef = coef;
res->nb_lignes = nb_lignes;
res->nb_colonnes = nb_colonnes;
return MAT_OK;
```

Remplir `*res` seulement à la fin garantit qu’un échec ne laisse jamais une matrice à moitié construite : `*res` reste dans l’état vide initialisé au début de la fonction (code fourni).

### 1.f — Destruction

```c
if (m->coef != NULL) {
    for (int i = 0; i < m->nb_lignes; i++)
        free(m->coef[i]);
    free(m->coef);
}
```

Je libère d’abord chaque ligne, puis le tableau de pointeurs. L’ordre est important : libérer `m->coef` en premier rendrait les pointeurs `m->coef[i]` inaccessibles et provoquerait des fuites. La remise de `*m` à `MATRICE_VIDE` (fournie) rend un second appel sans danger.
