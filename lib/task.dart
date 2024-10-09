class MyClass {
  // This is the data of a task/slice. This must be able to be stored in .json
    String name;
    int age;

    MyClass(this.name, this.age);


    void displayInfo() {
      print('Name: $name, Age: $age');
    }
}