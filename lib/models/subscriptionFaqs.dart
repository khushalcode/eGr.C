class SubscriptionFaqs {
  String? id;
  String? question;
  String? answer;
  String? sortOrder;
  String? status;
  bool isExpanded = false;

  SubscriptionFaqs({this.id, this.question, this.answer, this.sortOrder, this.status});

  SubscriptionFaqs.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    question = json['question'];
    answer = json['answer'];
    sortOrder = (json['sort_order'] ?? 0).toString();
    status = (json['status'] ?? 0).toString();
    isExpanded = json['is_expanded'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['sort_order'] = this.sortOrder;
    data['status'] = this.status;
    data['is_expanded'] = isExpanded;
    return data;
  }
}
