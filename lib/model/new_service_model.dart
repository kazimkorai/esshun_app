// To parse this JSON data, do
//
//     final serviceModel = serviceModelFromJson(jsonString);

import 'dart:convert';

mServiceModel serviceModelFromJson(String str) => mServiceModel.fromJson(json.decode(str));

String serviceModelToJson(mServiceModel data) => json.encode(data.toJson());

class mServiceModel {
  String status;
  List<ListServicesModel> data;

  mServiceModel({
    required this.status,
    required this.data,
  });

  factory mServiceModel.fromJson(Map<String, dynamic> json) => mServiceModel(
    status: json["status"],
    data: List<ListServicesModel>.from(json["data"].map((x) => ListServicesModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ListServicesModel {
  int id;
  dynamic parentId;
  dynamic name;
  dynamic regionId;
  dynamic capacity;
  dynamic baseFare;
  dynamic minimumFare;
  dynamic minimumDistance;
  dynamic perDistance;
  dynamic perMinuteDrive;
  dynamic perMinuteWait;
  dynamic waitingTimeLimit;
  dynamic cancellationFee;
  dynamic paymentMethod;
  dynamic commissionType;
  dynamic adminCommission;
  dynamic fleetCommission;
  dynamic status;
  dynamic description;
  DateTime createdAt;
  DateTime updatedAt;
  int mediaId;
  dynamic fileName;
  dynamic imageUrl;

  ListServicesModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.regionId,
    required this.capacity,
    required this.baseFare,
    required this.minimumFare,
    required this.minimumDistance,
    required this.perDistance,
    required this.perMinuteDrive,
    required this.perMinuteWait,
    required this.waitingTimeLimit,
    required this.cancellationFee,
    required this.paymentMethod,
    required this.commissionType,
    required this.adminCommission,
    required this.fleetCommission,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.mediaId,
    required this.fileName,
    required this.imageUrl,
  });

  factory ListServicesModel.fromJson(Map<String, dynamic> json) => ListServicesModel(
    id: json["id"],
    parentId: json["parent_id"],
    name: json["name"],
    regionId: json["region_id"],
    capacity: json["capacity"],
    baseFare: json["base_fare"],
    minimumFare: json["minimum_fare"],
    minimumDistance: json["minimum_distance"],
    perDistance: json["per_distance"],
    perMinuteDrive: json["per_minute_drive"],
    perMinuteWait: json["per_minute_wait"],
    waitingTimeLimit: json["waiting_time_limit"],
    cancellationFee: json["cancellation_fee"],
    paymentMethod: json["payment_method"],
    commissionType: json["commission_type"],
    adminCommission: json["admin_commission"],
    fleetCommission: json["fleet_commission"],
    status: json["status"],
    description: json["description"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    mediaId: json["media_id"],
    fileName: json["file_name"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "parent_id": parentId,
    "name": name,
    "region_id": regionId,
    "capacity": capacity,
    "base_fare": baseFare,
    "minimum_fare": minimumFare,
    "minimum_distance": minimumDistance,
    "per_distance": perDistance,
    "per_minute_drive": perMinuteDrive,
    "per_minute_wait": perMinuteWait,
    "waiting_time_limit": waitingTimeLimit,
    "cancellation_fee": cancellationFee,
    "payment_method": paymentMethod,
    "commission_type": commissionType,
    "admin_commission": adminCommission,
    "fleet_commission": fleetCommission,
    "status": status,
    "description": description,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "media_id": mediaId,
    "file_name": fileName,
    "image_url": imageUrl,
  };
}
