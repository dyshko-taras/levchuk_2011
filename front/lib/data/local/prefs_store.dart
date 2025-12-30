import 'package:shared_preferences/shared_preferences.dart';

enum DefaultDatePreset {
  today,
  yesterday,
  tomorrow,
}

class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStore(prefs);
  }

  static const _kFirstRun = 'first_run';
  static const _kDefaultDatePreset = 'default_date_preset';
  static const _kFinalAlertsEnabled = 'final_alerts_enabled';

  static const _kDevicePreviewEnabled = 'settings.device_preview_enabled';

  bool getFirstRun() => _prefs.getBool(_kFirstRun) ?? true;
  Future<void> setFirstRun({required bool value}) =>
      _prefs.setBool(_kFirstRun, value);

  DefaultDatePreset getDefaultDatePreset() {
    final raw = _prefs.getString(_kDefaultDatePreset);
    return DefaultDatePreset.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => DefaultDatePreset.today,
    );
  }

  Future<void> setDefaultDatePreset(DefaultDatePreset preset) =>
      _prefs.setString(_kDefaultDatePreset, preset.name);

  bool getFinalAlertsEnabled() => _prefs.getBool(_kFinalAlertsEnabled) ?? false;
  Future<void> setFinalAlertsEnabled({required bool value}) =>
      _prefs.setBool(_kFinalAlertsEnabled, value);

  bool getDevicePreviewEnabled() =>
      _prefs.getBool(_kDevicePreviewEnabled) ?? false;
  Future<void> setDevicePreviewEnabled({required bool value}) =>
      _prefs.setBool(_kDevicePreviewEnabled, value);
}
