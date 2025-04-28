%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Table des symboles
struct symbol {
    char *name;
    int value;
};

#define MAX_SYMBOLS 100
struct symbol symbols[MAX_SYMBOLS];
int symbol_count = 0;

// Forward declarations
void set_symbol_value(char *name, int value);

// Fonctions pour la table des symboles
int get_symbol_value(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            return symbols[i].value;
        }
    }
    // Initialize undefined variables with 0 automatically
    printf("Initialisation automatique de la variable: %s\n", name);
    set_symbol_value(name, 0);
    return 0; // Valeur par défaut si non trouvé
}

void set_symbol_value(char *name, int value) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            symbols[i].value = value;
            return;
        }
    }
    // Nouveau symbole
    if (symbol_count < MAX_SYMBOLS) {
        symbols[symbol_count].name = strdup(name);
        symbols[symbol_count].value = value;
        symbol_count++;
    }
}

// SDL et fonctions de dessin
#include <SDL2/SDL.h>
SDL_Window *window = NULL;
SDL_Renderer *renderer = NULL;

void init_sdl() {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "Erreur SDL_Init: %s\n", SDL_GetError());
        exit(1);
    }
    
    window = SDL_CreateWindow("Programme Fusion",
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, 0);
    if (!window) {
        fprintf(stderr, "Erreur SDL_CreateWindow: %s\n", SDL_GetError());
        SDL_Quit();
        exit(1);
    }
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        fprintf(stderr, "Erreur SDL_CreateRenderer: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        exit(1);
    }
    
    // Fond blanc
    SDL_SetRenderDrawColor(renderer, 0,0, 0, 0);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);
}

SDL_Color get_color(int color_id) {
    SDL_Color colors[] = {
        {0, 0, 0},       // noir (1)
        {255, 0, 0},     // rouge (2)
        {0, 255, 0},     // vert (3)
        {255, 255, 0},   // jaune (4)
        {0, 0, 255},     // bleu (5)
        {255, 0, 255},   // magenta (6)
        {0, 255, 255},   // cyan (7)
        {255, 255, 255}  // blanc (8)
    };
    
    if (color_id >= 1 && color_id <= 8)
        return colors[color_id - 1];
    return (SDL_Color){0, 0, 0}; // noir par défaut
}

void draw_circle(int size, int color_id) {
    SDL_Color color = get_color(color_id);
    int radius = size * 10;
    int cx = 400, cy = 300; // Centre de l'écran
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
    
    for (int w = 0; w < radius * 2; w++) {
        for (int h = 0; h < radius * 2; h++) {
            int dx = radius - w;
            int dy = radius - h;
            if (dx * dx + dy * dy <= radius * radius) {
                SDL_RenderDrawPoint(renderer, cx + dx, cy + dy);
            }
        }
    }
    
    SDL_RenderPresent(renderer);
    printf("Cercle dessiné, taille %d, couleur %d\n", size, color_id);
}

void draw_rectangle(int size, int color_id) {
    SDL_Color color = get_color(color_id);
    int width = size * 30;
    int height = size * 20;
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
    SDL_Rect rect = {400 - width/2, 300 - height/2, width, height};
    SDL_RenderFillRect(renderer, &rect);
    
    SDL_RenderPresent(renderer);
    printf("Rectangle dessiné, taille %d, couleur %d\n", size, color_id);
}

void draw_triangle(int size, int color_id) {
    SDL_Color color = get_color(color_id);
    int base = size * 30;
    int height = size * 20;
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
    
    // Centre du triangle en (400,300)
    int x1 = 400;
    int y1 = 300 - height/2;
    int x2 = 400 - base/2;
    int y2 = 300 + height/2;
    int x3 = 400 + base/2;
    int y3 = 300 + height/2;
    
    SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    SDL_RenderDrawLine(renderer, x2, y2, x3, y3);
    SDL_RenderDrawLine(renderer, x3, y3, x1, y1);
    
    SDL_RenderPresent(renderer);
    printf("Triangle dessiné, taille %d, couleur %d\n", size, color_id);
}

