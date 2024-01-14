%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <ctype.h>

    // class attributes structure
    typedef struct attr {
        char* name; // attribute name
        bool GetMethod; // flag for the GetMethod
        bool SetMethod; // flag for the SetMethod
    }attr;

    // class structure
    typedef struct class {
        char* name; // class name
        attr* attributes; // array of attributes
        int attr_num; // number of attributes
        int obj_num; // number of instances of the class
    }class;

    int class_num = 0; // number of classes
    int pubic_class_num = 0; // number of public classes
    class *classes; // array of classes
    char **objects; // array of objects types
    int total_obj_num = 0; // number of objects
    char obj_type[100]; // current object type

    void allocateMemoryClasses() {
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

    void allocateMemoryObjects() {
        // allocate memory for the objects array
        if(total_obj_num == 1)
            objects = (char **)malloc(sizeof(char *));
        else 
            objects = (char **)realloc(objects, total_obj_num * sizeof(char *));

        if (objects == NULL) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }
    }

    void allocateMemoryAttributes(class *current_class) {
        // allocate memory for the attributes array
        if(current_class->attr_num == 1)
            current_class->attributes = (attr *)malloc(sizeof(attr));
        else 
            current_class->attributes = (attr *)realloc(current_class->attributes, current_class->attr_num * sizeof(attr));

        if (current_class->attributes == NULL) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }
    }

    // function to add the SetMethod flag to an attribute
    void addSetMethodToAttr(char *method) {
        for(int i = 0; i < class_num; i++) {
            for(int j = 0; j < classes[i].attr_num; j++) {
                if(strcmp(classes[i].attributes[j].name, method) == 0) {
                    classes[i].attributes[j].GetMethod = true;
                }
            }
        }
    }

    // function to add the GetMethod flag to an attribute
    void addGetMethodToAttr(char *method) {
        for(int i = 0; i < class_num; i++) {
            for(int j = 0; j < classes[i].attr_num; j++) {
                if(strcmp(classes[i].attributes[j].name, method) == 0) {
                    classes[i].attributes[j].SetMethod = true;
                }
            }
        }
    }

    // function to add an object to the objects count 
    void addObject(char *object) {
        for(int i = 0; i < class_num; i++) {
            if(strcmp(classes[i].name, object) == 0) {
                classes[i].obj_num++;
            }
        }
    }
%}

%s CLASS_STATE CLASS_ATTR MAIN_STATE ATTR_NAME_STATE SET_STATE GET_STATE NEW_STATE PARANTHESIS SIZE_STATE

comments [[:space:]]*\/\/[[:space:]]*.*$
public_class public[[:space:]]class
class class
word [a-zA-Z]+
number [0-9]+
type [a-zA-Z\[\]]+
space [[:space:]]

%%

{comments} { /* ignore comments */ }

{public_class}   {  // rule for public classes
    BEGIN(CLASS_STATE); 

    class_num++; // increase the number of classes
    pubic_class_num++; // increase the number of public classes

    // print error if there are more than one public classes
    if(pubic_class_num > 1) {
        printf("Eroare: mai multe clase publice\n");
        exit(1);
    }

    // allocate memory for the classes array
    allocateMemoryClasses();
}

{class}  {  // rule for regular classes
    
    BEGIN(CLASS_STATE); 

    class_num++; // increase the number of classes

    // allocate memory for the classes array
    allocateMemoryClasses();
}

<CLASS_STATE>{word}   {   // rule for class names

    BEGIN(CLASS_ATTR); 

    // copy the class name
    classes[class_num - 1].name = (char *)malloc((yyleng + 1) * sizeof(char));
    strcpy(classes[class_num - 1].name, yytext);

    // initialize the attributes and objects number
    classes[class_num - 1].attr_num = 0;
    classes[class_num - 1].obj_num = 0;
}

<CLASS_ATTR>{space}*(public|private){space}{type}{space}/{word}; { // rule for attribute lines (followed by their names) (ignore it)

    BEGIN(ATTR_NAME_STATE);
}

<ATTR_NAME_STATE>{word}    { // rule for attribute names

    BEGIN(CLASS_ATTR);

    class *current_class = &classes[class_num - 1]; // current class is the last class added to the array
    current_class->attr_num++; // increase the number of attributes

    // allocate memory for the attributes array
    allocateMemoryAttributes(current_class);

    // copy the attribute name
    current_class->attributes[current_class->attr_num - 1].name = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
    strcpy(current_class->attributes[current_class->attr_num - 1].name, yytext);

    // initialize the GetMethod and SetMethod flags
    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
    current_class->attributes[current_class->attr_num - 1].SetMethod = false;
}

<CLASS_ATTR>set/{word}    { // rule for SetMethod lines (followed by the attribute names) (ignore it)

    BEGIN(SET_STATE);
}

<SET_STATE>{word}     { // rule for attribute names

    yytext[0] = tolower(yytext[0]);
    addSetMethodToAttr(yytext); // add the SetMethod flag to the attribute

    BEGIN(CLASS_ATTR);
}

<CLASS_ATTR>get/{word}    { // rule for GetMethod lines (followed by the attribute names) (ignore it)

    BEGIN(GET_STATE);
}

<GET_STATE>{word}    { // rule for attribute names

    yytext[0] = tolower(yytext[0]);
    addGetMethodToAttr(yytext); // add the GetMethod flag to the attribute

    BEGIN(CLASS_ATTR);
}

"public static void main(String[] args)"    { // rule for main method header (ignore it)

    BEGIN(MAIN_STATE);
}

<MAIN_STATE>new{space}+/{word}\[{number}\]    { // rule for the word "new" in an array initialization (ignore it)

    BEGIN(NEW_STATE);
}

<NEW_STATE>{word}/\[{number}\]    { // rule for the array type

    BEGIN(PARANTHESIS);
    strcpy(obj_type, yytext); // copy the array type
}

<PARANTHESIS>\[/{number}\]    { // rule for the '[' character in an array initialization (ignore it)

    BEGIN(SIZE_STATE);
}

<SIZE_STATE>{number}/\]    { // rule for the array size

    BEGIN(MAIN_STATE);
    int arraySize = atoi(yytext); // convert the array size to an integer
    
    for(int i = 0; i < arraySize; i++) {
        total_obj_num++; // increase the number of objects

        // allocate memory for the objects array
        allocateMemoryObjects();

        // allocate memory for the object type and copy it
        objects[total_obj_num - 1] = (char *)malloc((strlen(obj_type) + 1) * sizeof(char));
        strcpy(objects[total_obj_num - 1], obj_type);    
    }  
}

<MAIN_STATE>{word}\[.*\]{space}+={space}+new{space}+{word} { /* ignore array initialization */ }

<MAIN_STATE>new{space}+/{word}     {  // rule for the word "new" in an object initialization (ignore it)

    BEGIN(NEW_STATE);
}

<NEW_STATE>{word}     { // rule for the object type

    BEGIN(MAIN_STATE);
    
    total_obj_num++; // increase the number of objects

    // allocate memory for the objects array
    allocateMemoryObjects();

    // allocate memory for the object name and copy it
    objects[total_obj_num - 1] = (char *)malloc((strlen(yytext) + 1) * sizeof(char));
    strcpy(objects[total_obj_num - 1], yytext);    
}

.|\n    { /* ignore everything else */ }
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
