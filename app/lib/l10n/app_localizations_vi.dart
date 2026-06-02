// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Doctor Booking';

  @override
  String get welcome => 'Chào mừng trở lại';

  @override
  String get loginSubtitle => 'Đăng nhập để đặt lịch khám bệnh';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get orContinueWith => 'hoặc';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String hello(String name) {
    return 'Xin chào, $name 👋';
  }

  @override
  String get whatToday => 'Bạn muốn khám gì hôm nay?';

  @override
  String get searchHint => 'Tìm kiếm bác sĩ, chuyên khoa...';

  @override
  String get services => 'Dịch vụ';

  @override
  String get booking => 'Đặt lịch';

  @override
  String get videoCall => 'Video Call';

  @override
  String get chat => 'Chat';

  @override
  String get medicalRecords => 'Hồ sơ';

  @override
  String get upcomingAppointments => 'Lịch hẹn sắp tới';

  @override
  String get noAppointments => 'Chưa có lịch hẹn nào';

  @override
  String get bookNow => 'Đặt lịch ngay';

  @override
  String get topDoctors => 'Bác sĩ nổi bật';

  @override
  String get home => 'Trang chủ';

  @override
  String get calendar => 'Lịch hẹn';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get patient => 'Bệnh nhân';

  @override
  String get doctor => 'Bác sĩ';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get youAre => 'Bạn là:';

  @override
  String get createAccount => 'Tạo tài khoản mới';

  @override
  String get fillInfoBelow => 'Điền thông tin bên dưới để bắt đầu';

  @override
  String get registerSuccess =>
      'Đăng ký thành công! Vui lòng kiểm tra email để xác nhận.';

  @override
  String get errorEmailRequired => 'Vui lòng nhập email';

  @override
  String get errorEmailInvalid => 'Email không hợp lệ';

  @override
  String get errorPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get errorPasswordShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get errorPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get errorNameRequired => 'Vui lòng nhập họ tên';

  @override
  String get errorNetwork => 'Không có kết nối mạng. Vui lòng kiểm tra Wi-Fi.';

  @override
  String get errorServer => 'Hệ thống đang bảo trì. Vui lòng thử lại sau.';

  @override
  String get retry => 'Thử lại';
}
