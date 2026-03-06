// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'QStory';

  @override
  String get generateQr => 'Generar QR';

  @override
  String get scanQr => 'Escanear QR';

  @override
  String get cameraPermissionRequired =>
      'Se requiere permiso de cámara para escanear códigos QR.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get permissionDenied => 'Permiso Denegado';

  @override
  String get error => 'Error';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get scanResult => 'Resultado del Escaneo';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';
}
