import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/enums/main_tab.dart';

class ShellNavigationProvider extends ChangeNotifier {
  MainTab _activeTab = MainTab.home;
  MainTab get activeTab => _activeTab;

  int get activeIndex => _tabToIndex(_activeTab);

  void setInitialTab(MainTab tab) {
    setTab(tab);
  }

  void setTab(MainTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  void setIndex(int index) {
    final tab = _indexToTab(index);
    if (tab == null) return;
    setTab(tab);
  }

  static int _tabToIndex(MainTab tab) => switch (tab) {
    MainTab.home => 0,
    MainTab.standings => 1,
    MainTab.compare => 2,
    MainTab.favorites => 3,
    MainTab.predictions => 4,
  };

  static MainTab? _indexToTab(int index) => switch (index) {
    0 => MainTab.home,
    1 => MainTab.standings,
    2 => MainTab.compare,
    3 => MainTab.favorites,
    4 => MainTab.predictions,
    _ => null,
  };
}
