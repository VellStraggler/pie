/// This is what's known as a Singleton
/// it is modifiable from everywhere
class Diameter {
  // Private constructor
  Diameter._();

  // The single instance of the class
  static final Diameter instance = Diameter._();

  // The modifiable variable
  double pieDiameter = 350.0;

  /// Get the Pie Diameter.
  /// * Diameter.instance.getPieDiameter();
  double getPieDiameter() {
    return pieDiameter;
  }

  /// Set the Pie Diameter.
  /// * Diameter.instance.setPieDiameter(400.0);
  void setPieDiameter(double pieDiameter) {
    this.pieDiameter = pieDiameter;
  }
}
