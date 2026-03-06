// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$localeAtom =
      Atom(name: '_SettingsStore.locale', context: context);

  @override
  Locale get locale {
    _$localeAtom.reportRead();
    return super.locale;
  }

  @override
  set locale(Locale value) {
    _$localeAtom.reportWrite(value, super.locale, () {
      super.locale = value;
    });
  }

  late final _$themeModeAtom =
      Atom(name: '_SettingsStore.themeMode', context: context);

  @override
  ThemeMode get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeMode value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$notificationsEnabledAtom =
      Atom(name: '_SettingsStore.notificationsEnabled', context: context);

  @override
  bool get notificationsEnabled {
    _$notificationsEnabledAtom.reportRead();
    return super.notificationsEnabled;
  }

  @override
  set notificationsEnabled(bool value) {
    _$notificationsEnabledAtom.reportWrite(value, super.notificationsEnabled,
        () {
      super.notificationsEnabled = value;
    });
  }

  late final _$dataSaverEnabledAtom =
      Atom(name: '_SettingsStore.dataSaverEnabled', context: context);

  @override
  bool get dataSaverEnabled {
    _$dataSaverEnabledAtom.reportRead();
    return super.dataSaverEnabled;
  }

  @override
  set dataSaverEnabled(bool value) {
    _$dataSaverEnabledAtom.reportWrite(value, super.dataSaverEnabled, () {
      super.dataSaverEnabled = value;
    });
  }

  late final _$_initAsyncAction =
      AsyncAction('_SettingsStore._init', context: context);

  @override
  Future<void> _init() {
    return _$_initAsyncAction.run(() => super._init());
  }

  late final _$setLocaleAsyncAction =
      AsyncAction('_SettingsStore.setLocale', context: context);

  @override
  Future<void> setLocale(Locale newLocale) {
    return _$setLocaleAsyncAction.run(() => super.setLocale(newLocale));
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

  @override
  void setThemeMode(ThemeMode mode) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setThemeMode');
    try {
      return super.setThemeMode(mode);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleNotifications(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.toggleNotifications');
    try {
      return super.toggleNotifications(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleDataSaver(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.toggleDataSaver');
    try {
      return super.toggleDataSaver(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
locale: ${locale},
themeMode: ${themeMode},
notificationsEnabled: ${notificationsEnabled},
dataSaverEnabled: ${dataSaverEnabled}
    ''';
  }
}
