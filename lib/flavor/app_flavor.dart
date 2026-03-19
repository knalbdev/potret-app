enum AppFlavor { free, paid }

class FlavorConfig {
  static AppFlavor flavor = AppFlavor.free;

  static bool get isPaid => flavor == AppFlavor.paid;
  static bool get isFree => flavor == AppFlavor.free;

  static String get appName =>
      flavor == AppFlavor.paid ? 'Potret Pro' : 'Potret';
}
