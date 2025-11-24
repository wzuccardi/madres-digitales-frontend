import 'firebase_boot_impl_io.dart' if (dart.library.html) 'firebase_boot_impl_web.dart';

abstract class FirebaseBoot {
  static Future<void> init() => FirebaseBootImpl.init();
}