import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs, this._notifications) {
    _defaultDatePreset = _prefs.getDefaultDatePreset();
    _finalAlertsEnabled = _prefs.getFinalAlertsEnabled();
    _devicePreviewEnabled = _prefs.getDevicePreviewEnabled();
  }

  final PrefsStore _prefs;
  final NotificationService _notifications;

  late DefaultDatePreset _defaultDatePreset;
  DefaultDatePreset get defaultDatePreset => _defaultDatePreset;

  late bool _finalAlertsEnabled;
  bool get finalAlertsEnabled => _finalAlertsEnabled;

  late bool _devicePreviewEnabled;
  bool get devicePreviewEnabled => _devicePreviewEnabled;

  void reloadFromPrefs() {
    _defaultDatePreset = _prefs.getDefaultDatePreset();
    _finalAlertsEnabled = _prefs.getFinalAlertsEnabled();
    _devicePreviewEnabled = _prefs.getDevicePreviewEnabled();
    notifyListeners();
  }

  Future<void> setDefaultDatePreset(DefaultDatePreset preset) async {
    if (_defaultDatePreset == preset) return;
    _defaultDatePreset = preset;
    notifyListeners();
    await _prefs.setDefaultDatePreset(preset);
  }

  Future<void> setFinalAlertsEnabled({required bool enabled}) async {
    if (_finalAlertsEnabled == enabled) return;
    _finalAlertsEnabled = enabled;
    notifyListeners();
    await _prefs.setFinalAlertsEnabled(value: enabled);
    await _notifications.syncFinalAlerts();
  }

  Future<void> setDevicePreviewEnabled({required bool enabled}) async {
    if (_devicePreviewEnabled == enabled) return;
    _devicePreviewEnabled = enabled;
    notifyListeners();
    await _prefs.setDevicePreviewEnabled(value: enabled);
  }
}
