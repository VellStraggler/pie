/// This is what's known as a Singleton
/// it is modifiable from everywhere
class Diameter {
  // Private constructor
  Diameter._();

  // The single instance of the class
  static final Diameter instance = Diameter._();

  // The modifiable variable
  double pie = 350.0;

  // access/modify using this line:
  // Diameter.instance.pie = 400.0;
}
