import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:living_room/service/messaging/messaging_base.dart';
import 'package:living_room/util/constants/firebase_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  debugPrint(
      'handleBackgroundMessage: Title: ${remoteMessage.notification?.title}');
  debugPrint(
      'handleBackgroundMessage: Body: ${remoteMessage.notification?.body}');
  debugPrint('handleBackgroundMessage: Data: ${remoteMessage.data}');

  _onClicked?.call(remoteMessage.data[FirebaseMessagingConstants.messageDataIdKey]);
}

void Function(String?)? _onClicked;

class MessagingImp extends MessagingBase {
  //#region Singleton factory
  static final MessagingImp _instance = MessagingImp._();

  MessagingImp._();

  factory MessagingImp() {
    return _instance;
  }

//#endregion

  FirebaseMessaging get _firebaseMessagingInstance =>
      FirebaseMessaging.instance;


  @override
  Future<RemoteMessage?> getInitialMessage() async{
    return await _firebaseMessagingInstance.getInitialMessage();
  }

  void handleMessage(RemoteMessage? remoteMessage) {
    if (remoteMessage == null) return;
    debugPrint(
        'FirebaseMessagingImpl: handleMessages called with message title: ${remoteMessage.notification?.title}');
    _onClicked?.call(remoteMessage.data[FirebaseMessagingConstants.messageDataIdKey]);
  }

  Future<void> _initPushNotifications() async {
    await _firebaseMessagingInstance
        .setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    _firebaseMessagingInstance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @override
  Future<void> initNotifications({void Function(String?)? onClicked}) async {
    _onClicked = onClicked;
    await _firebaseMessagingInstance.requestPermission(
        alert: true, badge: true, sound: true);
    await _initPushNotifications();
  }

  @override
  Future<String?> getToken() async =>
      await _firebaseMessagingInstance.getToken();

  @override
  Stream<String> get onTokenRefresh =>
      _firebaseMessagingInstance.onTokenRefresh;

  @override
  Stream<RemoteMessage> foregroundMessage() => FirebaseMessaging.onMessage;

  @override
  Future<void> subscribeToTopic(
      String topicId, Function() onDone, Function() onError) async {
    await _firebaseMessagingInstance
        .subscribeToTopic(topicId)
        .then((value) => onDone.call(), onError: (_) => onError.call());
    return;
  }

  @override
  Future<void> unsubscribeFromTopic(
      String topicId, Function() onDone, Function() onError) async {
    await _firebaseMessagingInstance
        .unsubscribeFromTopic(topicId)
        .then((value) => onDone.call(), onError: (_) => onError.call());
    return;
  }
}
