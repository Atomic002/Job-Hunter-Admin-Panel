// constants/app_strings.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AppStrings {
  static const String appName = 'Imkon Job Admin';
  static const String dashboard = 'Boshqaruv';
  static const String posts = 'Elonlar';
  static const String users = 'Foydalanuvchilar';
  static const String notifications = 'Bildirishnomalar';

  static const String pending = 'Kutilmoqda';
  static const String approved = 'Tasdiqlangan';
  static const String rejected = 'Rad etilgan';
  static const String expired = 'Muddati tugagan';

  static const String approve = 'Tasdiqlash';
  static const String reject = 'Rad etish';
  static const String cancel = 'Bekor qilish';
  static const String save = 'Saqlash';
  static const String delete = 'O\'chirish';

  static const String success = 'Muvaffaqiyat';
  static const String error = 'Xato';
  static const String warning = 'Diqqat';

  static const String loading = 'Yuklanmoqda...';
  static const String noData = 'Ma\'lumot topilmadi';
  static const String search = 'Qidirish...';

  static const String confirmApprove = 'Ushbu elonni tasdiqlashni xohlaysizmi?';
  static const String confirmReject = 'Ushbu elonni rad etishni xohlaysizmi?';
  static const String confirmBlock =
      'Ushbu foydalanuvchini bloklashni xohlaysizmi?';

  static const String postApproved = 'Elon muvaffaqiyatli tasdiqlandi';
  static const String postRejected = 'Elon rad etildi';
  static const String userBlocked = 'Foydalanuvchi bloklandi';
  static const String userActivated = 'Foydalanuvchi faollashtirildi';
}

// constants/app_dimensions.dart
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeRegular = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
}

// services/notification_service.dart
class NotificationService {
  final supabase = Supabase.instance.client;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendPostApprovedNotification(
    String userId,
    String postTitle,
  ) async {
    await sendNotification(
      userId: userId,
      title: 'Elon tasdiqlandi ✅',
      body: '"$postTitle" eloni muvaffaqiyatli tasdiqlandi',
      type: 'post_approved',
    );
  }

  Future<void> sendPostRejectedNotification(
    String userId,
    String postTitle,
    String reason,
  ) async {
    await sendNotification(
      userId: userId,
      title: 'Elon rad etildi ❌',
      body: '"$postTitle" eloni rad etildi. Sabab: $reason',
      type: 'post_rejected',
    );
  }

  Future<void> sendUserBlockedNotification(String userId) async {
    await sendNotification(
      userId: userId,
      title: 'Hisob bloklandi 🚫',
      body:
          'Sizning hisobingiz bloklandi. Qo\'shimcha ma\'lumot uchun admin bilan bog\'laning.',
      type: 'user_blocked',
    );
  }
}
