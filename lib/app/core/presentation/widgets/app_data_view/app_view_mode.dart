import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';

/// How a list screen shows its records. [grid] needs a `gridItemBuilder`.
enum AppViewMode {
  table,
  cards,
  grid;

  static AppViewMode? tryParse(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

/// The user's chosen [AppViewMode] for one screen, persisted per screen with
/// [AppSettingsManager]. `null` means "no choice yet": the data view then picks
/// the default for the device. Presentation preference only; no business rule.
class ViewModeCubit extends Cubit<AppViewMode?> {
  ViewModeCubit({required AppSettingsManager settings, required this.screenId})
    : _settings = settings,
      super(null);

  final AppSettingsManager _settings;

  /// Stable id of the screen, e.g. `catalog.brands`.
  final String screenId;

  Future<void> restore() async {
    final stored = AppViewMode.tryParse(await _settings.getViewMode(screenId));
    if (!isClosed && stored != null) emit(stored);
  }

  Future<void> select(AppViewMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _settings.setViewMode(screenId, mode.name);
  }
}
