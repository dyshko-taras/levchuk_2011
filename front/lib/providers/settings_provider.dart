import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _defaultDatePreset = _prefs.getDefaultDatePreset();
    _pushAlertsEnabled = _prefs.getPushAlertsEnabled();
    _goalAlertsEnabled = _prefs.getGoalAlertsEnabled();
    _finalAlertsEnabled = _prefs.getFinalAlertsEnabled();
    _preGameRemindersEnabled = _prefs.getPreGameRemindersEnabled();
    _devicePreviewEnabled = _prefs.getDevicePreviewEnabled();
  }

  final PrefsStore _prefs;

  late DefaultDatePreset _defaultDatePreset;
  DefaultDatePreset get defaultDatePreset => _defaultDatePreset;

  late bool _pushAlertsEnabled;
  bool get pushAlertsEnabled => _pushAlertsEnabled;

  late bool _goalAlertsEnabled;
  bool get goalAlertsEnabled => _goalAlertsEnabled;

  late bool _finalAlertsEnabled;
  bool get finalAlertsEnabled => _finalAlertsEnabled;

  late bool _preGameRemindersEnabled;
  bool get preGameRemindersEnabled => _preGameRemindersEnabled;

  late bool _devicePreviewEnabled;
  bool get devicePreviewEnabled => _devicePreviewEnabled;

  Future<void> setDefaultDatePreset(DefaultDatePreset preset) async {
    if (_defaultDatePreset == preset) return;
    _defaultDatePreset = preset;
    notifyListeners();
    await _prefs.setDefaultDatePreset(preset);
  }

  Future<void> setPushAlertsEnabled({required bool enabled}) async {
    if (_pushAlertsEnabled == enabled) return;
    _pushAlertsEnabled = enabled;
    notifyListeners();
    await _prefs.setPushAlertsEnabled(value: enabled);
  }

  Future<void> setGoalAlertsEnabled({required bool enabled}) async {
    if (_goalAlertsEnabled == enabled) return;
    _goalAlertsEnabled = enabled;
    notifyListeners();
    await _prefs.setGoalAlertsEnabled(value: enabled);
  }

  Future<void> setFinalAlertsEnabled({required bool enabled}) async {
    if (_finalAlertsEnabled == enabled) return;
    _finalAlertsEnabled = enabled;
    notifyListeners();
    await _prefs.setFinalAlertsEnabled(value: enabled);
  }

  Future<void> setPreGameRemindersEnabled({required bool enabled}) async {
    if (_preGameRemindersEnabled == enabled) return;
    _preGameRemindersEnabled = enabled;
    notifyListeners();
    await _prefs.setPreGameRemindersEnabled(value: enabled);
  }

  Future<void> setDevicePreviewEnabled({required bool enabled}) async {
    if (_devicePreviewEnabled == enabled) return;
    _devicePreviewEnabled = enabled;
    notifyListeners();
    await _prefs.setDevicePreviewEnabled(value: enabled);
  }
}
