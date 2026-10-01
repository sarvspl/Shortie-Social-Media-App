// To parse this JSON data, do
//
//     final adminSettingModel = adminSettingModelFromJson(jsonString);

import 'dart:convert';

AdminSettingModel adminSettingModelFromJson(String str) => AdminSettingModel.fromJson(json.decode(str));

String adminSettingModelToJson(AdminSettingModel data) => json.encode(data.toJson());

class AdminSettingModel {
  bool? status;
  String? message;
  Data? data;

  AdminSettingModel({
    this.status,
    this.message,
    this.data,
  });

  factory AdminSettingModel.fromJson(Map<String, dynamic> json) => AdminSettingModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Currency? currency;
  Storage? storage;
  Android? android;
  Android? ios;
  String? id;
  bool? stripeSwitch;
  String? stripePublishableKey;
  String? stripeSecretKey;
  bool? razorPaySwitch;
  String? razorPayId;
  String? razorSecretKey;
  String? privacyPolicyLink;
  String? termsOfUsePolicyLink;
  String? zegoAppId;
  String? zegoAppSignIn;
  List<dynamic>? paymentGateway;
  bool? isFakeData;
  int? durationOfShorts;
  int? minCoinForCashOut;
  int? minWithdrawalRequestedCoin;
  DateTime? createdAt;
  DateTime? updatedAt;
  PrivateKey? privateKey;
  List<String>? videoBanned;
  bool? googlePlaySwitch;
  String? androidLicenseKey;
  String? iosLicenseKey;
  String? sightengineSecret;
  String? sightengineUser;
  int? loginBonus;
  int? adDisplayIndex;
  String? flutterWaveId;
  bool? flutterWaveSwitch;
  bool? isChatAdEnabled;
  bool? isChatBackButtonAdEnabled;
  bool? isFeedAdEnabled;
  bool? isGoogle;
  bool? isLiveStreamBackButtonAdEnabled;
  bool? isVideoAdEnabled;
  bool? isEffectActive;
  bool? isWatermarkOn;
  String? watermarkIcon;
  int? watermarkType;
  List<String>? postBanned;
  String? resendApiKey;
  String? zegoServerSecret;
  String? awsAccessKey;
  String? awsBucketName;
  String? awsEndpoint;
  String? awsHostname;
  String? awsRegion;
  String? awsSecretKey;
  String? doAccessKey;
  String? doBucketName;
  String? doEndpoint;
  String? doHostname;
  String? doRegion;
  String? doSecretKey;
  String? openAiKey;
  int? pkEndTime;
  List<String>? profilePictureCollection;
  bool? cashfreeAndroidEnabled;
  String? cashfreeClientId;
  String? cashfreeClientSecret;
  bool? cashfreeIosEnabled;
  bool? flutterwaveIosEnabled;
  bool? googlePayIosEnabled;
  bool? paypalAndroidEnabled;
  String? paypalClientId;
  bool? paypalIosEnabled;
  String? paypalSecretKey;
  bool? paystackAndroidEnabled;
  bool? paystackIosEnabled;
  String? paystackPublicKey;
  String? paystackSecretKey;
  bool? razorpayIosEnabled;
  bool? stripeIosEnabled;
  int? actionMinute;
  int? actionEndMinute;
  int? adminFeeRate;
  int? multiplier;
  String? androidAppLink;
  String? androidAppVersion;
  String? iosAppLink;
  String? iosAppVersion;

