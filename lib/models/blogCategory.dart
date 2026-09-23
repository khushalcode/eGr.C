class BlogCategory {
  String? id;
  String? name;
  String? slug;
  String? metaTitle;
  String? metaKeywords;
  String? metaDescription;
  String? status;
  String? activeBlogsCount;

  BlogCategory({this.id, this.name, this.slug, this.metaTitle, this.metaKeywords, this.metaDescription, this.status, this.activeBlogsCount});

  BlogCategory.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    name = json['name'] ?? "";
    slug = json['slug'] ?? "";
    metaTitle = json['meta_title'] ?? "";
    metaKeywords = json['meta_keywords'] ?? "";
    metaDescription = json['meta_description'] ?? "";
    status = (json['status']?? 0).toString();
    activeBlogsCount = (json['active_blogs_count']??0).toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['meta_title'] = this.metaTitle;
    data['meta_keywords'] = this.metaKeywords;
    data['meta_description'] = this.metaDescription;
    data['status'] = this.status;
    data['active_blogs_count'] = this.activeBlogsCount;
    return data;
  }
}
