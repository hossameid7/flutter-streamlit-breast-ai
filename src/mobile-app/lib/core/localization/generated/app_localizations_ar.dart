// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيق الثدي';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'تسجيل الدخول إلى حسابك';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get scanTitle => 'كشف وتجزئة سرطان الثدي';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get runClassification => 'تشغيل التصنيف';

  @override
  String get analysing => 'جاري التحليل...';

  @override
  String statusError(String message) {
    return 'خطأ: $message';
  }

  @override
  String get classification => 'التصنيف';

  @override
  String get unknown => 'غير معروف';

  @override
  String confidence(String value) {
    return 'الثقة: $value%';
  }

  @override
  String get benign => 'حميد';

  @override
  String get malignant => 'خبيث';

  @override
  String get normal => 'طبيعي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get russian => 'الروسية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'دخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'املأ تفاصيلك للبدء';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get myProfile => 'الملف الشخصي';

  @override
  String get noProfileData => 'لا توجد بيانات متاحة';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get uploadImagePrompt => 'قم بتحميل صورة فحص الثدي';

  @override
  String get segmenting => 'جاري التقسيم...';

  @override
  String get runSegmentation => 'بدء التقسيم';

  @override
  String get segmentationResult => 'نتيجة التقسيم';
}
