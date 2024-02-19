# LFA---Tema-FLEX

Stefan Diana 332CC
TEMA FLEX - Varianta C 

Platforma: Visual Studio Code (C)

In rezolvare am folosit urmatoarele structuri: 
    - class, care contine numele unei clase, numarul de instante, numarul de atribute si un vector de atribute 
    (de tip attr)
    - attr, care contine numele variabilei, un flag pentru metoda get corespunzatoare si unul pentru metoda set

1. Identificarea si numararea claselor definite
    - in cazul in care se gaseste cuvantul "class" sau sintagma "public class", creste numarul de clase si se 
    trece in starea CLASS_STATE
    - daca este a doua intalnire a sintagmei "public class", se afiseaza un mesaj de eroare si se iese din 
    program
    - ClASS_STATE: se gaseste numele clasei, care se copiaza in vectorul de clase si se initializeaza toate 
    campurile, apoi se intra in starea CLASS_ATTR

2. Determinarea numarului de instante create pentru fiecare clasa
    - in cazul in care este gasita sintagma "public static void main(String[] args)", se trece in starea 
    MAIN_STATE
    - MAIN_STATE: daca se gaseste cuvantul "new", urmat de o structura de tipul "nume_var[nr_elem]" se intra 
    in starea  NEW_STATE
    - NEW_STATE: se retine tipul vectorului si se intra in starea PARANTHESIS
    - PARANTHESIS: are scopul de a trece de simbolul '[', pentru a extrage numarul, deci se ignora caracterul 
    si se ajunge in starea SIZE_STATE
    - SIZE_STATE: se gaseste dimensiunea vectorului si se adauga numarul respectiv de obiecte in vectorul ce 
    contine toate instantele
    - MAIN_STATE: daca se gaseste o structura de tipul "nume_var[index] = new tip_instanta" este ignorata, 
    deoarece elementele vectorului au fost deja numarate la declarare
    - MAIN_STATE: daca se gaseste o alta structura de tipul "new tip_instanta", se intra in starea NEW_STATE
    - NEW_STATE: se adauga obiectul in lista instantelor

Probleme aparute: separarea cazului in care este declarat un vector de crearea unei instante obisnuite

3. Verificarea daca sunt implementate metodele "get" si "set" pentru fiecare atribut al unei clase
    - CLASS_ATTR: se face match cu linia declararii atributului, pana la numele acestuia, si se intra in 
    starea ATTR_NAME_STATE
    - ATTR_NAME_STATE: se adauga atributul in lista clasei curente si se revine in starea CLASS_ATTR
    - CLASS_ATTR: daca se gaseste o metoda "set", se intra in starea SET_STATE, iar pentru o metoda "get", in 
    starea GET_STATE
    - SET_STATE: se seteaza flag-ul atributului caruia ii corespunde metoda set gasita
    - GET_STATE: se seteaza flag-ul atributului caruia ii corespunde metoda get gasita

Probleme aparute: tinerea evidentei fecarei metode pentru fiecare atribut
