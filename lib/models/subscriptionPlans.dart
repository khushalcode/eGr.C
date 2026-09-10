class subscriptionPlans {
  List<Plans>? plans;
  String? subscriptionName;

  subscriptionPlans({this.plans, this.subscriptionName});

  subscriptionPlans.fromJson(Map<String, dynamic> json) {
    if (json['plans'] != null) {
      plans = <Plans>[];
      json['plans'].forEach((v) {
        plans!.add(new Plans.fromJson(v));
      });
    }
    subscriptionName = json['subscription_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.plans != null) {
      data['plans'] = this.plans!.map((v) => v.toJson()).toList();
    }
    data['subscription_name'] = this.subscriptionName;
    return data;
  }
}

class Plans {
  String? id;
  String? name;
  String? days;
  String? price;
  String? discountedPrice;
  String? freeDeliveryAbove;
  String? status;
  String? iosProductId;

  Plans({this.id, this.name, this.days, this.price, this.discountedPrice, this.freeDeliveryAbove, this.status, this.iosProductId});

  Plans.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    name = json['name'];
    days = (json['days'] ?? 0).toString();
    price = (json['price']??0).toString();
    discountedPrice = (json['discounted_price'] ?? 0).toString();
    freeDeliveryAbove = (json['free_delivery_above'] ?? 0).toString();
    status = (json['status'] ?? 0).toString();
    iosProductId = (json['ios_product_id']??0).toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['days'] = this.days;
    data['price'] = this.price;
    data['discounted_price'] = this.discountedPrice;
    data['free_delivery_above'] = this.freeDeliveryAbove;
    data['status'] = this.status;
    data['ios_product_id'] = this.iosProductId;
    return data;
  }
}
