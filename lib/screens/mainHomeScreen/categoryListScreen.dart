import 'package:project/helper/utils/generalImports.dart';

class CategoryListScreen extends StatefulWidget {
  final ScrollController scrollController;
  final String? categoryName;
  final String? categoryId;

  const CategoryListScreen({Key? key, required this.scrollController, this.categoryName, this.categoryId, a}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  ScrollController scrollController = ScrollController();
  ScrollController productScrollController = ScrollController();
  bool hasProducts = false;

  scrollListener() {
    // var nextPageTrigger = 0.99 * scrollController.position.maxScrollExtent;

    if (scrollController.position.maxScrollExtent == scrollController.offset) {
      // if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (hasProducts) {
          // For products pagination
          if (context.read<ProductListProvider>().hasMoreData) {
            callProductApi(false);
          }
        } else {
          // For subcategories pagination
          if (context.read<CategoryListProvider>().hasMoreData) {
            callApi(false);
          }
        }
      }
    }
  }

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    super.initState();
    //fetch categoryList and check for products
    Future.delayed(Duration.zero).then((value) async {
      await callApi(true);
      await checkAndLoadProducts();
    });
  }

  callApi(bool isReset) {
    if (isReset == true) {
      context.read<CategoryListProvider>().offset = 0;
      context.read<CategoryListProvider>().categories.clear();
    }
    return context
        .read<CategoryListProvider>()
        .getCategoryApiProvider(context: context, params: {ApiAndParams.categoryId: widget.categoryId == null ? "0" : widget.categoryId.toString()});
  }

  Future<void> checkAndLoadProducts() async {
    // Try to fetch products for current category
    if (widget.categoryId != null && widget.categoryId != "0") {
      await callProductApi(true);
      setState(() {
        hasProducts = context.read<ProductListProvider>().products.isNotEmpty;
      });
    }
  }

  Future<void> callProductApi(bool isReset) async {
    try {
      if (isReset) {
        context.read<ProductListProvider>().offset = 0;
        context.read<ProductListProvider>().products = [];
      }

      Map<String, String> params = await Constant.getProductsDefaultParams();
      params[ApiAndParams.categoryId] = widget.categoryId.toString();
      params[ApiAndParams.sort] = ApiAndParams.productListSortTypes[0]; // Default sort

      await context.read<ProductListProvider>().getProductListProvider(context: context, params: params);
    } catch (_) {}
  }

  @override
  dispose() {
    productScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        centerTitle: true,
        title: Consumer<LanguageProvider>(
          builder: (context, provider, child) {
            return CustomTextLabel(
              text: widget.categoryName == null ? getTranslatedValue(context, categoriesLabel) : widget.categoryName.toString(),
              style: TextStyle(color: ColorsRes.mainTextColor),
            );
          },
        ),
        actions: [
          setNotificationIcon(context: context),
        ],
        showBackButton: false,
      ),
      body: setRefreshIndicator(
        refreshCallback: () async {
          context.read<CartListProvider>().getAllCartItems(context: context);
          await callApi(true);
          await checkAndLoadProducts();
        },
        child: Column(
          children: [
            getSearchWidget(context: context),
            Expanded(
              child: hasProducts
                  ? productViewWithSubcategories()
                  : Container(
                      margin: EdgeInsetsDirectional.all(10),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          categoryWidget(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

// Product view with horizontal subcategories at top
  Widget productViewWithSubcategories() {
    return ListView(
      controller: scrollController,
      children: [
        // Horizontal subcategories section
        Consumer<CategoryListProvider>(
          builder: (context, categoryListProvider, _) {
            if (categoryListProvider.categoryState == CategoryState.loaded || categoryListProvider.categoryState == CategoryState.loadingMore) {
              if (categoryListProvider.categories.isEmpty) {
                return SizedBox.shrink();
              }
              return Container(
                margin: EdgeInsetsDirectional.only(start: 10, end: 10, top: 10),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.all(10),
                      child: CustomTextLabel(
                        jsonKey: categoriesLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height/6,//135,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 10),
                        itemCount: categoryListProvider.categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          CategoryItem category = categoryListProvider.categories[index];
                          return Container(
                            width: MediaQuery.of(context).size.height / 9, //90,
                            margin: EdgeInsetsDirectional.only(end: 10),
                            child: CategoryItemContainer(
                              category: category,
                              voidCallBack: () {
                                if (category.hasChild!) {
                                  Navigator.pushNamed(context, categoryListScreen, arguments: [ScrollController(), category.name, category.id.toString()]);
                                } else {
                                  Navigator.pushNamed(context, productListScreen, arguments: ["category", category.id.toString(), category.name]);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (categoryListProvider.categoryState == CategoryState.loading) {
              return Container(
                margin: EdgeInsetsDirectional.only(start: 10, end: 10, top: 10),
                height: 120,
                child: getCategoryShimmer(context: context, count: 3),
              );
            }
            return SizedBox.shrink();
          },
        ),

        // Products section
        Padding(
          padding: EdgeInsetsDirectional.only(/* start: 10, end: 10,  */top: 10),
          child: ProductWidget(
            voidCallBack: () {
              callProductApi(false);
            },
            from: "product_listing",
          ),
        ),
      ],
    );
  }

// categoryList ui (Grid view for when no products)
  Widget categoryWidget() {
    return Consumer<CategoryListProvider>(
      builder: (context, categoryListProvider, _) {
        if (categoryListProvider.categoryState == CategoryState.loaded || categoryListProvider.categoryState == CategoryState.loadingMore) {
          return GridView.builder(
            itemCount: categoryListProvider.categories.length,
            padding: EdgeInsets.symmetric(horizontal: Constant.size10, vertical: Constant.size10),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // Disable GridView scrolling
            itemBuilder: (BuildContext context, int index) {
              CategoryItem category = categoryListProvider.categories[index];

              return CategoryItemContainer(
                category: category,
                voidCallBack: () {
                  if (category.hasChild!) {
                    Navigator.pushNamed(context, categoryListScreen, arguments: [ScrollController(), category.name, category.id.toString()]);
                  } else {
                    Navigator.pushNamed(context, productListScreen, arguments: ["category", category.id.toString(), category.name]);
                  }
                },
              );
            },
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.8, crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          );
        } else if (categoryListProvider.categoryState == CategoryState.loading) {
          return getCategoryShimmer(context: context, count: 9);
        } else {
          return NoInternetConnectionScreen(
            height: context.height * 0.65,
            message: categoryListProvider.message,
            callback: () {
              callApi(true);
            },
          );
        }
      },
    );
  }
}