void wait_for_quit() {
    SDL_Event e;
    int quit = 0;
    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT)
                quit = 1;
        }
        SDL_Delay(100); // Économiser le CPU
    }
}

void cleanup_sdl() {
    if (renderer) SDL_DestroyRenderer(renderer);
    if (window) SDL_DestroyWindow(window);
    SDL_Quit();
}

// Partie pour le langage de programmation
typedef enum { 
    INSTR_PRINT, 
    INSTR_ASSIGN, 
    INSTR_IF, 
    INSTR_WHILE,
    INSTR_EXPR,
    INSTR_DRAW_CIRCLE,
    INSTR_DRAW_RECTANGLE,
    INSTR_DRAW_TRIANGLE
} InstrType;

typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_NEG,
    OP_EQ, OP_NE, OP_LT, OP_GT, OP_LE, OP_GE,
    OP_VAR, OP_NUM
} OpType;

struct Expression {
    OpType op;
    union {
        struct {
            struct Expression *left;
            struct Expression *right;
        } binary;
        struct Expression *expr;  // Pour l'opérateur unaire
        int value;               // Pour les constantes
        char *var_name;          // Pour les variables
    } data;
};

struct Instruction {
    InstrType type;
    union {
        struct Expression *expr;  // Pour PRINT et EXPR
        struct {
            char *var_name;
            struct Expression *expr;
        } assign;
        struct {
            struct Expression *condition;
            struct Instruction **if_block;
            int if_block_size;
            struct Instruction **else_block;
            int else_block_size;
        } if_stmt;
        struct {
            struct Expression *condition;
            struct Instruction **block;
            int block_size;
        } while_stmt;
        struct {
            int size;
            int color;
        } draw;
    } data;
};

// Tableau global pour stocker les instructions du programme
struct Instruction **program_instructions = NULL;
int instruction_count = 0;

// Variables globales pour la gestion des blocs
struct Instruction **temp_block = NULL;
int temp_block_size = 0;

// Fonctions pour la création d'expressions et d'instructions
struct Expression* create_number_expr(int value) {
    struct Expression *expr = malloc(sizeof(struct Expression));
    expr->op = OP_NUM;
    expr->data.value = value;
    return expr;
}

struct Expression* create_variable_expr(char *name) {
    struct Expression *expr = malloc(sizeof(struct Expression));
    expr->op = OP_VAR;
    expr->data.var_name = strdup(name);
    return expr;
}

struct Expression* create_binary_expr(OpType op, struct Expression *left, struct Expression *right) {
    struct Expression *expr = malloc(sizeof(struct Expression));
    expr->op = op;
    expr->data.binary.left = left;
    expr->data.binary.right = right;
    return expr;
}

struct Expression* create_unary_expr(OpType op, struct Expression *operand) {
    struct Expression *expr = malloc(sizeof(struct Expression));
    expr->op = op;
    expr->data.expr = operand;
    return expr;
}

struct Instruction* create_print_instr(struct Expression *expr) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_PRINT;
    instr->data.expr = expr;
    return instr;
}

struct Instruction* create_assign_instr(char *var_name, struct Expression *expr) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_ASSIGN;
    instr->data.assign.var_name = strdup(var_name);
    instr->data.assign.expr = expr;
    return instr;
}

struct Instruction* create_if_instr(struct Expression *condition, 
                                   struct Instruction **if_block, int if_block_size,
                                   struct Instruction **else_block, int else_block_size) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_IF;
    instr->data.if_stmt.condition = condition;
    instr->data.if_stmt.if_block = if_block;
    instr->data.if_stmt.if_block_size = if_block_size;
    instr->data.if_stmt.else_block = else_block;
    instr->data.if_stmt.else_block_size = else_block_size;
    return instr;
}

struct Instruction* create_while_instr(struct Expression *condition, 
                                     struct Instruction **block, int block_size) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_WHILE;
    instr->data.while_stmt.condition = condition;
    instr->data.while_stmt.block = block;
    instr->data.while_stmt.block_size = block_size;
    return instr;
}

struct Instruction* create_expr_instr(struct Expression *expr) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_EXPR;
    instr->data.expr = expr;
    return instr;
}

