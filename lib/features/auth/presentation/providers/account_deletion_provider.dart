import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set right before the app lands back on LoginPage after a successful
/// account deletion, so the page can show a one-time confirmation SnackBar
/// without needing to pass arguments through AuthGate's provider-driven
/// (not Navigator-driven) routing.
final accountJustDeletedProvider = StateProvider<bool>((ref) => false);
