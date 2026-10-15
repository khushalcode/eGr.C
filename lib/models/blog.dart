import 'package:project/models/blogCategory.dart';

class Blog {
  String? id;
  String? title;
  String? slug;
  String? categoryId;
  String? image;
  String? description;
  String? shortDescription;
  String? tags;
  List<String>? tagNames;
  String? metaTitle;
  String? metaKeywords;
  String? metaDescription;
  String? status;
  String? imageUrl;
  BlogCategory? category;
  String? viewsCount;
  String? createdAt;
  String? readTime;

  Blog(
      {this.id,
      this.title,
      this.slug,
      this.categoryId,
      this.image,
      this.description,
      this.shortDescription,
      this.tags,
      this.tagNames,
      this.metaTitle,
      this.metaKeywords,
      this.metaDescription,
      this.status,
      this.imageUrl,
      this.category,
      this.viewsCount,
      this.createdAt,
      this.readTime});

  Blog.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    title = json['title'] ?? "";
    slug = json['slug'] ?? "";
    categoryId = (json['category_id']??0).toString();
    image = json['image'] ?? "";
    description = json['description'] ?? "";
    shortDescription = json['short_description'] ?? "";
    tags = json['tags'] ?? "";
    tagNames = json['tag_names'] != null ? List<String>.from(json['tag_names']) : [];
    metaTitle = json['meta_title'] ?? "";
    metaKeywords = json['meta_keywords'] ?? "";
    metaDescription = json['meta_description'] ?? "";
    status = (json['status']??0).toString();
    imageUrl = json['image_url'] ?? "";
    category = json['category'] != null ? new BlogCategory.fromJson(json['category']) : null;
    viewsCount = (json['views_count'] ?? 0).toString();
    createdAt = json['created_at']??"";
    readTime = (json['read_time'] ?? "0").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['category_id'] = this.categoryId;
    data['image'] = this.image;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['tags'] = this.tags;
    data['tag_names'] = this.tagNames;
    data['meta_title'] = this.metaTitle;
    data['meta_keywords'] = this.metaKeywords;
    data['meta_description'] = this.metaDescription;
    data['status'] = this.status;
    data['image_url'] = this.imageUrl;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['views_count'] = this.viewsCount;
    data['created_at'] = this.createdAt;
    data['read_time'] = this.readTime;
    return data;
  }
}
