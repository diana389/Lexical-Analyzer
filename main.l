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
    char obj_name[100];

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
        for(int i = 0; i < class_num; i++) {
            if(strcmp(classes[i].name, object) == 0) {
                classes[i].obj_num++;
            }
        }
    }
%}

%s CLASS_STATE CLASS_ATTR MAIN_STATE ATTR_NAME_STATE SET_STATE GET_STATE NEW_STATE PARANTHESIS SIZE_STATE

%%

[[:space:]]*\/\/[[:space:]]*.*$ {}

public[[:space:]]class   {  
    BEGIN(CLASS_STATE); 

    class_num++; // increase the number of classes
    pubic_class_num++; // increase the number of public classes

    // print error if there are more than one public classes
    if(pubic_class_num > 1) {
        printf("Eroare: mai multe clase publice\n");
        exit(1);
    }

    // allocate memory for the classes array
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

    class_num++; // increase the number of classes

    // allocate memory for the classes array
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

    BEGIN(CLASS_ATTR); 

    // copy the class name
    classes[class_num - 1].name = (char *)malloc((yyleng + 1) * sizeof(char));
    strcpy(classes[class_num - 1].name, yytext);

    // initialize the attributes and objects number
    classes[class_num - 1].attr_num = 0;
    classes[class_num - 1].obj_num = 0;
}

<CLASS_ATTR>[[:space:]]*(public|private)[[:space:]][a-zA-Z\[\]]+[[:space:]]/[a-zA-Z]+; {

    BEGIN(ATTR_NAME_STATE);
}

<ATTR_NAME_STATE>[a-zA-Z]+    {

    BEGIN(CLASS_ATTR);

    class *current_class = &classes[class_num - 1]; // current class is the last class added to the array
    current_class->attr_num++; // increase the number of attributes

    // allocate memory for the attributes array
    if(current_class->attr_num == 1)
        current_class->attributes = (attr *)malloc(sizeof(attr));
    else 
        current_class->attributes = (attr *)realloc(current_class->attributes, current_class->attr_num * sizeof(attr));

    if (current_class->attributes == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }

    // copy the attribute name
    current_class->attributes[current_class->attr_num - 1].name = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
    strcpy(current_class->attributes[current_class->attr_num - 1].name, yytext);

    // initialize the GetMethod and SetMethod flags
    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
}

<CLASS_ATTR>set/[a-zA-Z]+    {

    BEGIN(SET_STATE);
}

<SET_STATE>[a-zA-Z]+    {

    yytext[0] = tolower(yytext[0]);
    addSetMethodToAttr(yytext);

    BEGIN(CLASS_ATTR);
}

<CLASS_ATTR>get/[a-zA-Z]+    {

    BEGIN(GET_STATE);
}

<GET_STATE>[a-zA-Z]+    {

    yytext[0] = tolower(yytext[0]);
    addGetMethodToAttr(yytext);

    BEGIN(CLASS_ATTR);
}

"public static void main(String[] args)"    {

    BEGIN(MAIN_STATE);
}

<MAIN_STATE>new[[:space:]]+/[a-zA-Z]+\[[0-9]+\]    {

    BEGIN(NEW_STATE);
}

<NEW_STATE>[a-zA-Z]+/\[[0-9]+\]    {

    BEGIN(PARANTHESIS);
    strcpy(obj_name, yytext);
}

<PARANTHESIS>\[/[0-9]+\]    {

    BEGIN(SIZE_STATE);
}

<SIZE_STATE>[0-9]+/\]    {

    BEGIN(MAIN_STATE);
    int arraySize = atoi(yytext);
    
    for(int i = 0; i < arraySize; i++) {
        total_obj_num++; // increase the number of objects

        // allocate memory for the objects array
        if(total_obj_num == 1)
            objects = (char **)malloc(sizeof(char *));
        else 
            objects = (char **)realloc(objects, total_obj_num * sizeof(char *));

        if (objects == NULL) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }

        // allocate memory for the object name and copy it
        objects[total_obj_num - 1] = (char *)malloc((strlen(obj_name) + 1) * sizeof(char));
        strcpy(objects[total_obj_num - 1], obj_name);    
    }  
}

<MAIN_STATE>[a-zA-Z]+\[.*\][[:space:]]+=[[:space:]]+new[[:space:]]+[a-zA-Z]+ {}

<MAIN_STATE>new[[:space:]]+/[a-zA-Z]+    {  

    BEGIN(NEW_STATE);
}

<NEW_STATE>[a-zA-Z]+    {

    BEGIN(MAIN_STATE);
    
    total_obj_num++; // increase the number of objects

    // allocate memory for the objects array
    if(total_obj_num == 1)
        objects = (char **)malloc(sizeof(char *));
    else 
        objects = (char **)realloc(objects, total_obj_num * sizeof(char *));

    if (objects == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }

    // allocate memory for the object name and copy it
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

    yyin = inputFile; // set the input file for Flex

    yylex(); // start lexical analysis

    // print the number of classes
    printf("\n");
    printf("Clase %d: ", class_num);

    // print the classes names
    for (int i = 0; i < class_num - 1; i++) {
        printf("%s, ", classes[i].name);
    }

    printf("%s\n", classes[class_num - 1].name);

    printf("\n");
    printf("----------------------------------------------------------------------\n");
    printf("\n");

    // add the objects to the array
    for (int i = 0; i < total_obj_num; i++) {
        addObject(objects[i]);
    }

    // print the number of objects for each class
    for (int i = 0; i < class_num; i++) {
        printf("Obiecte %s: %d\n", classes[i].name, classes[i].obj_num);
    }

    printf("\n");
    printf("----------------------------------------------------------------------\n");
    printf("\n");

    // print the methods
    for (int i = 0; i < class_num; i++) {
        printf("%s:\n", classes[i].name);

        if(classes[i].attr_num == 0) {
            printf("\tNu exista atribute\n");
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
            printf("\tMetodele “get” si “set” sunt implementate\n");
        }

        if (hasGet == false) {
            printf("\tMetoda “get” nu este implementata pentru toate atributele\n");
        }
        
        if (hasSet == false) {
            printf("\tMetoda “set” nu este implementata pentru toate atributele\n");
        }
    }

    printf("\n");

    // free allocated memory
    for (int i = 0; i < class_num; i++) {
        free(classes[i].name);
        for (int j = 0; j < classes[i].attr_num; j++) {
            free(classes[i].attributes[j].name);
        }
        free(classes[i].attributes);
    }
    free(classes);

    for (int i = 0; i < total_obj_num; i++) {
        free(objects[i]);
    }
    free(objects);

    fclose(inputFile);
    return 0;
}
