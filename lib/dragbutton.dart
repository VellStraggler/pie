class MyClass {
  // This will be found on the corners of every task (except the center one)
  // It is meant to show up when in edit mode or zoomed in to level 3
  // It is used to drag a task's starting or ending point

    String name;
    int age;

    MyClass(this.name, this.age);


    void displayInfo() {
      print('Name: $name, Age: $age');
    }
}