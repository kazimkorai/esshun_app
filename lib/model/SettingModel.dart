class SettingModel {
  dynamic contactEmail;
  dynamic contactNumber;
  dynamic createdAt;
  dynamic facebookUrl;
  dynamic id;
  dynamic instagramUrl;
  List<dynamic>? languageOption;
  dynamic linkedinUrl;
  dynamic helpSupportUrl;

  //List<Object>? notification_settings;
  dynamic siteCopyright;
  dynamic siteDescription;
  dynamic siteEmail;
  dynamic siteFavicon;
  dynamic siteLogo;
  dynamic siteName;
  dynamic twitterUrl;
  dynamic updatedAt;

  SettingModel({
    this.contactEmail,
    this.contactNumber,
    this.createdAt,
    this.facebookUrl,
    this.id,
    this.instagramUrl,
    this.languageOption,
    this.linkedinUrl,
    //this.notification_settings,
    this.siteCopyright,
    this.siteDescription,
    this.siteEmail,
    this.siteFavicon,
    this.siteLogo,
    this.siteName,
    this.twitterUrl,
    this.updatedAt,
    this.helpSupportUrl,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      contactEmail: json['contact_email'].toString(),
      contactNumber: json['contact_number'].toString(),
      createdAt: json['created_at'].toString(),
      facebookUrl: json['facebook_url'].toString(),
      id: json['id'].toString(),
      instagramUrl: json['instagram_url'].toString(),
      languageOption: json['language_option'] != null ? new List<String>.from(json['language_option']) : null,
      linkedinUrl: json['linkedin_url'].toString(),
      //notification_settings: json['notification_settings'] != null ? (json['notification_settings'] as List).map((i) => Object.fromJson(i)).toList() : null,
      siteCopyright: json['site_copyright'].toString(),
      siteDescription: json['site_description'].toString(),
      siteEmail: json['site_email'].toString(),
      siteFavicon: json['site_favicon'].toString(),
      siteLogo: json['site_logo'].toString(),
      siteName: json['site_name'].toString(),
      twitterUrl: json['twitter_url'].toString(),
      updatedAt: json['updated_at'].toString(),
      helpSupportUrl: json['help_support_url'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contact_email'] = this.contactEmail;
    data['contact_number'] = this.contactNumber;
    data['created_at'] = this.createdAt;
    data['facebook_url'] = this.facebookUrl;
    data['id'] = this.id;
    data['instagram_url'] = this.instagramUrl;
    data['linkedin_url'] = this.linkedinUrl;
    data['site_copyright'] = this.siteCopyright;
    data['site_description'] = this.siteDescription;
    data['site_email'] = this.siteEmail;
    data['site_favicon'] = this.siteFavicon;
    data['site_logo'] = this.siteLogo;
    data['site_name'] = this.siteName;
    data['twitter_url'] = this.twitterUrl;
    data['updated_at'] = this.updatedAt;
    data['help_support_url'] = this.helpSupportUrl;
    if (this.languageOption != null) {
      data['language_option'] = this.languageOption;
    }
    /*if (this.notification_settings != null) {
      data['notification_settings'] = this.notification_settings.map((v) => v.toJson()).toList();
    }*/
    return data;
  }
}
