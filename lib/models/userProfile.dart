class UserProfile {
  String? status;
  String? message;
  String? total;
  UserProfileData? data;

  UserProfile({this.status, this.message, this.total, this.data});

  UserProfile.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    data = json['data'] != null
        ? new UserProfileData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserProfileData {
  User? user;
  String? accessToken;

  UserProfileData({this.user, this.accessToken});

  UserProfileData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    accessToken = json['access_token'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['access_token'] = this.accessToken;
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? countryCode;
  String? mobile;
  String? profile;
  String? balance;
  String? referralCode;
  String? status;
  bool? isSubscriptionPlans;
  String? hasActiveSubscription;
  String? subscriptionName;
  String? subscriptionExpiryDate;

  User({
    this.id,
    this.name,
    this.email,
    this.countryCode,
    this.mobile,
    this.profile,
    this.balance,
    this.referralCode,
    this.status,
    this.isSubscriptionPlans,
    this.hasActiveSubscription,
    this.subscriptionName,
    this.subscriptionExpiryDate,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    email = json['email'].toString();
    countryCode = json['country_code'].toString();
    mobile = json['mobile'].toString();
    profile = json['profile'].toString();
    balance = json['balance'].toString();
    referralCode = json['referral_code'].toString();
    status = json['status'].toString();
    isSubscriptionPlans = (json['is_subscription_plans'] == true || json['is_subscription_plans'].toString() == '1' || json['is_subscription_plans'].toString().toLowerCase() == 'true');
    hasActiveSubscription = json['has_active_subscription']??"0";
    subscriptionName = json['subscription_name']??"";
    subscriptionExpiryDate = json['subscription_expiry_date']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['country_code'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['profile'] = this.profile;
    data['balance'] = this.balance;
    data['referral_code'] = this.referralCode;
    data['status'] = this.status;
    data['is_subscription_plans'] = this.isSubscriptionPlans;
    data['has_active_subscription'] = this.hasActiveSubscription;
    data['subscription_name'] = this.subscriptionName;
    data['subscription_expiry_date'] = this.subscriptionExpiryDate;
    return data;
  }
}
