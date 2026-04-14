import 'package:flutter/widgets.dart';
import 'package:breast_app/core/localization/generated/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
