import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences and reading positions, persisted on device.
final class LumenSettings extends ChangeNotifier {
  LumenSettings(this._prefs);

  final SharedPreferences _prefs;

  static Future<LumenSettings> load() async =>
      LumenSettings(await SharedPreferences.getInstance());

  /// Multiplier for prayer text (meditations, stations).
  double get textScale => _prefs.getDouble('textScale') ?? 1.0;
  set textScale(double value) {
    _prefs.setDouble('textScale', value);
    notifyListeners();
  }

  /// The set chosen by hand today, if any; tomorrow the app opens on the
  /// mysteries of the day again.
  String? chosenSetFor(DateTime day) =>
      _prefs.getString('chosenSetDate') == _dayKey(day)
          ? _prefs.getString('chosenSet')
          : null;

  void chooseSet(String setId, DateTime day) {
    _prefs
      ..setString('chosenSet', setId)
      ..setString('chosenSetDate', _dayKey(day));
  }

  /// `dark`, `light` or `system`.
  String get themeMode => _prefs.getString('themeMode') ?? 'dark';
  set themeMode(String value) {
    _prefs.setString('themeMode', value);
    notifyListeners();
  }

  bool get onboardingDone => _prefs.getBool('onboardingDone') ?? false;
  set onboardingDone(bool value) {
    _prefs.setBool('onboardingDone', value);
    notifyListeners();
  }

  int meditationIndex(String setId, int mystery) =>
      _prefs.getInt('med_${setId}_$mystery') ?? 0;

  void setMeditationIndex(String setId, int mystery, int index) =>
      _prefs.setInt('med_${setId}_$mystery', index);

  int lastStation(String collectionId) =>
      _prefs.getInt('station_$collectionId') ?? 0;

  void setLastStation(String collectionId, int index) =>
      _prefs.setInt('station_$collectionId', index);

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

/// Gives every screen access to [LumenSettings] and rebuilds on change.
class LumenScope extends InheritedNotifier<LumenSettings> {
  const LumenScope({
    super.key,
    required LumenSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static LumenSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LumenScope>()!.notifier!;
}
