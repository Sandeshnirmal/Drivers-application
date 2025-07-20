import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String _languageKey = 'selected_language';
  String _currentLanguage = 'en';
  
  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'hi': 'हिंदी',
    'ur': 'اردو',
    'es': 'Español',
    'fr': 'Français',
  };

  String get currentLanguage => _currentLanguage;
  String get currentLanguageName => supportedLanguages[_currentLanguage] ?? 'English';

  // Initialize translation service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
  }

  // Change language
  Future<bool> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      _currentLanguage = languageCode;
      return true;
    } catch (e) {
      debugPrint('Error setting language: $e');
      return false;
    }
  }

  // Get translated text
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  // Translation data
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // App General
      'app_title': 'Driver Self-Service',
      'welcome_back': 'Welcome back!',
      'driver_portal': 'Driver Portal',
      'self_service_app': 'Self-Service Mobile App',
      
      // Navigation
      'dashboard': 'Dashboard',
      'attendance': 'Attendance',
      'earnings': 'Earnings',
      'profile': 'Profile',
      'settings': 'Settings',
      
      // Login
      'username': 'Username',
      'password': 'Password',
      'login': 'Login',
      'login_failed': 'Login failed',
      'logout': 'Logout',
      'remember_me': 'Remember me',
      
      // Dashboard
      'quick_actions': 'Quick Actions',
      'start_trip': 'Start Trip',
      'check_in': 'Check In',
      'view_reports': 'View Reports',
      'support': 'Support',
      'trip_performance': 'Trip Performance',
      'payment_summary': 'Payment Summary',
      'total_earnings': 'Total Earnings',
      'completed_trips': 'Completed Trips',
      'total_distance': 'Total Distance',
      'tips_earned': 'Tips Earned',
      'cash_payments': 'Cash Payments',
      'digital_payments': 'Digital Payments',
      'cash_earnings': 'Cash Earnings',
      
      // Profile
      'driver_name': 'Driver Name',
      'mobile_number': 'Mobile Number',
      'iqama_number': 'Iqama Number',
      'vehicle_info': 'Vehicle Information',
      'company_info': 'Company Information',
      'edit_profile': 'Edit Profile',
      'deductions': 'Deductions',
      
      // Settings
      'general_settings': 'General Settings',
      'mobile_features': 'Mobile Features',
      'account_support': 'Account & Support',
      'push_notifications': 'Push Notifications',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'biometric_auth': 'Biometric Authentication',
      'offline_mode': 'Offline Mode',
      'device_info': 'Device Information',
      'privacy_policy': 'Privacy Policy',
      'help_support': 'Help & Support',
      'about_app': 'About App',
      'app_version': 'App Version',
      
      // Attendance
      'check_in_time': 'Check In Time',
      'check_out_time': 'Check Out Time',
      'working_hours': 'Working Hours',
      'location': 'Location',
      'attendance_history': 'Attendance History',

      // Leave Management
      'leave_management': 'Leave Management',
      'manage_your_leave_requests': 'Manage your leave requests',
      'request_leave': 'Request Leave',
      'leave_type': 'Leave Type',
      'select_leave_type': 'Select leave type',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'reason': 'Reason',
      'emergency_contact': 'Emergency Contact',
      'submit_request': 'Submit Request',
      'remaining_days': 'Remaining Days',
      'pending_requests': 'Pending Requests',
      'recent_requests': 'Recent Requests',
      'no_leave_requests': 'No leave requests yet',
      'tap_request_to_submit_leave': 'Tap "Request" to submit your first leave request',
      'view_all_requests': 'View All Requests',
      'cancel_leave_request': 'Cancel Leave Request',
      'are_you_sure_cancel_leave': 'Are you sure you want to cancel this leave request?',
      'yes_cancel': 'Yes, Cancel',
      'request': 'Request',
      
      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'close': 'Close',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'trips': 'trips',
      'enabled': 'enabled',
      'disabled': 'disabled',

      // Additional Settings
      'biometric_subtitle': 'Use fingerprint or face unlock',
      'offline_subtitle': 'Cache data for offline access',
      'notification_subtitle': 'Receive app notifications',

      // Intelligent Alarm System
      'stationary_alert_title': 'Movement Alert',
      'stationary_alert_message': 'You have been stationary for {duration} minutes. Please check your status.',
      'shift_reminder_1h_title': 'Shift Reminder - 1 Hour',
      'shift_reminder_1h_message': 'Your shift starts in 1 hour. Please prepare.',
      'shift_reminder_30m_title': 'Shift Reminder - 30 Minutes',
      'shift_reminder_30m_message': 'Your shift starts in 30 minutes. Get ready!',
      'shift_reminder_15m_title': 'Shift Reminder - 15 Minutes',
      'shift_reminder_15m_message': 'Your shift starts in 15 minutes. Time to go!',
      'intelligent_alarms': 'Intelligent Alarms',
      'location_monitoring': 'Location Monitoring',
      'time_reminders': 'Time Reminders',
      'set_shift_time': 'Set Shift Time',
      'monitoring_status': 'Monitoring Status',
      'restart_required': 'Restart Required',
      'restart_app_message': 'Please restart the app to apply language changes.',
      'later': 'Later',
      'restart_now': 'Restart Now',
      'confirm_logout': 'Confirm Logout',
      'logout_message': 'Are you sure you want to logout?',
      'changed_to': 'changed to',

      // Privacy Policy
      'privacy_policy_content': 'This privacy policy explains how we collect, use, and protect your personal information when you use our Driver Self-Service application.',
      'data_collection_title': 'Data Collection',
      'data_collection_content': 'We collect location data, trip information, and device information to provide our services effectively.',
      'data_usage_title': 'Data Usage',
      'data_usage_content': 'Your data is used to track attendance, calculate earnings, and improve our services. We do not share your personal information with third parties.',

      // Help & Support
      'contact_phone': 'Contact Phone',
      'contact_email': 'Contact Email',
      'live_chat': 'Live Chat',
      'chat_available': 'Available 24/7',
      'calling_support': 'Calling support...',
      'opening_email': 'Opening email client...',
      'opening_chat': 'Opening live chat...',

      // About App
      'app_description': 'A comprehensive mobile application designed for drivers to manage their daily operations, track earnings, and maintain attendance records.',
      'developed_by': 'Developed by',
    },
    
    'ar': {
      // App General
      'app_title': 'خدمة السائق الذاتية',
      'welcome_back': 'مرحباً بعودتك!',
      'driver_portal': 'بوابة السائق',
      'self_service_app': 'تطبيق الخدمة الذاتية',
      
      // Navigation
      'dashboard': 'لوحة التحكم',
      'attendance': 'الحضور',
      'earnings': 'الأرباح',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      
      // Login
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'login_failed': 'فشل تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'remember_me': 'تذكرني',
      
      // Dashboard
      'quick_actions': 'الإجراءات السريعة',
      'start_trip': 'بدء الرحلة',
      'check_in': 'تسجيل الحضور',
      'view_reports': 'عرض التقارير',
      'support': 'الدعم',
      'trip_performance': 'أداء الرحلات',
      'payment_summary': 'ملخص المدفوعات',
      'total_earnings': 'إجمالي الأرباح',
      'completed_trips': 'الرحلات المكتملة',
      'total_distance': 'إجمالي المسافة',
      'tips_earned': 'البقشيش المكتسب',
      'cash_payments': 'المدفوعات النقدية',
      'digital_payments': 'المدفوعات الرقمية',
      'cash_earnings': 'الأرباح النقدية',
      
      // Profile
      'driver_name': 'اسم السائق',
      'mobile_number': 'رقم الجوال',
      'iqama_number': 'رقم الإقامة',
      'vehicle_info': 'معلومات المركبة',
      'company_info': 'معلومات الشركة',
      'edit_profile': 'تعديل الملف الشخصي',
      'deductions': 'الخصومات',
      
      // Settings
      'general_settings': 'الإعدادات العامة',
      'mobile_features': 'ميزات الجوال',
      'account_support': 'الحساب والدعم',
      'push_notifications': 'الإشعارات',
      'language': 'اللغة',
      'dark_mode': 'الوضع المظلم',
      'biometric_auth': 'المصادقة البيومترية',
      'offline_mode': 'وضع عدم الاتصال',
      'device_info': 'معلومات الجهاز',
      'privacy_policy': 'سياسة الخصوصية',
      'help_support': 'المساعدة والدعم',
      'about_app': 'حول التطبيق',
      'app_version': 'إصدار التطبيق',
      
      // Attendance
      'check_in_time': 'وقت تسجيل الحضور',
      'check_out_time': 'وقت تسجيل الانصراف',
      'working_hours': 'ساعات العمل',
      'location': 'الموقع',
      'attendance_history': 'تاريخ الحضور',

      // Leave Management
      'leave_management': 'إدارة الإجازات',
      'manage_your_leave_requests': 'إدارة طلبات الإجازة الخاصة بك',
      'request_leave': 'طلب إجازة',
      'leave_type': 'نوع الإجازة',
      'select_leave_type': 'اختر نوع الإجازة',
      'start_date': 'تاريخ البداية',
      'end_date': 'تاريخ النهاية',
      'reason': 'السبب',
      'emergency_contact': 'جهة الاتصال الطارئة',
      'submit_request': 'إرسال الطلب',
      'remaining_days': 'الأيام المتبقية',
      'pending_requests': 'الطلبات المعلقة',
      'recent_requests': 'الطلبات الحديثة',
      'no_leave_requests': 'لا توجد طلبات إجازة حتى الآن',
      'tap_request_to_submit_leave': 'اضغط على "طلب" لإرسال طلب الإجازة الأول',
      'view_all_requests': 'عرض جميع الطلبات',
      'cancel_leave_request': 'إلغاء طلب الإجازة',
      'are_you_sure_cancel_leave': 'هل أنت متأكد من إلغاء طلب الإجازة هذا؟',
      'yes_cancel': 'نعم، إلغاء',
      'request': 'طلب',
      
      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'retry': 'إعادة المحاولة',
      'refresh': 'تحديث',
      'close': 'إغلاق',
      'edit': 'تعديل',
      'delete': 'حذف',
      'confirm': 'تأكيد',
      'trips': 'رحلات',
      'enabled': 'مفعل',
      'disabled': 'معطل',

      // Intelligent Alarm System
      'stationary_alert_title': 'تنبيه الحركة',
      'stationary_alert_message': 'لقد كنت ثابتاً لمدة {duration} دقيقة. يرجى التحقق من حالتك.',
      'shift_reminder_1h_title': 'تذكير الوردية - ساعة واحدة',
      'shift_reminder_1h_message': 'تبدأ ورديتك خلال ساعة واحدة. يرجى الاستعداد.',
      'shift_reminder_30m_title': 'تذكير الوردية - 30 دقيقة',
      'shift_reminder_30m_message': 'تبدأ ورديتك خلال 30 دقيقة. استعد!',
      'shift_reminder_15m_title': 'تذكير الوردية - 15 دقيقة',
      'shift_reminder_15m_message': 'تبدأ ورديتك خلال 15 دقيقة. حان وقت الذهاب!',
      'intelligent_alarms': 'التنبيهات الذكية',
      'location_monitoring': 'مراقبة الموقع',
      'time_reminders': 'تذكيرات الوقت',
      'set_shift_time': 'تحديد وقت الوردية',
      'monitoring_status': 'حالة المراقبة',
    },
    
    'hi': {
      // App General
      'app_title': 'ड्राइवर सेल्फ-सर्विस',
      'welcome_back': 'वापसी पर स्वागत है!',
      'driver_portal': 'ड्राइवर पोर्टल',
      'self_service_app': 'सेल्फ-सर्विस मोबाइल ऐप',
      
      // Navigation
      'dashboard': 'डैशबोर्ड',
      'attendance': 'उपस्थिति',
      'earnings': 'कमाई',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      
      // Login
      'username': 'उपयोगकर्ता नाम',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'login_failed': 'लॉगिन असफल',
      'logout': 'लॉगआउट',
      'remember_me': 'मुझे याद रखें',
      
      // Dashboard
      'quick_actions': 'त्वरित कार्य',
      'start_trip': 'यात्रा शुरू करें',
      'check_in': 'चेक इन',
      'view_reports': 'रिपोर्ट देखें',
      'support': 'सहायता',
      'trip_performance': 'यात्रा प्रदर्शन',
      'payment_summary': 'भुगतान सारांश',
      'total_earnings': 'कुल कमाई',
      'completed_trips': 'पूर्ण यात्राएं',
      'total_distance': 'कुल दूरी',
      'tips_earned': 'अर्जित टिप्स',
      'cash_payments': 'नकद भुगतान',
      'digital_payments': 'डिजिटल भुगतान',
      'cash_earnings': 'नकद कमाई',
      
      // Profile
      'driver_name': 'ड्राइवर का नाम',
      'mobile_number': 'मोबाइल नंबर',
      'iqama_number': 'इकामा नंबर',
      'vehicle_info': 'वाहन की जानकारी',
      'company_info': 'कंपनी की जानकारी',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'deductions': 'कटौती',
      
      // Settings
      'general_settings': 'सामान्य सेटिंग्स',
      'mobile_features': 'मोबाइल सुविधाएं',
      'account_support': 'खाता और सहायता',
      'push_notifications': 'पुश नोटिफिकेशन',
      'language': 'भाषा',
      'dark_mode': 'डार्क मोड',
      'biometric_auth': 'बायोमेट्रिक प्रमाणीकरण',
      'offline_mode': 'ऑफ़लाइन मोड',
      'device_info': 'डिवाइस की जानकारी',
      'privacy_policy': 'गोपनीयता नीति',
      'help_support': 'सहायता और समर्थन',
      'about_app': 'ऐप के बारे में',
      'app_version': 'ऐप संस्करण',
      
      // Common
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
      'yes': 'हाँ',
      'no': 'नहीं',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'retry': 'पुनः प्रयास',
      'refresh': 'रीफ्रेश',
      'close': 'बंद करें',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'confirm': 'पुष्टि करें',
      'trips': 'यात्राएं',
      'enabled': 'सक्षम',
      'disabled': 'अक्षम',
    },
  };
}

// Translation helper widget
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      TranslationService().translate(translationKey),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Translation extension for easy access
extension TranslationExtension on String {
  String get tr => TranslationService().translate(this);
}
