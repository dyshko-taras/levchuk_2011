import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/services/notification_service.dart';

class PrefsProvider extends ChangeNotifier {
  PrefsProvider(this._prefs, this._notifications) {
    _draftDefaultDatePreset = _prefs.getDefaultDatePreset();
    _draftFinalAlertsEnabled = _prefs.getFinalAlertsEnabled();
  }

  final PrefsStore _prefs;
  final NotificationService _notifications;

  bool get firstRun => _prefs.getFirstRun();

  late DefaultDatePreset _draftDefaultDatePreset;
  DefaultDatePreset get draftDefaultDatePreset => _draftDefaultDatePreset;

  late bool _draftFinalAlertsEnabled;
  bool get draftFinalAlertsEnabled => _draftFinalAlertsEnabled;

  bool _saving = false;
  bool get saving => _saving;

  void setDraftDefaultDatePreset(DefaultDatePreset preset) {
    if (_draftDefaultDatePreset == preset) return;
    _draftDefaultDatePreset = preset;
    notifyListeners();
  }

  Future<bool> setDraftFinalAlertsEnabled({required bool enabled}) async {
    if (_draftFinalAlertsEnabled == enabled) return true;
    if (enabled) {
      final granted = await _notifications.ensureNotificationPermission();
      if (!granted) return false;
    }
    _draftFinalAlertsEnabled = enabled;
    notifyListeners();
    return true;
  }

  Future<void> completeWelcome() async {
    _saving = true;
    notifyListeners();

    try {
      await _prefs.setDefaultDatePreset(_draftDefaultDatePreset);
      await _prefs.setFinalAlertsEnabled(value: _draftFinalAlertsEnabled);
      await _prefs.setFirstRun(value: false);
      await _notifications.syncFinalAlerts();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
