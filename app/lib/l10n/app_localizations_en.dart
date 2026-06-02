// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Doctor Booking';

  @override
  String get welcome => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to book your appointments';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerNow => 'Register now';

  @override
  String get orContinueWith => 'or';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String hello(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get whatToday => 'What do you want to check today?';

  @override
  String get searchHint => 'Search doctors, specialities...';

  @override
  String get services => 'Services';

  @override
  String get booking => 'Booking';

  @override
  String get videoCall => 'Video Call';

  @override
  String get chat => 'Chat';

  @override
  String get medicalRecords => 'Records';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get noAppointments => 'No appointments yet';

  @override
  String get bookNow => 'Book Now';

  @override
  String get topDoctors => 'Top Doctors';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get patient => 'Patient';

  @override
  String get doctor => 'Doctor';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get youAre => 'You are:';

  @override
  String get createAccount => 'Create New Account';

  @override
  String get fillInfoBelow => 'Fill in the information below to get started';

  @override
  String get registerSuccess =>
      'Registration successful! Please check your email to confirm.';

  @override
  String get errorEmailRequired => 'Please enter your email';

  @override
  String get errorEmailInvalid => 'Invalid email address';

  @override
  String get errorPasswordRequired => 'Please enter your password';

  @override
  String get errorPasswordShort => 'Password must be at least 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorNameRequired => 'Please enter your name';

  @override
  String get errorNetwork => 'No internet connection. Please check your Wi-Fi.';

  @override
  String get errorServer =>
      'System is under maintenance. Please try again later.';

  @override
  String get retry => 'Retry';
}
