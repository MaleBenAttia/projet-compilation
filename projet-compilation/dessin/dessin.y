
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);
void genererCode(char* forme, int taille, int couleur);
%}

%union {
    int nombre;
    int couleur;
}

%token DRAW CIRCLE RECTANGLE TRIANGLE
%token OUVRIR_PAR FERMER_PAR VIRGULE
%token <nombre> NOMBRE
%token <couleur> COULEUR

%%

programme:
    instruction
    | programme instruction
    ;

instruction:
    DRAW CIRCLE OUVRIR_PAR NOMBRE VIRGULE COULEUR FERMER_PAR {
        genererCode("cercle", $4, $6);
        printf("Commande de dessin d'un cercle de taille %d et couleur %d reconnue\n", $4, $6);
    }
    | DRAW RECTANGLE OUVRIR_PAR NOMBRE VIRGULE COULEUR FERMER_PAR {
        genererCode("rectangle", $4, $6);
        printf("Commande de dessin d'un rectangle de taille %d et couleur %d reconnue\n", $4, $6);
    }
    | DRAW TRIANGLE OUVRIR_PAR NOMBRE VIRGULE COULEUR FERMER_PAR {
        genererCode("triangle", $4, $6);
        printf("Commande de dessin d'un triangle de taille %d et couleur %d reconnue\n", $4, $6);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erreur de parsing: %s\n", s);
    exit(1);
}

