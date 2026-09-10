import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/blog.dart';
import 'package:project/repositories/blogApi.dart';

enum BlogState {
  initial,
  loading,
  loadingMore,
  loaded,
  empty,
  error,
}

class BlogListProvider extends ChangeNotifier {
  BlogState blogState = BlogState.initial;
  String message = '';
  List<Blog> blogList = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;
  int? selectedBlogCategoryId = 0;

  getBlogApiProvider({
    required Map<String, String> params,
    required BuildContext context,
  }) async {
    try {
      if (offset == 0) {
        blogState = BlogState.loading;
        notifyListeners();
      } else {
        blogState = BlogState.loadingMore;
        notifyListeners();
      }

      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();
      params[ApiAndParams.categoryId] = selectedBlogCategoryId.toString();

      Map<String, dynamic> blogData =
          await getBlogList(context: context, params: params);

      if (blogData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(blogData[ApiAndParams.total].toString());
        List<Blog> tempBlog = List.from(blogData[ApiAndParams.data])
            .map((e) => Blog.fromJson(e))
            .toList();

        blogList.addAll(tempBlog);

        hasMoreData = totalData > blogList.length;
        if (hasMoreData) {
          offset += (Constant.defaultDataLoadLimitAtOnce + 20);
        }

        blogState = BlogState.loaded;
        notifyListeners();
      } else {
        message = blogData[ApiAndParams.status];
        blogState = BlogState.empty;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      blogState = BlogState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> changeBlogCategorySelectedStatus(int index) async {
    if (selectedBlogCategoryId.toString() != index.toString()) {
      selectedBlogCategoryId = index;
      notifyListeners();
      offset = 0;
      blogList = [];
      return true;
    } else {
      return false;
    }
  }
}
