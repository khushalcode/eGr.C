import 'package:project/helper/generalWidgets/blogItemContainer.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/blogCategoryProvider.dart';
import 'package:project/provider/blogProvider.dart';
import 'package:project/screens/ordersHistoryScreen/widgets/orderListShimmer.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  ScrollController scrollController = ScrollController();
  int currentIndex = 0;

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<BlogListProvider>().hasMoreData) {
          blogListApiCall(reset: false);
        }
      }
    }
  }

  blogListApiCall({bool? reset}) {
    if(reset==true){
      context.read<BlogListProvider>().blogList.clear();
      context.read<BlogListProvider>().offset = 0;
    }
    context.read<BlogListProvider>().getBlogApiProvider(params: {}, context: context);
  }

  blogCategoryApiCall() {
    context.read<BlogCategoryProvider>().getBlogCategoryApiProvider(params: {}, context: context);
  }

  apiCall(){
    blogCategoryApiCall();
    blogListApiCall(reset: true);
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    Future.delayed(Duration.zero).then((value) {
      blogListApiCall(reset: false);
      blogCategoryApiCall();
    });
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  getBlogCategoryContainer({
    required BuildContext context,
    required String title,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? ColorsRes.appColor : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(100),
        border: BoxBorder.all(color: isActive ? ColorsRes.appColor : Theme.of(context).scaffoldBackgroundColor, width: 2)
      ),
      alignment: Alignment.center,
      margin: EdgeInsetsDirectional.only(start: 10, bottom: 10, top: 10),
      padding: EdgeInsetsDirectional.only(start: 15, bottom: 10, top: 10, end: 15),
      child: CustomTextLabel(
        text: title,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(color: isActive ? ColorsRes.appColorWhite : ColorsRes.mainTextColor, fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: blogsLabel,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
        actions: [],
      ),
      body: setRefreshIndicator(
        refreshCallback: () async{
          context.read<BlogListProvider>().blogList.clear();
          context.read<BlogListProvider>().offset = 0;
          await apiCall();
          
        },
        child: Column(
          children: [
            getSizedBox(height: 10),
            Consumer<BlogCategoryProvider>(
              builder: (context, blogCategoryProvider, _) {
                if (blogCategoryProvider.blogCategoryState == BlogCategoryState.loaded) {
                  return Container(width: context.width,
                    color: Theme.of(context).cardColor,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(blogCategoryProvider.blogCategories.length, (index) {
                          return GestureDetector(
                            onTap: () async{
                        if (mounted) {
                          await context.read<BlogListProvider>().changeBlogCategorySelectedStatus(int.parse(blogCategoryProvider.blogCategories[index].id!)).then((value) async {
                              if (value) {
                                blogListApiCall(reset: true);
                              }
                            });
                         
                        }},
                            child: getBlogCategoryContainer(
                              isActive: context.watch<BlogListProvider>().selectedBlogCategoryId == int.parse(blogCategoryProvider.blogCategories[index].id!),
                              context: context,
                              title: blogCategoryProvider.blogCategories[index].name.toString(),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Container(color: Theme.of(context).cardColor, padding: const EdgeInsets.all(10), margin: const EdgeInsetsDirectional.only(top: 10), child: blogWidget()),
            ),
          ],
        ),
      ),
    );
  }

//blogCategoryList ui
  Widget blogWidget() {
    return Consumer<BlogListProvider>(
      builder: (context, blogListProvider, _) {

        if (blogListProvider.blogState == BlogState.loading) {
          return OrderListShimmer();
        } else if (blogListProvider.blogList.isEmpty) {
          return /* NoInternetConnectionScreen(
            height: context.height * 0.65,
            message: blogListProvider.message,
            callback: () {
              blogListApiCall(reset: true);
              blogCategoryApiCall();
            },
          ) */
             DefaultBlankItemMessageScreen(
            title: emptyProductListMessageLabel,
            description: emptyProductListDescriptionLabel,
            image: "no_product_icon",
            buttonTitle: tryAgainLabel,
            callback: () {
              blogListApiCall(reset: true);
              blogCategoryApiCall();
            },
          );
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) => getDivider(
              color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.50),
              endIndent: 5,
              indent: 5,
            ),
            controller: scrollController,
            itemCount: blogListProvider.blogList.length,
            itemBuilder: (BuildContext context, int index) {
              final blog = blogListProvider.blogList[index];

              return Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5,
                  end: 5,
                  top: 5,
                  bottom: 5,
                ),
                child: BlogItemContainer(
                  blog: blog,
                  voidCallBack: () {
                    Navigator.pushNamed(
                      context,
                      blogDetailScreen,
                      arguments: [
                        blog
                      ],
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

}
