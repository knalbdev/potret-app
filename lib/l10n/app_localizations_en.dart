// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Potret';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get storyList => 'Story';

  @override
  String get newStory => 'New Story';

  @override
  String get description => 'Description';

  @override
  String get upload => 'Upload';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get noData => 'No stories yet';

  @override
  String get retry => 'Retry';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get selectImage => 'Tap to select an image';

  @override
  String get storyDetail => 'Story Detail';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get imageRequired => 'Please select an image';

  @override
  String get loginFailed => 'Login failed. Check your email and password.';

  @override
  String get registerSuccess => 'Registration successful! Please login.';

  @override
  String get uploadSuccess => 'Story uploaded successfully!';

  @override
  String get uploadFailed => 'Failed to upload story';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get or => 'or';

  @override
  String get loginSubtitle => 'Welcome back! Please sign in to continue.';

  @override
  String get registerSubtitle => 'Create a new account to get started.';

  @override
  String get pickLocation => 'Pick Location';

  @override
  String get removeLocation => 'Remove Location';

  @override
  String get locationAdded => 'Location added';

  @override
  String get tapToPickLocation => 'Tap on the map to pick a location';

  @override
  String get fetchingAddress => 'Fetching address...';

  @override
  String get noAddress => 'No address available';

  @override
  String get locationOnMap => 'Location on Map';

  @override
  String get confirm => 'Confirm';

  @override
  String get freePlanNoLocation =>
      'Location is only available in the paid plan';

  @override
  String get loadingMore => 'Loading more stories...';
}
