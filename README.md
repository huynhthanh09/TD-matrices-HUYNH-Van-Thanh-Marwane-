# TD Matrices — Compte rendu

INSA Centre Val de Loire — 3e année STI — Programmation C

> Version de travail mise à jour le 31 octobre 2026. Cette version documente les exercices 1, 2 et 3. Le compte rendu du groupe reste à compléter (exercice 4, bilan, Valgrind de l’exercice 3) avant le rendu.

## Membres du groupe

| Membre | GitHub | Travail documenté ici | Résultat des tests |
|---|---|---|---|
| HUYNH Van Thanh | [@huynhthanh09](https://github.com/huynhthanh09) | Exercice 1, étapes 1.a à 1.f (`matrice.c`, `matrice_alloc.c`) ; exercice 3, étapes 3.a à 3.h (`matrice_calcul.c`) ; réponses aux questions Q3.1 à Q3.4 et Q5.1 à Q5.4 | `test_ex1` : 16 / 16 ; `test_ex3` : 14 / 14 |
| Marwane Laanaya | [@LnyMarwane](https://github.com/LnyMarwane) | Exercice 2 (`matrice_io.c`) | À compléter |

### Avancement par exercice

| Exercice | Fichier(s) | Responsable | État | Test |
|---|---|---|---|---|
| 1 — Allocation et destruction | `matrice.c`, `matrice_alloc.c` | Van Thanh | Terminé | `test_ex1` : 16 / 16, Valgrind sans fuite |
| 2 — Entrées-sorties | `matrice_io.c` | Marwane | Explications et sortie de `test_ex2` à ajouter | À compléter |
| 3 — Calcul matriciel | `matrice_calcul.c` | Van Thanh | Terminé | `test_ex3` : 14 / 14, Valgrind à ajouter |
| 4 — Démonstration complète | `main.c` | Marwane | À compléter | À compléter |

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

Valgrind n’existant pas sous Windows, la vérification mémoire a été faite sous Linux (Valgrind 3.22.0), sur les fichiers de l’exercice 1 de ce dépôt (`matrice.c`, `matrice_alloc.c`) avec la commande `valgrind --leak-check=full ./test_ex1`. Extrait du rapport :

```text
==196== HEAP SUMMARY:
==196==     in use at exit: 0 bytes in 0 blocks
==196==   total heap usage: 11 allocs, 11 frees, 4,300 bytes allocated
==196==
==196== All heap blocks were freed -- no leaks are possible
==196==
==196== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Les 11 allocations correspondent à 11 libérations : aucune fuite, y compris dans les scénarios d’échec d’allocation simulés.

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

### Questions de l’exercice 2

**Question 1**

`mat_lire` remplit d’abord une matrice locale avant de l’affecter à `*res`, afin de respecter la règle R3 de la bibliothèque : si une fonction échoue, le paramètre de sortie `*res` doit rester dans un état sûr (`MATRICE_VIDE`), sans fuite de mémoire. Si la lecture échoue au milieu du fichier, seule la matrice locale est détruite ; l’appelant ne reçoit jamais une matrice à moitié remplie.

**Question 2**

Non. `mat_lire` appelle `lire_entier`, qui utilise `fscanf` avec `%31s` puis `strtol` : elle consomme les entiers les uns après les autres. En C, les fonctions de lecture formatée de la bibliothèque standard traitent les espaces, les tabulations et les sauts de ligne (`\n`) comme de simples séparateurs. La mise en forme du fichier n’est donc pas gênante.

**Question 3**

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

**Question 4**

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

Vérification mémoire : la sortie réelle de `valgrind --leak-check=full ./test_ex3`, exécuté sous Linux sur le `matrice_calcul.c` final du dépôt, reste à ajouter ici (le test pose la question de l’absence de fuite ; les chemins d’erreur avec `mat_detruire(&r)` sont ceux à surveiller).

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

## Déclaration de l’aide utilisée

Codex (assistant d’IA) a été utilisé pour clarifier les consignes, examiner les diagnostics des tests et discuter de la vérification des dimensions, de l’allocation et du nettoyage en cas d’échec. Claude (assistant d’IA) a été utilisé pour relire le code de l’exercice 1, pour expliquer la démarche de l’exercice 3 étape par étape (3.a à 3.h) et proposer les extraits de code correspondants, que Van Thanh a intégrés dans `matrice_calcul.c`, compilés et testés, pour lancer Valgrind sous Linux sur l’exercice 1, et pour rédiger et mettre en forme les parties de ce compte rendu consacrées aux exercices 1 et 3. Van Thanh a intégré les modifications dans le dépôt et a exécuté les commandes de compilation et les tests indiqués dans ce compte rendu, sauf la commande Valgrind de l’exercice 1, exécutée sous Linux comme indiqué plus haut. Chaque autre membre devra déclarer l’aide qu’il a reçue pour sa propre contribution.

## Éléments restant à compléter par le groupe

- Ajouter, pour l’exercice 2, l’explication des étapes 2.a à 2.f avec le code correspondant, et la sortie réelle de `test_ex2`.
- Ajouter la sortie réelle de `valgrind --leak-check=full ./test_ex3` avec le résumé du tas et la confirmation d’absence de fuite (Linux ou GitHub Actions), puis celle de `demo_matrices` pour l’exercice 4.
- Exercice 4 (`main.c`, Marwane) : explications, scénarios de démonstration, réponses aux questions Q6.1 à Q6.3 et résultats de tests.
- Ajouter le bilan global du groupe avant le rendu final.
- Avant le rendu, créer le tag `rendu` sur le commit final et pousser ce tag. Déposer sur Célène le ZIP du dépôt au tag `rendu`, l’adresse du dépôt GitHub et les 7 premiers caractères du commit. Date limite annoncée : lundi 2 novembre 2026 à 18 h. Le dépôt GitHub doit être public au plus tard le mardi 3 novembre 2026.
