// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Breast App';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get scanTitle => 'Breast Detection & Segmentation';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get runClassification => 'Run Classification';

  @override
  String get analysing => 'Analysing...';

  @override
  String statusError(String message) {
    return 'Error: $message';
  }

  @override
  String get classification => 'Classification';

  @override
  String get unknown => 'Unknown';

  @override
  String confidence(String value) {
    return 'Confidence: $value%';
  }

  @override
  String get benign => 'Benign';

  @override
  String get malignant => 'Malignant';

  @override
  String get normal => 'Normal';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get russian => 'Russian';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get logout => 'Logout';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Fill in your details to get started';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone Number';

  @override
  String get myProfile => 'My Profile';

  @override
  String get noProfileData => 'No profile data available';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get uploadImagePrompt => 'Upload a breast scan image';

  @override
  String get segmenting => 'Segmenting...';

  @override
  String get runSegmentation => 'Run Segmentation';

  @override
  String get segmentationResult => 'Segmentation Result';
}