void genererCode(char* forme, int taille, int couleur) {
    FILE *fichier = fopen("dessin_genere.c", "w");
    
    // Écrire l'en-tête du fichier
    fprintf(fichier, "#include <SDL2/SDL.h>\n");
    fprintf(fichier, "#include <stdio.h>\n");
    fprintf(fichier, "#include <stdlib.h>\n");
    fprintf(fichier, "#include <math.h>\n\n");
    
    // Copier les fonctions utilitaires
    fprintf(fichier, "void dessinerRectangle(SDL_Renderer *renderer, SDL_Color couleur, int largeur, int hauteur) {\n");
    fprintf(fichier, "    SDL_SetRenderDrawColor(renderer, couleur.r, couleur.g, couleur.b, 255);\n");
    fprintf(fichier, "    SDL_Rect rect = {400 - largeur/2, 300 - hauteur/2, largeur, hauteur};\n");
    fprintf(fichier, "    SDL_RenderFillRect(renderer, &rect);\n");
    fprintf(fichier, "}\n\n");
    
    fprintf(fichier, "void dessinerTriangle(SDL_Renderer *renderer, SDL_Color couleur, int base, int hauteur) {\n");
    fprintf(fichier, "    SDL_SetRenderDrawColor(renderer, couleur.r, couleur.g, couleur.b, 255);\n");
    fprintf(fichier, "    // Centre du triangle en (400,300)\n");
    fprintf(fichier, "    int x1 = 400;\n");
    fprintf(fichier, "    int y1 = 300 - hauteur/2;\n");
    fprintf(fichier, "    int x2 = 400 - base/2;\n");
    fprintf(fichier, "    int y2 = 300 + hauteur/2;\n");
    fprintf(fichier, "    int x3 = 400 + base/2;\n");
    fprintf(fichier, "    int y3 = 300 + hauteur/2;\n");
    fprintf(fichier, "    SDL_RenderDrawLine(renderer, x1, y1, x2, y2);\n");
    fprintf(fichier, "    SDL_RenderDrawLine(renderer, x2, y2, x3, y3);\n");
    fprintf(fichier, "    SDL_RenderDrawLine(renderer, x3, y3, x1, y1);\n");
    fprintf(fichier, "}\n\n");
    
    fprintf(fichier, "void dessinerCercle(SDL_Renderer *renderer, SDL_Color couleur, int cx, int cy, int rayon) {\n");
    fprintf(fichier, "    SDL_SetRenderDrawColor(renderer, couleur.r, couleur.g, couleur.b, 255);\n");
    fprintf(fichier, "    for (int w = 0; w < rayon * 2; w++) {\n");
    fprintf(fichier, "        for (int h = 0; h < rayon * 2; h++) {\n");
    fprintf(fichier, "            int dx = rayon - w;\n");
    fprintf(fichier, "            int dy = rayon - h;\n");
    fprintf(fichier, "            if (dx * dx + dy * dy <= rayon * rayon) {\n");
    fprintf(fichier, "                SDL_RenderDrawPoint(renderer, cx + dx, cy + dy);\n");
    fprintf(fichier, "            }\n");
    fprintf(fichier, "        }\n");
    fprintf(fichier, "    }\n");
    fprintf(fichier, "}\n\n");
    
    fprintf(fichier, "SDL_Color choisirCouleur(int choix) {\n");
    fprintf(fichier, "    SDL_Color couleurs[] = {\n");
    fprintf(fichier, "        {0, 0, 0},       // noir\n");
    fprintf(fichier, "        {255, 0, 0},     // rouge\n");
    fprintf(fichier, "        {0, 255, 0},     // vert\n");
    fprintf(fichier, "        {255, 255, 0},   // jaune\n");
    fprintf(fichier, "        {0, 0, 255},     // bleu\n");
    fprintf(fichier, "        {255, 0, 255},   // magenta\n");
    fprintf(fichier, "        {0, 255, 255},   // cyan\n");
    fprintf(fichier, "        {255, 255, 255}  // blanc\n");
    fprintf(fichier, "    };\n");
    fprintf(fichier, "    if (choix >= 1 && choix <= 8)\n");
    fprintf(fichier, "        return couleurs[choix - 1];\n");
    fprintf(fichier, "    else\n");
    fprintf(fichier, "        return (SDL_Color){255, 255, 255};\n");
    fprintf(fichier, "}\n\n");
    
    // Fonction principale personnalisée en fonction des paramètres
    fprintf(fichier, "int main() {\n");
    fprintf(fichier, "    if (SDL_Init(SDL_INIT_VIDEO) != 0) {\n");
    fprintf(fichier, "        printf(\"Erreur SDL: %%s\\n\", SDL_GetError());\n");
    fprintf(fichier, "        return 1;\n");
    fprintf(fichier, "    }\n\n");
    
    fprintf(fichier, "    SDL_Window *window = SDL_CreateWindow(\"Dessin Automatique\",\n");
    fprintf(fichier, "                    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, 0);\n\n");
    
    fprintf(fichier, "    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);\n");
    fprintf(fichier, "    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);\n");
    fprintf(fichier, "    SDL_RenderClear(renderer);\n\n");
    
    fprintf(fichier, "    SDL_Color couleur = choisirCouleur(%d); // Couleur %d\n\n", couleur, couleur);
    
    // Code spécifique à la forme
    if (strcmp(forme, "cercle") == 0) {
        fprintf(fichier, "    // Dessiner un cercle de taille %d avec couleur %d\n", taille, couleur);
        fprintf(fichier, "    dessinerCercle(renderer, couleur, 400, 300, %d * 10);\n", taille);
    } else if (strcmp(forme, "rectangle") == 0) {
        fprintf(fichier, "    // Dessiner un rectangle de taille %d avec couleur %d\n", taille, couleur);
        fprintf(fichier, "    dessinerRectangle(renderer, couleur, %d * 30, %d * 20);\n", taille, taille);
    } else if (strcmp(forme, "triangle") == 0) {
        fprintf(fichier, "    // Dessiner un triangle de taille %d avec couleur %d\n", taille, couleur);
        fprintf(fichier, "    dessinerTriangle(renderer, couleur, %d * 30, %d * 20);\n", taille, taille);
    }
    
    fprintf(fichier, "\n    SDL_RenderPresent(renderer);\n\n");
    
    fprintf(fichier, "    SDL_Event e;\n");
    fprintf(fichier, "    int quit = 0;\n");
    fprintf(fichier, "    while (!quit) {\n");
    fprintf(fichier, "        while (SDL_PollEvent(&e)) {\n");
    fprintf(fichier, "            if (e.type == SDL_QUIT)\n");
    fprintf(fichier, "                quit = 1;\n");
    fprintf(fichier, "        }\n");
    fprintf(fichier, "    }\n\n");
    
    fprintf(fichier, "    SDL_DestroyRenderer(renderer);\n");
    fprintf(fichier, "    SDL_DestroyWindow(window);\n");
    fprintf(fichier, "    SDL_Quit();\n\n");
    
    fprintf(fichier, "    return 0;\n");
    fprintf(fichier, "}\n");
    
    fclose(fichier);
    printf("Code généré avec succès dans 'dessin_genere.c'\n");
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            perror(argv[1]);
            return 1;
        }
        yyin = f;
    }
    
    yyparse();
    return 0;
}
