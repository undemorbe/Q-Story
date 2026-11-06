import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Applies to every test: fonts come from assets/google_fonts, never the network.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
