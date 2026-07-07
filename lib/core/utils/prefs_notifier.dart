import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/providers/settings_providers.dart';

class PrefsNotifier<T> extends StateNotifier<T> {
  final Ref _ref;
  final String key;
  final T Function(SharedPreferences) load;
  final void Function(SharedPreferences, T) save;

  PrefsNotifier(
    this._ref,
    this.key,
    T defaultValue, {
    required this.load,
    required this.save,
  }) : super(defaultValue) {
    _init();
  }

  void _init() {
    final prefs = _ref.read(sharedPrefsProvider);
    state = load(prefs);
  }

  void set(T value) {
    state = value;
    final prefs = _ref.read(sharedPrefsProvider);
    save(prefs, value);
  }
}