struct Instruction* create_draw_circle_instr(int size, int color) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_DRAW_CIRCLE;
    instr->data.draw.size = size;
    instr->data.draw.color = color;
    return instr;
}

struct Instruction* create_draw_rectangle_instr(int size, int color) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_DRAW_RECTANGLE;
    instr->data.draw.size = size;
    instr->data.draw.color = color;
    return instr;
}

struct Instruction* create_draw_triangle_instr(int size, int color) {
    struct Instruction *instr = malloc(sizeof(struct Instruction));
    instr->type = INSTR_DRAW_TRIANGLE;
    instr->data.draw.size = size;
    instr->data.draw.color = color;
    return instr;
}

// Fonctions pour la gestion des blocs
struct Instruction** new_block() {
    temp_block = NULL;
    temp_block_size = 0;
    return temp_block;
}

void add_to_block(struct Instruction *instr) {
    temp_block = realloc(temp_block, (temp_block_size + 1) * sizeof(struct Instruction*));
    temp_block[temp_block_size++] = instr;
}

void add_instruction(struct Instruction *instr) {
    program_instructions = realloc(program_instructions, (instruction_count + 1) * sizeof(struct Instruction*));
    program_instructions[instruction_count++] = instr;
}

int evaluate_expr(struct Expression *expr) {
    if (!expr) return 0;
    
    switch (expr->op) {
        case OP_NUM:
            return expr->data.value;
        case OP_VAR:
            return get_symbol_value(expr->data.var_name);
        case OP_ADD:
            return evaluate_expr(expr->data.binary.left) + evaluate_expr(expr->data.binary.right);
        case OP_SUB:
            return evaluate_expr(expr->data.binary.left) - evaluate_expr(expr->data.binary.right);
        case OP_MUL:
            return evaluate_expr(expr->data.binary.left) * evaluate_expr(expr->data.binary.right);
        case OP_DIV: {
            int divisor = evaluate_expr(expr->data.binary.right);
            if (divisor == 0) {
                fprintf(stderr, "Erreur: Division par zéro\n");
                return 0;
            }
            return evaluate_expr(expr->data.binary.left) / divisor;
        }
        case OP_NEG:
            return -evaluate_expr(expr->data.expr);
        case OP_EQ:
            return evaluate_expr(expr->data.binary.left) == evaluate_expr(expr->data.binary.right);
        case OP_NE:
            return evaluate_expr(expr->data.binary.left) != evaluate_expr(expr->data.binary.right);
        case OP_LT:
            return evaluate_expr(expr->data.binary.left) < evaluate_expr(expr->data.binary.right);
        case OP_GT:
            return evaluate_expr(expr->data.binary.left) > evaluate_expr(expr->data.binary.right);
        case OP_LE:
            return evaluate_expr(expr->data.binary.left) <= evaluate_expr(expr->data.binary.right);
        case OP_GE:
            return evaluate_expr(expr->data.binary.left) >= evaluate_expr(expr->data.binary.right);
        default:
            fprintf(stderr, "Opérateur inconnu\n");
            return 0;
    }
}

void execute_instructions(struct Instruction **instructions, int count) {
    for (int i = 0; i < count; i++) {
        struct Instruction *instr = instructions[i];
        if (!instr) continue;
        
        switch (instr->type) {
            case INSTR_PRINT:
                printf("Print: %d\n", evaluate_expr(instr->data.expr));
                break;
            case INSTR_ASSIGN:
                set_symbol_value(instr->data.assign.var_name, evaluate_expr(instr->data.assign.expr));
                break;
            case INSTR_EXPR:
                printf("Résultat: %d\n", evaluate_expr(instr->data.expr));
                break;
            case INSTR_IF:
                if (evaluate_expr(instr->data.if_stmt.condition)) {
                    execute_instructions(instr->data.if_stmt.if_block, instr->data.if_stmt.if_block_size);
                } else if (instr->data.if_stmt.else_block) {
                    execute_instructions(instr->data.if_stmt.else_block, instr->data.if_stmt.else_block_size);
                }
                break;
            case INSTR_WHILE: {
                while (evaluate_expr(instr->data.while_stmt.condition)) {
                    execute_instructions(instr->data.while_stmt.block, instr->data.while_stmt.block_size);
                }
                break;
            }
            case INSTR_DRAW_CIRCLE:
                draw_circle(instr->data.draw.size, instr->data.draw.color);
                break;
            case INSTR_DRAW_RECTANGLE:
                draw_rectangle(instr->data.draw.size, instr->data.draw.color);
                break;
            case INSTR_DRAW_TRIANGLE:
                draw_triangle(instr->data.draw.size, instr->data.draw.color);
                break;
        }
    }
}

