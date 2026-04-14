// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Breast App';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInSubtitle => 'Войдите в свой аккаунт';

  @override
  String get dontHaveAccount => 'Нет аккаунта? ';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get scanTitle => 'Детекция и сегментация';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get runClassification => 'Запустить классификацию';

  @override
  String get analysing => 'Анализ...';

  @override
  String statusError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get classification => 'Классификация';

  @override
  String get unknown => 'Неизвестно';

  @override
  String confidence(String value) {
    return 'Уверенность: $value%';
  }

  @override
  String get benign => 'Доброкачественная';

  @override
  String get malignant => 'Злокачественная';

  @override
  String get normal => 'Норма';

  @override
  String get profile => 'Профиль';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get english => 'Английский';

  @override
  String get arabic => 'Арабский';

  @override
  String get russian => 'Русский';

  @override
  String get login => 'Вход';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get logout => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get registerSubtitle => 'Заполните данные, чтобы начать';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get phone => 'Номер телефона';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get noProfileData => 'Нет данных профиля';

  @override
  String get profileUpdatedSuccess => 'Профиль успешно обновлен';

  @override
  String get personalInformation => 'Личная информация';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get uploadImagePrompt => 'Загрузите снимок';

  @override
  String get segmenting => 'Сегментация...';

  @override
  String get runSegmentation => 'Запустить сегментацию';

  @override
  String get segmentationResult => 'Результат сегментации';
}
