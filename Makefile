CC     = gcc
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -g
TESTF  = -DMAT_TEST_ALLOC

all: demo_matrices test_ex1 test_ex2 test_ex3

demo_matrices: main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c $(wildcard *.h)
	$(CC) $(CFLAGS) main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c -o $@

test_ex1: test_ex1.c matrice.c matrice_alloc.c $(wildcard *.h)
	$(CC) $(CFLAGS) $(TESTF) test_ex1.c matrice.c matrice_alloc.c -o $@

test_ex2: test_ex2.c matrice.c matrice_alloc.c matrice_io.c $(wildcard *.h)
	$(CC) $(CFLAGS) $(TESTF) test_ex2.c matrice.c matrice_alloc.c matrice_io.c -o $@

test_ex3: test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c $(wildcard *.h)
	$(CC) $(CFLAGS) $(TESTF) test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c -o $@

tests: test_ex1 test_ex2 test_ex3
	./test_ex1
	./test_ex2
	./test_ex3

valgrind: test_ex1 test_ex2 test_ex3 demo_matrices
	valgrind --leak-check=full --error-exitcode=1 ./test_ex1
	valgrind --leak-check=full --error-exitcode=1 ./test_ex2
	valgrind --leak-check=full --error-exitcode=1 ./test_ex3
	valgrind --leak-check=full --error-exitcode=1 ./demo_matrices add donnees/A.txt donnees/B.txt R.txt

clean:
	rm -f *.o *.exe demo_matrices test_ex1 test_ex2 test_ex3 test_ex2_sortie.txt R.txt R2.txt

.PHONY: all tests valgrind clean
