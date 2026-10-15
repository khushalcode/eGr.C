class subscriptionDetail {
  String? id;
  String? userId;
  String? planId;
  String? planName;
  String? pricePaid;
  String? discountedPrice;
  String? freeDeliveryAbove;
  String? startDate;
  String? endDate;
  String? status;
  String? totalMoneySaved;
  String? daysRemaining;
  String? deliveriesNumber;

  subscriptionDetail(
      {this.id,
      this.userId,
      this.planId,
      this.planName,
      this.pricePaid,
      this.discountedPrice,
      this.freeDeliveryAbove,
      this.startDate,
      this.endDate,
      this.status,
      this.totalMoneySaved,
      this.daysRemaining,
      this.deliveriesNumber});

  subscriptionDetail.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    userId = (json['user_id'] ?? 0).toString();
    planId = (json['plan_id'] ?? 0).toString();
    planName = json['plan_name'];
    pricePaid = (json['price_paid'] ?? 0).toString();
    discountedPrice = (json['discounted_price'] ?? 0).toString();
    freeDeliveryAbove = (json['free_delivery_above'] ?? 0).toString();
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    totalMoneySaved = (json['total_money_saved'] ?? 0).toString();
    daysRemaining = (json['days_remaining'] ?? 0).toString();
    deliveriesNumber = (json['deliveries_number'] ?? 0).toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['plan_id'] = this.planId;
    data['plan_name'] = this.planName;
    data['price_paid'] = this.pricePaid;
    data['discounted_price'] = this.discountedPrice;
    data['free_delivery_above'] = this.freeDeliveryAbove;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['status'] = this.status;
    data['total_money_saved'] = this.totalMoneySaved;
    data['days_remaining'] = this.daysRemaining;
    data['deliveries_number'] = this.deliveriesNumber;
    return data;
  }
}
