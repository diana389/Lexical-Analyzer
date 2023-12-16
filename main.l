%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <ctype.h>

    typedef struct attr {
        char* name;
        bool GetMethod;
        bool SetMethod;
    }attr;

    typedef struct class {
        char* name;
        attr* attributes;
        int attr_num;
        int obj_num;
    }class;

    int class_num = 0;
    int pubic_class_num = 0;
    class *classes;
    char **objects;
    int total_obj_num = 0;

    char* getLastWord(char *sentence) {
        // Create a copy of the sentence as strtok modifies the input
        char *lastWord = (char*)malloc(100 * sizeof(char));

        // Tokenize the sentence
        char *token = strtok(sentence, " \t\n");

        // Find the last token
        while (token != NULL) {
            strcpy(lastWord, token);
            token = strtok(NULL, " \t\n");
        }

        lastWord[strlen(lastWord) - 1] = '\0';

        return lastWord;
    }

    void extractAttrFromMethod(char *method) {
        strcpy(method, method + 3);
        method[0] = tolower(method[0]);
    }

    void addSetMethodToAttr(char *method) {
        for(int i = 0; i < class_num; i++) {
            for(int j = 0; j < classes[i].attr_num; j++) {
                if(strcmp(classes[i].attributes[j].name, method) == 0) {
                    classes[i].attributes[j].GetMethod = true;
                }
            }
        }
    }

    void addGetMethodToAttr(char *method) {
        for(int i = 0; i < class_num; i++) {
            for(int j = 0; j < classes[i].attr_num; j++) {
                if(strcmp(classes[i].attributes[j].name, method) == 0) {
                    classes[i].attributes[j].SetMethod = true;
                }
            }
        }
    }

    void addObject(char *object) {
        printf("%s\n", object);
        for(int i = 0; i < class_num; i++) {
            if(strcmp(classes[i].name, object) == 0) {
                printf("Obiectul %s este de tipul %s\n", object, classes[i].name);
                classes[i].obj_num++;
            }
        }
    }
%}

%s CLASS_STATE CLASS_ATTR MAIN_STATE

%%

[[:space:]]*\/\/[[:space:]]*.*$ {}

public[[:space:]]class   {  
                            BEGIN(CLASS_STATE); 
                            class_num++;
                            pubic_class_num++;

                            if(pubic_class_num > 1) {
                                printf("Eroare: mai multe clase publice\n");
                                exit(1);
                            }

                            if(class_num == 1)
                                classes = (class *)malloc(sizeof(class));
                            else 
                                classes = (class *)realloc(classes, class_num * sizeof(class));

                            if (classes == NULL) {
                                fprintf(stderr, "Memory allocation failed\n");
                                exit(1);
                            }
                        }

class   {  
                    BEGIN(CLASS_STATE); 
                    class_num++;
                    if(class_num == 1)
                        classes = (class *)malloc(sizeof(class));
                    else 
                        classes = (class *)realloc(classes, class_num * sizeof(class));

                    if (classes == NULL) {
                        fprintf(stderr, "Memory allocation failed\n");
                        exit(1);
                    }
                 }

<CLASS_STATE>[a-zA-Z]+   {  
                            classes[class_num - 1].name = (char *)malloc((yyleng + 1) * sizeof(char));
                            strcpy(classes[class_num - 1].name, yytext);

                            classes[class_num - 1].attr_num = 0;
                            classes[class_num - 1].obj_num = 0;

                            BEGIN(CLASS_ATTR); 
                         }

<CLASS_ATTR>[[:space:]]*(public|private)[[:space:]][a-zA-Z\[\]]+[[:space:]][a-zA-Z]+; {
                    // This part recognizes the specified line pattern
                    char *lastWord = getLastWord(yytext);
                    // printf("%s\n", lastWord);

                    class *current_class = &classes[class_num - 1];
                    current_class->attr_num++;
                
                    if(current_class->attr_num == 1)
                        current_class->attributes = (attr *)malloc(sizeof(attr));
                    else 
                        current_class->attributes = (attr *)realloc(current_class->attributes, current_class->attr_num * sizeof(attr));
                
                    current_class->attributes[current_class->attr_num - 1].name = (char *)malloc((strlen(lastWord) + 1) * sizeof(char));
                    strcpy(current_class->attributes[current_class->attr_num - 1].name, lastWord);
                    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
                    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
                }

<CLASS_ATTR>set[a-zA-Z]+    {
                                //printf("%s\n", yytext);
                                extractAttrFromMethod(yytext);
                                //printf("%s\n", yytext);
                                addSetMethodToAttr(yytext);
                            }

<CLASS_ATTR>get[a-zA-Z]+    {
                                //printf("%s\n", yytext);
                                extractAttrFromMethod(yytext);
                                //printf("%s\n", yytext);
                                addGetMethodToAttr(yytext);
                            }

"public static void main(String[] args)"    {
                                                printf("%s\n", yytext);
                                                BEGIN(MAIN_STATE);
                                            }

<MAIN_STATE>new[[:space:]]+[a-zA-Z]+    {
                                            yytext = yytext + 4;
                                            printf("%s\n", yytext);
                                            //addObject(yytext);
                                            total_obj_num++;

                                            if(total_obj_num == 1)
                                                objects = (char **)malloc(sizeof(char *));
                                            else 
                                                objects = (char **)realloc(objects, total_obj_num * sizeof(char *));

                                            if (objects == NULL) {
                                                fprintf(stderr, "Memory allocation failed\n");
                                                exit(1);
                                            }

                                            objects[total_obj_num - 1] = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
                                            strcpy(objects[total_obj_num - 1], yytext);    
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

    printf("-------------------------------\n");

    for (int i = 0; i < class_num; i++) {
        printf("%s : %d\n", classes[i].name, classes[i].attr_num);
            for (int j = 0; j < classes[i].attr_num; j++) {
                printf("%s: ", classes[i].attributes[j].name);
                printf("set: %d get: %d\n", classes[i].attributes[j].SetMethod, classes[i].attributes[j].GetMethod);
            }
        printf("\n");
    }

    printf("Clase %d: ", class_num);

    for (int i = 0; i < class_num - 1; i++) {
        printf("%s, ", classes[i].name);
    }

    printf("%s\n", classes[class_num - 1].name);

    for (int i = 0; i < total_obj_num; i++) {
        addObject(objects[i]);
    }

    for (int i = 0; i < class_num; i++) {
        printf("Obiecte %s: %d\n", classes[i].name, classes[i].obj_num);
    }

    for (int i = 0; i < class_num; i++) {
        printf("%s: ", classes[i].name);

        if(classes[i].attr_num == 0) {
            printf("Nu exista atribute\n");
            continue;
        }

        bool hasSet = true;
        bool hasGet = true;
        for (int j = 0; j < classes[i].attr_num; j++) {
            if (classes[i].attributes[j].SetMethod == false) {
                hasSet = false;
            }
            if (classes[i].attributes[j].GetMethod == false) {
                hasGet = false;
            }
        }

        if (hasSet == true && hasGet == true) {
            printf("Metodele “get” si “set” sunt implementate\n");
        }

        if (hasGet == false) {
            printf("Metoda “get” nu este implementata pentru toate atributele\n");
        }
        
        if (hasSet == false) {
            printf("Metoda “set” nu este implementata pentru toate atributele\n");
        }
    }

    // Free allocated memory
    for (int i = 0; i < class_num; i++) {
        free(classes[i].name);
    }
    free(classes);

    fclose(inputFile);
    return 0;
}
