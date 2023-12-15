%{
#include <stdio.h>
#include <stdlib.h>

typedef struct class {
    char* name;
}class;

int class_num = 0;
int obj_num[100] = {0};
class *classes;

%}

%s CLASS_STATE NEW_OBJ_STATE

%%
<INITIAL>class   {  
                    BEGIN(CLASS_STATE); 
                    class_num++;
                    if(class_num == 1)
                        classes = (class *)malloc(sizeof(class));
                    else 
                        classes = (class *)realloc(classes, class_num * sizeof(class));

                    if (classes == NULL) {
                        fprintf(stderr, "Memory allocation failed\n");
                        return 1;
                    }
                 }

<CLASS_STATE>[a-zA-Z]+   {  
                            classes[class_num - 1].name = (char *)malloc((yyleng + 1) * sizeof(char));
                            strcpy(classes[class_num - 1].name, yytext);
                            BEGIN(INITIAL); 
                         }

<INITIAL>new     {  
                    BEGIN(NEW_OBJ_STATE);
                 }

<NEW_OBJ_STATE>[a-zA-Z]+    {  
                                for (int i = 0; i < class_num; i++) {
                                    if(strcmp(classes[i].name, yytext) == 0)
                                        obj_num[i]++;
                                }
                                // printf("%s\n", yytext);
                                BEGIN(INITIAL); 
                            }

.|\n    { }
%%

int yywrap() {
    return 1; // indicate that there are no more files to parse
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s input_file\n", argv[0]);
        return 1;
    }

    FILE *inputFile = fopen(argv[1], "r");
    if (!inputFile) {
        perror("Error opening file");
        return 1;
    }

    yyin = inputFile; // Set the input file for Flex

    yylex(); // Start lexical analysis

    printf("Clase %d: ", class_num);

    for (int i = 0; i < class_num; i++) {
        printf("%s ", classes[i].name);
    }

    printf("\n");

    for (int i = 0; i < class_num; i++) {
        printf("Obiecte %s: %d\n", classes[i].name, obj_num[i]);
    }

    for (int i = 0; i < class_num; i++) {
        printf("%s: \n", classes[i].name);
    }

    // Free allocated memory
    for (int i = 0; i < class_num; i++) {
        free(classes[i].name);
    }
    free(classes);

    fclose(inputFile);
    return 0;
}
