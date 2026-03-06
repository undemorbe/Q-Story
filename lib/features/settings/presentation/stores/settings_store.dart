// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  final SettingsRepository _repository;

  _SettingsStore(this._repository) {
    _init();
  }

  @observable
  Locale locale = const Locale('en');

  @observable
  ThemeMode themeMode = ThemeMode.system;

  @observable
  bool notificationsEnabled = true;

  @observable
  bool dataSaverEnabled = false;

  @action
  Future<void> _init() async {
    final savedLocale = await _repository.getLocale();
    if (savedLocale != null) {
      locale = Locale(savedLocale);
    }
  }

  @action
  Future<void> setLocale(Locale newLocale) async {
    locale = newLocale;
    await _repository.setLocale(newLocale.languageCode);
  }

  @action
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
  }

  @action
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
  }

  @action
  void toggleDataSaver(bool value) {
    dataSaverEnabled = value;
  }
}
