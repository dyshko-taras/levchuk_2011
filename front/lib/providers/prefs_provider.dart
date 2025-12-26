import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';

class PrefsProvider extends ChangeNotifier {
  PrefsProvider(this._prefs) {
    _draftDefaultDatePreset = _prefs.getDefaultDatePreset();
    _draftPushAlertsEnabled = _prefs.getPushAlertsEnabled();
  }

  final PrefsStore _prefs;

  bool get firstRun => _prefs.getFirstRun();

  late DefaultDatePreset _draftDefaultDatePreset;
  DefaultDatePreset get draftDefaultDatePreset => _draftDefaultDatePreset;

  late bool _draftPushAlertsEnabled;
  bool get draftPushAlertsEnabled => _draftPushAlertsEnabled;

  bool _saving = false;
  bool get saving => _saving;

  void setDraftDefaultDatePreset(DefaultDatePreset preset) {
    if (_draftDefaultDatePreset == preset) return;
    _draftDefaultDatePreset = preset;
    notifyListeners();
  }

  void setDraftPushAlertsEnabled({required bool enabled}) {
    if (_draftPushAlertsEnabled == enabled) return;
    _draftPushAlertsEnabled = enabled;
    notifyListeners();
  }

  Future<void> completeWelcome() async {
    _saving = true;
    notifyListeners();

    try {
      await _prefs.setDefaultDatePreset(_draftDefaultDatePreset);
      await _prefs.setPushAlertsEnabled(value: _draftPushAlertsEnabled);
      await _prefs.setGoalAlertsEnabled(value: _draftPushAlertsEnabled);
      await _prefs.setFinalAlertsEnabled(value: _draftPushAlertsEnabled);
      await _prefs.setFirstRun(value: false);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
