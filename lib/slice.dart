class MyClass {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
    String name;
    int age;

    MyClass(this.name, this.age);


    void displayInfo() {
      print('Name: $name, Age: $age');
    }
}