  Data({
    this.currency,
    this.storage,
    this.android,
    this.ios,
    this.id,
    this.stripeSwitch,
    this.stripePublishableKey,
    this.stripeSecretKey,
    this.razorPaySwitch,
    this.razorPayId,
    this.razorSecretKey,
    this.privacyPolicyLink,
    this.termsOfUsePolicyLink,
    this.zegoAppId,
    this.zegoAppSignIn,
    this.paymentGateway,
    this.isFakeData,
    this.durationOfShorts,
    this.minCoinForCashOut,
    this.minWithdrawalRequestedCoin,
    this.createdAt,
    this.updatedAt,
    this.privateKey,
    this.videoBanned,
    this.googlePlaySwitch,
    this.androidLicenseKey,
    this.iosLicenseKey,
    this.sightengineSecret,
    this.sightengineUser,
    this.loginBonus,
    this.adDisplayIndex,
    this.flutterWaveId,
    this.flutterWaveSwitch,
    this.isChatAdEnabled,
    this.isChatBackButtonAdEnabled,
    this.isFeedAdEnabled,
    this.isGoogle,
    this.isLiveStreamBackButtonAdEnabled,
    this.isVideoAdEnabled,
    this.isEffectActive,
    this.isWatermarkOn,
    this.watermarkIcon,
    this.watermarkType,
    this.postBanned,
    this.resendApiKey,
    this.zegoServerSecret,
    this.awsAccessKey,
    this.awsBucketName,
    this.awsEndpoint,
    this.awsHostname,
    this.awsRegion,
    this.awsSecretKey,
    this.doAccessKey,
    this.doBucketName,
    this.doEndpoint,
    this.doHostname,
    this.doRegion,
    this.doSecretKey,
    this.openAiKey,
    this.pkEndTime,
    this.profilePictureCollection,
    this.cashfreeAndroidEnabled,
    this.cashfreeClientId,
    this.cashfreeClientSecret,
    this.cashfreeIosEnabled,
    this.flutterwaveIosEnabled,
    this.googlePayIosEnabled,
    this.paypalAndroidEnabled,
    this.paypalClientId,
    this.paypalIosEnabled,
    this.paypalSecretKey,
    this.paystackAndroidEnabled,
    this.paystackIosEnabled,
    this.paystackPublicKey,
    this.paystackSecretKey,
    this.razorpayIosEnabled,
    this.stripeIosEnabled,
    this.actionMinute,
    this.actionEndMinute,
    this.adminFeeRate,
    this.multiplier,
    this.androidAppLink,
    this.androidAppVersion,
    this.iosAppLink,
    this.iosAppVersion,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
    storage: json["storage"] == null ? null : Storage.fromJson(json["storage"]),
    android: json["android"] == null ? null : Android.fromJson(json["android"]),
    ios: json["ios"] == null ? null : Android.fromJson(json["ios"]),
    id: json["_id"],
    stripeSwitch: json["stripeSwitch"],
    stripePublishableKey: json["stripePublishableKey"],
    stripeSecretKey: json["stripeSecretKey"],
    razorPaySwitch: json["razorPaySwitch"],
    razorPayId: json["razorPayId"],
    razorSecretKey: json["razorSecretKey"],
    privacyPolicyLink: json["privacyPolicyLink"],
    termsOfUsePolicyLink: json["termsOfUsePolicyLink"],
    zegoAppId: json["zegoAppId"],
    zegoAppSignIn: json["zegoAppSignIn"],
    paymentGateway: json["paymentGateway"] == null ? [] : List<dynamic>.from(json["paymentGateway"]!.map((x) => x)),
    isFakeData: json["isFakeData"],
    durationOfShorts: json["durationOfShorts"],
    minCoinForCashOut: json["minCoinForCashOut"],
    minWithdrawalRequestedCoin: json["minWithdrawalRequestedCoin"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    privateKey: json["privateKey"] == null ? null : PrivateKey.fromJson(json["privateKey"]),
    videoBanned: json["videoBanned"] == null ? [] : List<String>.from(json["videoBanned"]!.map((x) => x)),
    googlePlaySwitch: json["googlePlaySwitch"],
    androidLicenseKey: json["androidLicenseKey"],
    iosLicenseKey: json["iosLicenseKey"],
    sightengineSecret: json["sightengineSecret"],
    sightengineUser: json["sightengineUser"],
    loginBonus: json["loginBonus"],
    adDisplayIndex: json["adDisplayIndex"],
    flutterWaveId: json["flutterWaveId"],
    flutterWaveSwitch: json["flutterWaveSwitch"],
    isChatAdEnabled: json["isChatAdEnabled"],
    isChatBackButtonAdEnabled: json["isChatBackButtonAdEnabled"],
    isFeedAdEnabled: json["isFeedAdEnabled"],
    isGoogle: json["isGoogle"],
    isLiveStreamBackButtonAdEnabled: json["isLiveStreamBackButtonAdEnabled"],
    isVideoAdEnabled: json["isVideoAdEnabled"],
    isEffectActive: json["isEffectActive"],
    isWatermarkOn: json["isWatermarkOn"],
    watermarkIcon: json["watermarkIcon"],
    watermarkType: json["watermarkType"],
    postBanned: json["postBanned"] == null ? [] : List<String>.from(json["postBanned"]!.map((x) => x)),
    resendApiKey: json["resendApiKey"],
    zegoServerSecret: json["zegoServerSecret"],
    awsAccessKey: json["awsAccessKey"],
    awsBucketName: json["awsBucketName"],
    awsEndpoint: json["awsEndpoint"],
    awsHostname: json["awsHostname"],
    awsRegion: json["awsRegion"],
    awsSecretKey: json["awsSecretKey"],
    doAccessKey: json["doAccessKey"],
    doBucketName: json["doBucketName"],
    doEndpoint: json["doEndpoint"],
    doHostname: json["doHostname"],
    doRegion: json["doRegion"],
    doSecretKey: json["doSecretKey"],
    openAiKey: json["openAIKey"],
    pkEndTime: json["pkEndTime"],
    profilePictureCollection: json["profilePictureCollection"] == null ? [] : List<String>.from(json["profilePictureCollection"]!.map((x) => x)),
    cashfreeAndroidEnabled: json["cashfreeAndroidEnabled"],
    cashfreeClientId: json["cashfreeClientId"],
    cashfreeClientSecret: json["cashfreeClientSecret"],
    cashfreeIosEnabled: json["cashfreeIosEnabled"],
    flutterwaveIosEnabled: json["flutterwaveIosEnabled"],
    googlePayIosEnabled: json["googlePayIosEnabled"],
    paypalAndroidEnabled: json["paypalAndroidEnabled"],
    paypalClientId: json["paypalClientId"],
    paypalIosEnabled: json["paypalIosEnabled"],
    paypalSecretKey: json["paypalSecretKey"],
    paystackAndroidEnabled: json["paystackAndroidEnabled"],
    paystackIosEnabled: json["paystackIosEnabled"],
    paystackPublicKey: json["paystackPublicKey"],
    paystackSecretKey: json["paystackSecretKey"],
    razorpayIosEnabled: json["razorpayIosEnabled"],
    stripeIosEnabled: json["stripeIosEnabled"],
    actionMinute: json["actionMinute"],
    actionEndMinute: json["actionEndMinute"],
    adminFeeRate: json["adminFeeRate"],
    multiplier: json["multiplier"],
      androidAppLink:json["androidAppLink"],
      androidAppVersion:json["androidAppVersion"],
      iosAppLink:json["iosAppLink"],
      iosAppVersion:json["iosAppVersion"],
  );

  Map<String, dynamic> toJson() => {
    "currency": currency?.toJson(),
    "storage": storage?.toJson(),
    "android": android?.toJson(),
    "ios": ios?.toJson(),
    "_id": id,
    "stripeSwitch": stripeSwitch,
    "stripePublishableKey": stripePublishableKey,
    "stripeSecretKey": stripeSecretKey,
    "razorPaySwitch": razorPaySwitch,
    "razorPayId": razorPayId,
    "razorSecretKey": razorSecretKey,
    "privacyPolicyLink": privacyPolicyLink,
    "termsOfUsePolicyLink": termsOfUsePolicyLink,
    "zegoAppId": zegoAppId,
    "zegoAppSignIn": zegoAppSignIn,
    "paymentGateway": paymentGateway == null ? [] : List<dynamic>.from(paymentGateway!.map((x) => x)),
    "isFakeData": isFakeData,
    "durationOfShorts": durationOfShorts,
    "minCoinForCashOut": minCoinForCashOut,
    "minWithdrawalRequestedCoin": minWithdrawalRequestedCoin,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "privateKey": privateKey?.toJson(),
    "videoBanned": videoBanned == null ? [] : List<dynamic>.from(videoBanned!.map((x) => x)),
    "googlePlaySwitch": googlePlaySwitch,
    "androidLicenseKey": androidLicenseKey,
    "iosLicenseKey": iosLicenseKey,
    "sightengineSecret": sightengineSecret,
    "sightengineUser": sightengineUser,
    "loginBonus": loginBonus,
    "adDisplayIndex": adDisplayIndex,
    "flutterWaveId": flutterWaveId,
    "flutterWaveSwitch": flutterWaveSwitch,
    "isChatAdEnabled": isChatAdEnabled,
    "isChatBackButtonAdEnabled": isChatBackButtonAdEnabled,
    "isFeedAdEnabled": isFeedAdEnabled,
    "isGoogle": isGoogle,
    "isLiveStreamBackButtonAdEnabled": isLiveStreamBackButtonAdEnabled,
    "isVideoAdEnabled": isVideoAdEnabled,
    "isEffectActive": isEffectActive,
    "isWatermarkOn": isWatermarkOn,
    "watermarkIcon": watermarkIcon,
    "watermarkType": watermarkType,
    "postBanned": postBanned == null ? [] : List<dynamic>.from(postBanned!.map((x) => x)),
    "resendApiKey": resendApiKey,
    "zegoServerSecret": zegoServerSecret,
    "awsAccessKey": awsAccessKey,
    "awsBucketName": awsBucketName,
    "awsEndpoint": awsEndpoint,
    "awsHostname": awsHostname,
    "awsRegion": awsRegion,
    "awsSecretKey": awsSecretKey,
    "doAccessKey": doAccessKey,
    "doBucketName": doBucketName,
    "doEndpoint": doEndpoint,
    "doHostname": doHostname,
    "doRegion": doRegion,
    "doSecretKey": doSecretKey,
    "openAIKey": openAiKey,
    "pkEndTime": pkEndTime,
    "profilePictureCollection": profilePictureCollection == null ? [] : List<dynamic>.from(profilePictureCollection!.map((x) => x)),
    "cashfreeAndroidEnabled": cashfreeAndroidEnabled,
    "cashfreeClientId": cashfreeClientId,
    "cashfreeClientSecret": cashfreeClientSecret,
    "cashfreeIosEnabled": cashfreeIosEnabled,
    "flutterwaveIosEnabled": flutterwaveIosEnabled,
    "googlePayIosEnabled": googlePayIosEnabled,
    "paypalAndroidEnabled": paypalAndroidEnabled,
    "paypalClientId": paypalClientId,
    "paypalIosEnabled": paypalIosEnabled,
    "paypalSecretKey": paypalSecretKey,
    "paystackAndroidEnabled": paystackAndroidEnabled,
    "paystackIosEnabled": paystackIosEnabled,
    "paystackPublicKey": paystackPublicKey,
    "paystackSecretKey": paystackSecretKey,
    "razorpayIosEnabled": razorpayIosEnabled,
    "stripeIosEnabled": stripeIosEnabled,
    "actionMinute":actionMinute,
    "actionEndMinute":actionEndMinute,
    "adminFeeRate":adminFeeRate,
    "multiplier":multiplier,
    "androidAppLink":androidAppLink,
    "androidAppVersion":androidAppVersion,
    "iosAppLink":iosAppLink,
    "iosAppVersion":iosAppVersion,
  };
}

class Android {
  Google? google;

  Android({
    this.google,
  });

  factory Android.fromJson(Map<String, dynamic> json) => Android(
    google: json["google"] == null ? null : Google.fromJson(json["google"]),
  );

  Map<String, dynamic> toJson() => {
    "google": google?.toJson(),
  };
}

class Google {
  String? interstitial;
  String? native;
  String? nativeAdVideo;

  Google({
    this.interstitial,
    this.native,
    this.nativeAdVideo,
  });

  factory Google.fromJson(Map<String, dynamic> json) => Google(
    interstitial: json["interstitial"],
    native: json["native"],
    nativeAdVideo: json["nativeAdVideo"],
  );

  Map<String, dynamic> toJson() => {
    "interstitial": interstitial,
    "native": native,
    "nativeAdVideo": nativeAdVideo,
  };
}

class Currency {
  String? name;
  String? symbol;
  String? countryCode;
  String? currencyCode;
  bool? isDefault;

  Currency({
    this.name,
    this.symbol,
    this.countryCode,
    this.currencyCode,
    this.isDefault,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    name: json["name"],
    symbol: json["symbol"],
    countryCode: json["countryCode"],
    currencyCode: json["currencyCode"],
    isDefault: json["isDefault"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "symbol": symbol,
    "countryCode": countryCode,
    "currencyCode": currencyCode,
    "isDefault": isDefault,
  };
}

class PrivateKey {
  String? type;
  String? projectId;
  String? privateKeyId;
  String? privateKey;
  String? clientEmail;
  String? clientId;
  String? authUri;
  String? tokenUri;
  String? authProviderX509CertUrl;
  String? clientX509CertUrl;
  String? universeDomain;

  PrivateKey({
    this.type,
    this.projectId,
    this.privateKeyId,
    this.privateKey,
    this.clientEmail,
    this.clientId,
    this.authUri,
    this.tokenUri,
    this.authProviderX509CertUrl,
    this.clientX509CertUrl,
    this.universeDomain,
  });

  factory PrivateKey.fromJson(Map<String, dynamic> json) => PrivateKey(
    type: json["type"],
    projectId: json["project_id"],
    privateKeyId: json["private_key_id"],
    privateKey: json["private_key"],
    clientEmail: json["client_email"],
    clientId: json["client_id"],
    authUri: json["auth_uri"],
    tokenUri: json["token_uri"],
    authProviderX509CertUrl: json["auth_provider_x509_cert_url"],
    clientX509CertUrl: json["client_x509_cert_url"],
    universeDomain: json["universe_domain"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "project_id": projectId,
    "private_key_id": privateKeyId,
    "private_key": privateKey,
    "client_email": clientEmail,
    "client_id": clientId,
    "auth_uri": authUri,
    "token_uri": tokenUri,
    "auth_provider_x509_cert_url": authProviderX509CertUrl,
    "client_x509_cert_url": clientX509CertUrl,
    "universe_domain": universeDomain,
  };
}

class Storage {
  bool? awsS3;
  bool? digitalOcean;
  bool? local;

  Storage({
    this.awsS3,
    this.digitalOcean,
    this.local,
  });

  factory Storage.fromJson(Map<String, dynamic> json) => Storage(
    awsS3: json["awsS3"],
    digitalOcean: json["digitalOcean"],
    local: json["local"],
  );

  Map<String, dynamic> toJson() => {
    "awsS3": awsS3,
    "digitalOcean": digitalOcean,
    "local": local,
  };
}
