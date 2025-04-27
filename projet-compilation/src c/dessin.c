#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define LARGEUR 80
#define HAUTEUR 40

void initialiserGrille(char grille[HAUTEUR][LARGEUR]) {
    for (int i = 0; i < HAUTEUR; i++) {
        for (int j = 0; j < LARGEUR; j++) {
            grille[i][j] = ' ';
        }
    }
}

void afficherGrille(char grille[HAUTEUR][LARGEUR]) {
    for (int i = 0; i < HAUTEUR; i++) {
        for (int j = 0; j < LARGEUR; j++) {
            printf("%c", grille[i][j]);
        }
        printf("\n");
    }
}

void dessinerCercle(char grille[HAUTEUR][LARGEUR], int xc, int yc, int rayon) {
    for (int y = 0; y < HAUTEUR; y++) {
        for (int x = 0; x < LARGEUR; x++) {
            float dx = (x - xc);
            float dy = (y - yc) * 2.0;  // Correction d'aspect terminal
            float distance = sqrt(dx * dx + dy * dy);
            if (distance >= rayon - 0.5 && distance <= rayon + 0.5) {
                if (y >= 0 && y < HAUTEUR && x >= 0 && x < LARGEUR)
                    grille[y][x] = '*';
            }
        }
    }
}

void dessinerLigne(char grille[HAUTEUR][LARGEUR], int x1, int y1, int x2, int y2) {
    int dx = abs(x2 - x1), dy = abs(y2 - y1);
    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;
    int err = dx - dy, e2;

    while (1) {
        if (x1 >= 0 && x1 < LARGEUR && y1 >= 0 && y1 < HAUTEUR)
            grille[y1][x1] = '*';
        if (x1 == x2 && y1 == y2) break;
        e2 = 2 * err;
        if (e2 > -dy) { err -= dy; x1 += sx; }
        if (e2 < dx) { err += dx; y1 += sy; }
    }
}

void dessinerTriangle(char grille[HAUTEUR][LARGEUR], int x1, int y1, int x2, int y2, int x3, int y3) {
    dessinerLigne(grille, x1, y1, x2, y2);
    dessinerLigne(grille, x2, y2, x3, y3);
    dessinerLigne(grille, x3, y3, x1, y1);
}

void dessinerRectangle(char grille[HAUTEUR][LARGEUR], int x, int y, int largeur, int hauteur) {
    dessinerLigne(grille, x, y, x + largeur, y);
    dessinerLigne(grille, x + largeur, y, x + largeur, y + hauteur);
    dessinerLigne(grille, x + largeur, y + hauteur, x, y + hauteur);
    dessinerLigne(grille, x, y + hauteur, x, y);
}

int main() {
    char grille[HAUTEUR][LARGEUR];
    int choix;
    printf("Choisissez une forme à dessiner :\n");
    printf("1. Cercle\n");
    printf("2. Triangle\n");
    printf("3. Rectangle\n");
    printf("Votre choix : ");
    scanf("%d", &choix);

    initialiserGrille(grille);

    if (choix == 1) {
        int xc, yc, rayon;
        printf("Centre (x y) et rayon : ");
        scanf("%d %d %d", &xc, &yc, &rayon);
        dessinerCercle(grille, xc, yc, rayon);
    }
    else if (choix == 2) {
        int x1, y1, x2, y2, x3, y3;
        printf("Coordonnées des 3 sommets : ");
        scanf("%d %d %d %d %d %d", &x1, &y1, &x2, &y2, &x3, &y3);
        dessinerTriangle(grille, x1, y1, x2, y2, x3, y3);
    }
    else if (choix == 3) {
        int x, y, l, h;
        printf("Coin supérieur gauche (x y), largeur, hauteur : ");
        scanf("%d %d %d %d", &x, &y, &l, &h);
        dessinerRectangle(grille, x, y, l, h);
    }
    else {
        printf("Choix invalide.\n");
        return 1;
    }

    afficherGrille(grille);
    return 0;
}

