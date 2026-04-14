import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../locale_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final LocaleService _localeService;

  LocaleCubit(this._localeService) : super(_localeService.getLocale() ?? const Locale('en'));

  void changeLocale(Locale locale) {
    if (state != locale) {
      _localeService.saveLocale(locale);
      emit(locale);
    }
  }
}
