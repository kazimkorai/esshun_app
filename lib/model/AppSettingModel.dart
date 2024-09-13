import 'SettingModel.dart';

class AppSettingModel {
    Region? region;
    SettingModel? settingModel;
    List<RideSetting> rideSetting=[];
    List<WalletSetting> walletSetting=[];
    CurrencySetting? currencySetting;
    PrivacyPolicyModel? privacyPolicyModel;
    PrivacyPolicyModel? termsCondition;

    AppSettingModel({this.region, required this.rideSetting, required this.walletSetting, this.currencySetting, this.settingModel, this.privacyPolicyModel, this.termsCondition});

    AppSettingModel.fromJson(Map<String, dynamic> json) {
        region = json['region'] != null ? new Region.fromJson(json['region']) : null;
        settingModel = json['app_setting'] != null ? new SettingModel.fromJson(json['app_setting']) : null;
        if (json['ride_setting'] != null) {
            rideSetting = <RideSetting>[];
            json['ride_setting'].forEach((v) {
                rideSetting.add(new RideSetting.fromJson(v));
            });
        }
        if (json['wallet_setting'] != null) {
            walletSetting = <WalletSetting>[];
            json['wallet_setting'].forEach((v) {
                walletSetting!.add(new WalletSetting.fromJson(v));
            });
        }
        currencySetting = json['currency_setting'] != null ? new CurrencySetting.fromJson(json['currency_setting']) : null;
        privacyPolicyModel = json['privacy_policy'] != null ? new PrivacyPolicyModel.fromJson(json['privacy_policy']) : null;
        termsCondition = json['terms_condition'] != null ? new PrivacyPolicyModel.fromJson(json['terms_condition']) : null;
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.region != null) {
            data['region'] = this.region!.toJson();
        }
        if (this.settingModel != null) {
            data['app_seeting'] = this.settingModel!.toJson();
        }
        if (this.rideSetting != null) {
            data['ride_setting'] = this.rideSetting!.map((v) => v.toJson()).toList();
        }
        if (this.walletSetting != null) {
            data['Wallet_setting'] = this.walletSetting!.map((v) => v.toJson()).toList();
        }
        if (this.currencySetting != null) {
            data['currency_setting'] = this.currencySetting!.toJson();
        }
        if (this.privacyPolicyModel != null) {
            data['privacy_policy'] = this.privacyPolicyModel!.toJson();
        }
        if (this.termsCondition != null) {
            data['terms_condition'] = this.termsCondition!.toJson();
        }
        return data;
    }
}

class Region {
    dynamic id;
    dynamic name;
    dynamic currencyName;
    dynamic currencyCode;
    dynamic distanceUnit;
    dynamic status;
    dynamic timezone;
    dynamic createdAt;
    dynamic updatedAt;

    Region({
        this.id,
        this.name,
        this.currencyName,
        this.currencyCode,
        this.distanceUnit,
        this.status,
        this.timezone,
        this.createdAt,
        this.updatedAt,
    });

    Region.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        name = json['name'].toString();
        currencyName = json['currency_name'].toString();
        currencyCode = json['currency_code'].toString();
        distanceUnit = json['distance_unit'].toString();
        status = json['status'];
        timezone = json['timezone'].toString();
        createdAt = json['created_at'].toString();
        updatedAt = json['updated_at'].toString();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id.toString();
        data['name'] = this.name.toString();
        data['currency_name'] = this.currencyName.toString();
        data['currency_code'] = this.currencyCode.toString();
        data['distance_unit'] = this.distanceUnit.toString();
        data['status'] = this.status;
        data['timezone'] = this.timezone;
        data['created_at'] = this.createdAt;
        data['updated_at'] = this.updatedAt;
        return data;
    }
}

class WalletSetting {
    dynamic id;
    dynamic key;
    dynamic type;
    dynamic value;

    WalletSetting({this.id, this.key, this.type, this.value});

    WalletSetting.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        key = json['key'].toString();
        type = json['type'].toString();
        value = json['value'].toString();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['key'] = this.key;
        data['type'] = this.type;
        data['value'] = this.value;
        return data;
    }
}

class RideSetting {
    dynamic id;
    dynamic key;
    dynamic type;
    dynamic value;

    RideSetting({this.id, this.key, this.type, this.value});

    RideSetting.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        key = json['key'];
        type = json['type'];
        value = json['value'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['key'] = this.key;
        data['type'] = this.type;
        data['value'] = this.value;
        return data;
    }
}

class CurrencySetting {
    dynamic name;
    dynamic code;
    dynamic symbol;
    dynamic position;

    CurrencySetting({this.name, this.code, this.position, this.symbol});

    CurrencySetting.fromJson(Map<String, dynamic> json) {
        name = json['name'];
        code = json['code'];
        position = json['position'];
        symbol = json['symbol'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['name'] = this.name;
        data['code'] = this.code;
        data['position'] = this.position;
        data['symbol'] = this.symbol;
        return data;
    }
}

class PrivacyPolicyModel {
    int? id;
    dynamic key;
    dynamic type;
    dynamic value;

    PrivacyPolicyModel({this.id, this.key, this.type, this.value});

    factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
        return PrivacyPolicyModel(
            id: json['id'],
            key: json['key'],
            type: json['type'],
            value: json['value'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['key'] = this.key;
        data['type'] = this.type;
        data['value'] = this.value;
        return data;
    }
}
