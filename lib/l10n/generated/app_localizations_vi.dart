// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'PDF Readcloud';

  @override
  String get settings => 'Cài đặt';

  @override
  String get account => 'Tài khoản';

  @override
  String get guest => 'Khách';

  @override
  String get notSignedIn => 'Chưa đăng nhập';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get subscription => 'Gói đăng ký';

  @override
  String get premiumActive => 'Premium đang hoạt động ✓';

  @override
  String get upgradeToPremium => 'Nâng cấp Premium';

  @override
  String get backgroundPlaybackEnabled => 'Phát nền đã bật';

  @override
  String get unlockBackgroundAudioPlayback => 'Mở khóa phát âm thanh nền';

  @override
  String get viewOptions => 'Tùy chọn hiển thị';

  @override
  String get readerMode => 'Chế độ đọc';

  @override
  String get plainText => 'Văn bản thuần';

  @override
  String get originalPdf => 'PDF gốc';

  @override
  String get scrollDirection => 'Hướng cuộn';

  @override
  String get vertical => 'Dọc';

  @override
  String get horizontal => 'Ngang';

  @override
  String get textToSpeech => 'Chuyển văn bản thành giọng nói';

  @override
  String get playbackSpeed => 'Tốc độ phát';

  @override
  String get voiceLanguage => 'Ngôn ngữ giọng nói';

  @override
  String get about => 'Giới thiệu';

  @override
  String get appLanguage => 'Ngôn ngữ ứng dụng';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get continueWithoutAccount => 'Tiếp tục không cần tài khoản';

  @override
  String get listenToYourPdfsWithRealtimeWordHighlighting =>
      'Nghe PDF với\\nđánh sáng từng từ theo thời gian thực';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get signInToSyncYourLibraryAcrossDevices =>
      'Đăng nhập để đồng bộ thư viện giữa các thiết bị';

  @override
  String get myLibrary => 'Thư viện của tôi';

  @override
  String get loadingLibrary => 'Đang tải thư viện...';

  @override
  String get openingPdf => 'Đang mở PDF...';

  @override
  String get importPdf => 'Nhập PDF';

  @override
  String get noPdfsYet => 'Chưa có PDF nào';

  @override
  String get tapToImportFirstPdf =>
      'Nhấn nút bên dưới để nhập\\nPDF đầu tiên của bạn';

  @override
  String hello(Object name) {
    return 'Xin chào, $name 👋';
  }

  @override
  String pages(int count) {
    return '$count trang';
  }

  @override
  String get pageNotFound => 'Không tìm thấy trang';

  @override
  String pageNotFoundMessage(Object error) {
    return 'Không tìm thấy trang: $error';
  }

  @override
  String pageOf(int pageNumber, int pageCount) {
    return 'Trang $pageNumber / $pageCount';
  }

  @override
  String get noTextOnThisPage => 'Trang này không có văn bản';

  @override
  String get sessionSettings => 'Cài đặt phiên';

  @override
  String get reset => 'Đặt lại';

  @override
  String get speechSpeed => 'Tốc độ giọng nói';

  @override
  String get voice => 'Giọng đọc';

  @override
  String get systemDefault => 'Mặc định hệ thống';

  @override
  String get autoDetectedByContent => 'Tự động (phát hiện từ nội dung)';

  @override
  String get showAllLanguages => 'Hiển thị tất cả ngôn ngữ';

  @override
  String detected(Object locale) {
    return 'Đã phát hiện: $locale';
  }

  @override
  String unableToLoadVoices(Object error) {
    return 'Không thể tải giọng đọc: $error';
  }

  @override
  String get noVoicesAvailableForThisLanguage =>
      'Không có giọng đọc nào cho ngôn ngữ này.';

  @override
  String get systemVoice => 'Giọng hệ thống';

  @override
  String get searchNotImplementedYet => 'Tìm kiếm chưa được hỗ trợ.';

  @override
  String get cancel => 'Hủy';

  @override
  String get goPremium => 'Nâng cấp Premium';

  @override
  String get unlockPremium => 'Mở khóa Premium';

  @override
  String get restorePurchase => 'Khôi phục mua hàng';

  @override
  String get keepReadingWhileScreenIsOff => 'Tiếp tục đọc khi tắt màn hình';

  @override
  String get backgroundAudioPlayback => 'Phát âm thanh nền';

  @override
  String get lockScreenAndNotificationControls =>
      'Điều khiển trên màn hình khóa và thông báo';

  @override
  String get allFuturePremiumFeatures =>
      'Tất cả tính năng Premium trong tương lai';

  @override
  String removePdfMessage(Object title) {
    return 'Thao tác này sẽ xóa \"$title\" khỏi thư viện của bạn. Không thể hoàn tác.';
  }

  @override
  String get removePdf => 'Xóa PDF?';

  @override
  String get openOriginalPdf => 'Mở PDF gốc';

  @override
  String get viewerWithOriginalLayout => 'Trình xem với bố cục gốc';

  @override
  String get openPlainText => 'Mở văn bản thuần';

  @override
  String get textOnlyReader => 'Trình đọc chỉ văn bản';

  @override
  String get delete => 'Xóa';

  @override
  String get retry => 'Thử lại';

  @override
  String get reader => 'Trình đọc';

  @override
  String versionLabel(Object version) {
    return 'Phiên bản $version';
  }
}
