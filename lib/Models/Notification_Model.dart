// To parse this JSON data, do
//
//     final notificationMessage = notificationMessageFromJson(jsonString);

import 'dart:convert';

NotificationMessage notificationMessageFromJson(String str) =>
    NotificationMessage.fromJson(json.decode(str));

String notificationMessageToJson(NotificationMessage data) =>
    json.encode(data.toJson());

class NotificationMessage {
  final Message message;

  NotificationMessage({
    required this.message,
  });

  NotificationMessage copyWith({
    Message? message,
  }) =>
      NotificationMessage(
        message: message ?? this.message,
      );

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
      };
}

class Message {
  final String? token;
  final Notification notification;
  final Map<String, String> data;

  Message({
    this.token,
    required this.notification,
    required this.data,
  });

  Message copyWith({
    String? token,
    Notification? notification,
    Map<String, String>? data,
  }) {
    return Message(
      token: token ?? this.token,
      notification: notification ?? this.notification,
      data: data ?? this.data,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json["token"] as String?,
      notification:
          Notification.fromJson(json["notification"] as Map<String, dynamic>),
      data: Map<String, String>.from(
          json["data"] as Map), // Safely cast to Map<String, String>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "notification": notification.toJson(),
      "data": data, // Directly include the Map<String, String>
    };
  }
}

class Notification {
  final String title;
  final String body;

  Notification({
    required this.title,
    required this.body,
  });

  Notification copyWith({
    String? title,
    String? body,
  }) =>
      Notification(
        title: title ?? this.title,
        body: body ?? this.body,
      );

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        title: json["title"],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "body": body,
      };
}
