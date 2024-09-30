// To parse this JSON data, do
//
//     final newServiceModel = newServiceModelFromJson(jsonString);

import 'dart:convert';

NewServiceModel newServiceModelFromJson(String str) => NewServiceModel.fromJson(json.decode(str));

String newServiceModelToJson(NewServiceModel data) => json.encode(data.toJson());

class NewServiceModel {
  String status;
  List<NewServicesModelObj> data;

  NewServiceModel({
    required this.status,
    required this.data,
  });

  factory NewServiceModel.fromJson(Map<String, dynamic> json) => NewServiceModel(
    status: json["status"],
    data: List<NewServicesModelObj>.from(json["data"].map((x) => NewServicesModelObj.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class NewServicesModelObj {
  int id;
  int parentId;
  String name;
  int regionId;
  int capacity;
  int baseFare;
  int minimumFare;
  int minimumDistance;
  int perDistance;
  int perMinuteDrive;
  int perMinuteWait;
  int waitingTimeLimit;
  int cancellationFee;
  String paymentMethod;
  String commissionType;
  int adminCommission;
  int fleetCommission;
  int status;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  int mediaId;
  String fileName;
  String imageUrl;

  NewServicesModelObj({
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

  factory NewServicesModelObj.fromJson(Map<String, dynamic> json) => NewServicesModelObj(
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
