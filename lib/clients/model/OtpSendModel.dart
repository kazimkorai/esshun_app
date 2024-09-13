// To parse this JSON data, do
//
//     final otpSendModel = otpSendModelFromJson(jsonString);

import 'dart:convert';

OtpSendModel otpSendModelFromJson(String str) => OtpSendModel.fromJson(json.decode(str));

String otpSendModelToJson(OtpSendModel data) => json.encode(data.toJson());

class OtpSendModel {
  bool success;
  String message;
  int otp;
  String userStatus;
  Users users;

  OtpSendModel({
    required this.success,
    required this.message,
    required this.otp,
    required this.userStatus,
    required this.users,
  });

  factory OtpSendModel.fromJson(Map<String, dynamic> json) => OtpSendModel(
    success: json["success"],
    message: json["message"],
    otp: json["otp"],
    userStatus: json["user_status"],
    users: Users.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "otp": otp,
    "user_status": userStatus,
    "users": users.toJson(),
  };
}

class Users {
  int id;
  dynamic firstName;
  dynamic lastName;
  dynamic email;
  dynamic username;
  String contactNumber;
  int otp;
  dynamic gender;
  dynamic emailVerifiedAt;
  dynamic address;
  dynamic userType;
  dynamic playerId;
  dynamic serviceId;
  dynamic fleetId;
  dynamic latitude;
  dynamic longitude;
  dynamic lastNotificationSeen;
  String status;
  int isOnline;
  int isAvailable;
  int isVerifiedDriver;
  dynamic uid;
  dynamic fcmToken;
  dynamic displayName;
  dynamic loginType;
  String timezone;
  dynamic lastLocationUpdateAt;
  DateTime createdAt;
  DateTime updatedAt;

  Users({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.contactNumber,
    required this.otp,
    required this.gender,
    required this.emailVerifiedAt,
    required this.address,
    required this.userType,
    required this.playerId,
    required this.serviceId,
    required this.fleetId,
    required this.latitude,
    required this.longitude,
    required this.lastNotificationSeen,
    required this.status,
    required this.isOnline,
    required this.isAvailable,
    required this.isVerifiedDriver,
    required this.uid,
    required this.fcmToken,
    required this.displayName,
    required this.loginType,
    required this.timezone,
    required this.lastLocationUpdateAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    username: json["username"],
    contactNumber: json["contact_number"],
    otp: json["otp"],
    gender: json["gender"],
    emailVerifiedAt: json["email_verified_at"],
    address: json["address"],
    userType: json["user_type"],
    playerId: json["player_id"],
    serviceId: json["service_id"],
    fleetId: json["fleet_id"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    lastNotificationSeen: json["last_notification_seen"],
    status: json["status"],
    isOnline: json["is_online"]!=null?json["is_online"]:1,
    isAvailable: json["is_available"]!=null?json["is_available"]:1,
    isVerifiedDriver: json["is_verified_driver"]!=null?json["is_verified_driver"]:1,
    uid: json["uid"],
    fcmToken: json["fcm_token"],
    displayName: json["display_name"],
    loginType: json["login_type"],
    timezone: json["timezone"].toString(),
    lastLocationUpdateAt: json["last_location_update_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "username": username,
    "contact_number": contactNumber,
    "otp": otp,
    "gender": gender,
    "email_verified_at": emailVerifiedAt,
    "address": address,
    "user_type": userType,
    "player_id": playerId,
    "service_id": serviceId,
    "fleet_id": fleetId,
    "latitude": latitude,
    "longitude": longitude,
    "last_notification_seen": lastNotificationSeen,
    "status": status,
    "is_online": isOnline,
    "is_available": isAvailable,
    "is_verified_driver": isVerifiedDriver,
    "uid": uid,
    "fcm_token": fcmToken,
    "display_name": displayName,
    "login_type": loginType,
    "timezone": timezone,
    "last_location_update_at": lastLocationUpdateAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
