import 'package:living_room/model/database/users/database_user.dart';

extension DatabaseUserExtension on DatabaseUser {
  get string => 'id: $id, displayName: $displayName, email: $email, '
      'photoUrl: $photoUrl, isBanned: $isBanned, isArchived: $isArchived, '
      'fcmToken: $fcmToken, generalNotification: $generalNotification, '
      'createdAt: $createdAt';
}
