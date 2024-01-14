public class LibrarySystem {
    public static void main(String[] args) {
        Person person = new Person("John Doe", 25);

        Book book = new Book("123", "The Java Programming Language", "James Gosling");

        person.display();
        book.display();
    }
}

class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public void display() {
        System.out.println("Person: " + name + ", Age: " + age);
    }
}

public class Book {
    private String isbn;
    private String title;
    private String author;

    public Book(String isbn, String title, String author) {
        this.isbn = isbn;
        this.title = title;
        this.author = author;
    }

    public void display() {
        System.out.println("Book: ISBN=" + isbn + ", Title=" + title + ", Author=" + author);
    }
}