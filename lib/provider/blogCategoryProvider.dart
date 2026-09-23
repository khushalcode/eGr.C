import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/blogCategory.dart';
import 'package:project/repositories/blogApi.dart';

enum BlogCategoryState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class BlogCategoryProvider extends ChangeNotifier {
  BlogCategoryState blogCategoryState = BlogCategoryState.initial;
  String message = '';
  List<BlogCategory> blogCategories = [];

  Future<void> getBlogCategoryApiProvider({
    required Map<String, String> params,
    required BuildContext context,
  }) async {
    try {
      blogCategoryState = BlogCategoryState.loading;
      notifyListeners();

      Map<String, dynamic> blogCategoryData = await getBlogCategory(context: context, params: params);

      if (blogCategoryData[ApiAndParams.status].toString() == "1") {
        List<BlogCategory> tempCategories = List.from(
          blogCategoryData[ApiAndParams.data],
        ).map((e) => BlogCategory.fromJson(e)).toList();
        // Only add "All" if there is at least 1 category
        if (tempCategories.isNotEmpty) {
          tempCategories.insert(
            0,
            BlogCategory(
              id: "0",
              name: "All",
              slug: "all",
              metaTitle: "all",
              metaKeywords: "all",
              metaDescription: "all",
              status: "1"
            ),
          );
        }

        blogCategories = tempCategories;
        blogCategoryState = BlogCategoryState.loaded;
      } else {
        message = blogCategoryData[ApiAndParams.message] ?? somethingWentWrongLabel;
        blogCategoryState = BlogCategoryState.empty;
      }

      notifyListeners();
    } catch (e) {
      message = e.toString();
      blogCategoryState = BlogCategoryState.error;
      notifyListeners();
      rethrow;
    }
  }
}
