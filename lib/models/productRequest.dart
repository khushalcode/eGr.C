class ProductRequest {
  String? id;
  String? customerId;
  String? description;
  String? image;
  String? status;
  String? productId;
  String? adminNotes;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;
  Product? product;

  ProductRequest(
      {this.id,
      this.customerId,
      this.description,
      this.image,
      this.status,
      this.productId,
      this.adminNotes,
      this.createdAt,
      this.updatedAt,
      this.imageUrl,
      this.product});

  ProductRequest.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    customerId = (json['customer_id'] ?? 0).toString();
    description = json['description']??"";
    image = json['image'] ?? "";
    status = json['status'] ?? "";
    productId = (json['product_id'] ?? 0).toString();
    adminNotes = json['admin_notes'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    imageUrl = json['image_url'] ?? "";
    product = json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['description'] = this.description;
    data['image'] = this.image;
    data['status'] = this.status;
    data['product_id'] = this.productId;
    data['admin_notes'] = this.adminNotes;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['image_url'] = this.imageUrl;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    return data;
  }
}

class Product {
  String? id;
  String? name;
  String? sellerName;

  Product({this.id, this.name, this.sellerName});

  Product.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? 0).toString();
    name = json['name'] ?? "";
    sellerName = json['seller_name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['seller_name'] = this.sellerName;
    return data;
  }
}
