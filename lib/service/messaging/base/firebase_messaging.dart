import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:living_room/main.dart';
import 'package:living_room/service/messaging/messaging_base.dart';
import 'package:living_room/util/constants/firebase_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  _onClicked
      ?.call(remoteMessage.data[FirebaseMessagingConstants.messageDataIdKey]);
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

  final String _httpFcmSend =
      "https://fcm.googleapis.com/v1/projects/living-room-9bcc0/messages:send";
  final String _serviceAccountJsonPath = "assets/json/service-account.json";
  final String _serviceScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  final String _tokenKey = "token";
  final String _topicKey = "topic";

  FirebaseMessaging get _firebaseMessagingInstance =>
      FirebaseMessaging.instance;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessagingInstance.getInitialMessage();
  }

  void handleMessage(RemoteMessage? remoteMessage) {
    if (remoteMessage == null) return;
    debugPrint(
        'FirebaseMessagingImpl: handleMessages called with message title: ${remoteMessage.notification?.title}');
    _onClicked
        ?.call(remoteMessage.data[FirebaseMessagingConstants.messageDataIdKey]);
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

  @override
  void sendMessage(
      {required String fcmToken, required String title, required String body}) {
    _sendMessage(
        to: fcmToken,
        title: title,
        body: body,
        onSuccess: () {
          log.d('Successful sending.');
        },
        onError: () {
          log.e('Unsuccessful sending.');
        });
  }

  void _sendMessage(
      {required String to,
      required String title,
      required String body,
      Map<String, String>? payload,
      Function()? onSuccess,
      Function()? onError}) async {
    var toKey = to.length > 40 ? _tokenKey : _topicKey;
    try {
      _getAccessToken().then((accessToken) {
        if (accessToken == null) {
          onError?.call();
        } else {
          http
              .post(Uri.parse(_httpFcmSend),
                  headers: _headers(accessToken),
                  body: _body(
                      toKey: toKey,
                      toValue: to,
                      title: title,
                      body: body,
                      payload: payload))
              .then((response) => response.statusCode == 200
                  ? onSuccess?.call()
                  : onError?.call());
        }
      });
     } catch (_) {
      onError?.call();
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      var serviceAccountJson =
          json.decode(await rootBundle.loadString(_serviceAccountJsonPath));
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      var accessCredentials = await obtainAccessCredentialsViaServiceAccount(
          accountCredentials, <String>[_serviceScope], http.Client());
      var accessToken = accessCredentials.accessToken;
      return (accessToken.type.isEmpty || accessToken.data.isEmpty)
          ? null
          : "${accessToken.type} ${accessToken.data}";
    } catch (e) {
      return null;
    }
  }

  Map<String, String> _headers(String accessToken) =>
      {'Content-Type': 'application/json', 'Authorization': accessToken};

  String _body(
      {required String toKey,
      required String toValue,
      required String title,
      required String body,
      Map<String, String>? payload}) {
    return json.encode({
      'message': {
        toKey: toValue,
        'notification': {'title': title, 'body': body},
        'data': payload ?? {}
      }
    });
  }
}

class MessagingObject {
  String fcmToken, message;
  String? massageDayId;

  MessagingObject(
      {required this.fcmToken,
      required this.message,
      required this.massageDayId});
}