void free_expr(struct Expression *expr) {
    if (!expr) return;
    
    switch (expr->op) {
        case OP_VAR:
            free(expr->data.var_name);
            break;
        case OP_ADD:
        case OP_SUB:
        case OP_MUL:
        case OP_DIV:
        case OP_EQ:
        case OP_NE:
        case OP_LT:
        case OP_GT:
        case OP_LE:
        case OP_GE:
            free_expr(expr->data.binary.left);
            free_expr(expr->data.binary.right);
            break;
        case OP_NEG:
            free_expr(expr->data.expr);
            break;
        default:
            break;
    }
    free(expr);
}

void free_instruction(struct Instruction *instr) {
    if (!instr) return;
    
    switch (instr->type) {
        case INSTR_PRINT:
        case INSTR_EXPR:
            free_expr(instr->data.expr);
            break;
        case INSTR_ASSIGN:
            free(instr->data.assign.var_name);
            free_expr(instr->data.assign.expr);
            break;
        case INSTR_IF:
            free_expr(instr->data.if_stmt.condition);
            for (int i = 0; i < instr->data.if_stmt.if_block_size; i++) {
                free_instruction(instr->data.if_stmt.if_block[i]);
            }
            free(instr->data.if_stmt.if_block);
            if (instr->data.if_stmt.else_block) {
                for (int i = 0; i < instr->data.if_stmt.else_block_size; i++) {
                    free_instruction(instr->data.if_stmt.else_block[i]);
                }
                free(instr->data.if_stmt.else_block);
            }
            break;
        case INSTR_WHILE:
            free_expr(instr->data.while_stmt.condition);
            for (int i = 0; i < instr->data.while_stmt.block_size; i++) {
                free_instruction(instr->data.while_stmt.block[i]);
            }
            free(instr->data.while_stmt.block);
            break;
        case INSTR_DRAW_CIRCLE:
        case INSTR_DRAW_RECTANGLE:
        case INSTR_DRAW_TRIANGLE:
            // Pas de libération spécifique pour ces types
            break;
    }
    free(instr);
}

void yyerror(const char *s) {
    fprintf(stderr, "Erreur: %s\n", s);
}

extern int yylex();
extern int yyparse();
extern FILE *yyin;

%}

%union {
    int num;
    int color_val;
    char *str;
    struct Expression *expr;
    struct Instruction *instr;
    struct {
        struct Instruction **block;
        int size;
    } block;
}

/* Tokens pour le langage de programmation */
%token <num> NUMBER
%token <str> IDENTIFIER
%token IF ELSE WHILE PRINT
%token EQ NE LE GE

/* Tokens pour le langage de dessin */
%token DRAW CIRCLE RECTANGLE TRIANGLE
%token <color_val> COULEUR

%type <expr> expr condition
%type <instr> statement
%type <block> statements if_statement

/* Définir la priorité et l'associativité des opérateurs */
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%right UMINUS

/* Résoudre le conflit dangling else */
%nonassoc IFX
%nonassoc ELSE

%%

program:
    statements {
        // Stocker les instructions du programme
        program_instructions = $1.block;
        instruction_count = $1.size;
    }
    ;

statements:
    /* vide */ {
        $$.block = NULL;
        $$.size = 0;
    }
    | statements statement {
        // Ajouter l'instruction au bloc
        struct Instruction **new_block = realloc($1.block, ($1.size + 1) * sizeof(struct Instruction*));
        if (new_block) {
            $1.block = new_block;
            $1.block[$1.size] = $2;
            $1.size++;
        }
        $$ = $1;
    }
    ;

