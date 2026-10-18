# TD Matrices — Compte rendu

INSA Centre Val de Loire — 3e année STI — Programmation C

| Membre | GitHub | Travail réalisé |
|---|---|---|
| Nom Prénom | @huynhthanh09 | ... |

## Exercice 1 — Allocation et destruction
#### (1.a) Messages d'erreur

Dans `mat_message_erreur` (matrice.c), il manquait les cas `MAT_ERR_DIMENSIONS` et `MAT_ERR_DEPASSEMENT` : ils tombaient dans le `default` et renvoyaient « erreur inconnue ». Je les ai ajoutés sur le modèle des autres :

```c
case MAT_ERR_DIMENSIONS:  return "dimensions incompatibles";
case MAT_ERR_DEPASSEMENT: return "dépassement de capacité";
```

Ces messages sont réutilisés plus tard par `main.c` (scénario 3 : addition de matrices de tailles différentes). Résultat de `./test_ex1` :

```
[OK]    (1.a) message pour MAT_ERR_DIMENSIONS
[OK]    (1.a) message pour MAT_ERR_DEPASSEMENT
```
