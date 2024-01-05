import 'package:firebase_messaging/firebase_messaging.dart';

abstract class MessagingBase {
  Future<void> initNotifications({void Function(String?)? onClicked});

  Future<RemoteMessage?> getInitialMessage();

  Stream<RemoteMessage> foregroundMessage();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  void sendMessage(
      {required String fcmToken, required String title, required String body});

  Future<void> subscribeToTopic(
      String topicId, Function() onDone, Function() onError);

  Future<void> unsubscribeFromTopic(
      String topicId, Function() onDone, Function() onError);
}