statement:
    expr ';' {
        $$ = create_expr_instr($1);
    }
    | PRINT expr ';' {
        $$ = create_print_instr($2);
    }
    | IDENTIFIER '=' expr ';' {
        $$ = create_assign_instr($1, $3);
        free($1);
    }
    | if_statement {
        $$ = $1.block[0]; // Prendre la première instruction du bloc
        free($1.block);   // Libérer le tableau mais pas les instructions
    }
    | WHILE '(' condition ')' '{' statements '}' {
        $$ = create_while_instr($3, $6.block, $6.size);
    }
    | DRAW CIRCLE '(' expr ',' COULEUR ')' ';' {
        int size = evaluate_expr($4);
        free_expr($4);
        $$ = create_draw_circle_instr(size, $6);
    }
    | DRAW RECTANGLE '(' expr ',' COULEUR ')' ';' {
        int size = evaluate_expr($4);
        free_expr($4);
        $$ = create_draw_rectangle_instr(size, $6);
    }
    | DRAW TRIANGLE '(' expr ',' COULEUR ')' ';' {
        int size = evaluate_expr($4);
        free_expr($4);
        $$ = create_draw_triangle_instr(size, $6);
    }
    ;

if_statement:
    IF '(' condition ')' '{' statements '}' %prec IFX {
        struct Instruction *if_instr = create_if_instr($3, $6.block, $6.size, NULL, 0);
        $$.block = malloc(sizeof(struct Instruction*));
        $$.block[0] = if_instr;
        $$.size = 1;
    }
    | IF '(' condition ')' '{' statements '}' ELSE '{' statements '}' {
        struct Instruction *if_instr = create_if_instr($3, $6.block, $6.size, $10.block, $10.size);
        $$.block = malloc(sizeof(struct Instruction*));
        $$.block[0] = if_instr;
        $$.size = 1;
    }
    ;

condition:
    expr EQ expr { $$ = create_binary_expr(OP_EQ, $1, $3); }
    | expr NE expr { $$ = create_binary_expr(OP_NE, $1, $3); }
    | expr '<' expr { $$ = create_binary_expr(OP_LT, $1, $3); }
    | expr '>' expr { $$ = create_binary_expr(OP_GT, $1, $3); }
    | expr LE expr { $$ = create_binary_expr(OP_LE, $1, $3); }
    | expr GE expr { $$ = create_binary_expr(OP_GE, $1, $3); }
    | expr { $$ = $1; } /* Allow any expression as a condition */
    ;

expr:
    NUMBER { $$ = create_number_expr($1); }
    | IDENTIFIER { $$ = create_variable_expr($1); free($1); }
    | expr '+' expr { $$ = create_binary_expr(OP_ADD, $1, $3); }
    | expr '-' expr { $$ = create_binary_expr(OP_SUB, $1, $3); }
    | expr '*' expr { $$ = create_binary_expr(OP_MUL, $1, $3); }
    | expr '/' expr { $$ = create_binary_expr(OP_DIV, $1, $3); }
    | '-' expr %prec UMINUS { $$ = create_unary_expr(OP_NEG, $2); }
    | '(' expr ')' { $$ = $2; }
    ;

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Impossible d'ouvrir le fichier");
            return 1;
        }
    } else {
        printf("Usage: %s fichier.dessin\n", argv[0]);
        return 1;
    }
    
    // Initialiser SDL
    init_sdl();
    
    // Analyser le programme
    yyparse();
    
    // Exécuter le programme
    execute_instructions(program_instructions, instruction_count);
    
    // Attendre que l'utilisateur ferme la fenêtre
    wait_for_quit();
    
    // Libérer la mémoire
    for (int i = 0; i < instruction_count; i++) {
        free_instruction(program_instructions[i]);
    }
    free(program_instructions);
    
    // Libérer la mémoire utilisée par les symboles
    for (int i = 0; i < symbol_count; i++) {
        free(symbols[i].name);
    }
    
    // Nettoyer SDL
    cleanup_sdl();
    
    if (yyin != stdin) {
        fclose(yyin);
    }
    
    return 0;
}
