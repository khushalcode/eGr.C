import 'package:project/helper/utils/generalImports.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  const HomeScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<OfferImages>> map = {};
  bool _imagesPreCached = false;

  @override
  void initState() {
    super.initState();
    // Attach scroll listener for pagination
    widget.scrollController.addListener(scrollListener);
    //fetch productList from api
    Future.delayed(Duration.zero).then(
      (value) async {
        await getAppSettings(context: context);

        Map<String, String> params = await Constant.getProductsDefaultParams();
        await context.read<HomeScreenProvider>().getHomeScreenApiProvider(context: context, params: params);

        await context.read<ProductListProvider>().getProductListProvider(context: context, params: params);

        if (Constant.session.isUserLoggedIn()) {
          await context.read<CartProvider>().getCartListProvider(context: context);

          await context.read<CartListProvider>().getAllCartItems(context: context);

          await getUserDetail(context: context).then(
            (value) {
              if (value[ApiAndParams.status].toString() == "1") {
                context.read<UserProfileProvider>().updateUserDataInSession(value, context);
              }
            },
          );
        } else {
          context.read<CartListProvider>().setGuestCartItems();
          if (context.read<CartListProvider>().cartList.isNotEmpty) {
            await context.read<CartProvider>().getGuestCartListProvider(context: context);
          }
        }
      },
    );
  }

  scrollListener() async {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * widget.scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (widget.scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<ProductListProvider>().hasMoreData && context.read<ProductListProvider>().productState != ProductState.loadingMore) {
          Map<String, String> params = await Constant.getProductsDefaultParams();

          await context.read<ProductListProvider>().getProductListProvider(context: context, params: params);
        }
      }
    }
  }

  @override
  dispose() {
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  refreshList() async {
    await getAppSettings(context: context);

    Map<String, String> params = await Constant.getProductsDefaultParams();
    await context.read<HomeScreenProvider>().getHomeScreenApiProvider(context: context, params: params);

    await context.read<ProductListProvider>().getProductListProvider(context: context, params: params);

    if (Constant.session.isUserLoggedIn()) {
      await context.read<CartProvider>().getCartListProvider(context: context);

      await context.read<CartListProvider>().getAllCartItems(context: context);

      await getUserDetail(context: context).then(
        (value) {
          if (value[ApiAndParams.status].toString() == "1") {
            context.read<UserProfileProvider>().updateUserDataInSession(value, context);
          }
        },
      );
    } else {
      context.read<CartListProvider>().setGuestCartItems();
      if (context.read<CartListProvider>().cartList.isNotEmpty) {
        await context.read<CartProvider>().getGuestCartListProvider(context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: getAppBar(
        context: context,
        title: DeliveryAddressWidget(),
        centerTitle: false,
        actions: [
          (Constant.session.isUserLoggedIn() && Constant.session.isSubscriptionPlansAvailable())?Container(padding: EdgeInsetsDirectional.all(4), decoration: DesignConfig.boxDecoration(Theme.of(context).primaryColor, 100),
          child: Row(children:[
            defaultImg(
                  image: AppAssets.subscriptionIcon,
                  height: 20,
                  width: 20,
                ),
                getSizedBox(width: 4),
                CustomTextLabel(
                  jsonKey: maxLabel,
                  style: TextStyle(
                    color: ColorsRes.appColorWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
          ])): SizedBox.shrink(),
          setNotificationIcon(context: context),
        ],
        showBackButton: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              getSearchWidget(
                context: context,
              ),
              Expanded(
                child: setRefreshIndicator(
                  refreshCallback: () async {
                    refreshList();
                    /* context
                        .read<CartListProvider>()
                        .getAllCartItems(context: context);
                    Map<String, String> params =
                        await Constant.getProductsDefaultParams();
                    return await context
                        .read<HomeScreenProvider>()
                        .getHomeScreenApiProvider(
                            context: context, params: params); */
                  },
                  child: Consumer<HomeScreenProvider>(
                    builder: (context, homeScreenProvider, _) {
                      map = homeScreenProvider.homeOfferImagesMap;
                      if (homeScreenProvider.homeScreenState == HomeScreenState.loaded) {
                        // Precache images only once using post frame callback
                        if (!_imagesPreCached && homeScreenProvider.homeScreenData.sliders != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            for (int i = 0; i < homeScreenProvider.homeScreenData.sliders!.length; i++) {
                              if (homeScreenProvider.homeScreenData.sliders?[i].imageUrl?.isNotEmpty == true) {
                                precacheImage(
                                  NetworkImage(homeScreenProvider.homeScreenData.sliders![i].imageUrl!),
                                  context,
                                );
                              }
                            }
                            _imagesPreCached = true;
                          });
                        }
                        return CustomScrollView(
                          controller: widget.scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          cacheExtent: 500, // Improve scroll performance
                          slivers: [
                            // Top Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'top'),
                              ),
                            ),
                            // Top Offer Images
                            if (map.containsKey("top"))
                              SliverToBoxAdapter(
                                child: RepaintBoundary(
                                  child: OfferImagesWidget(
                                    offerImages: map["top"]!.toList(),
                                  ),
                                ),
                              ),
                            // Slider
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: ChangeNotifierProvider<SliderImagesProvider>(
                                  create: (context) => SliderImagesProvider(),
                                  child: SliderImageWidget(
                                    sliders: homeScreenProvider.homeScreenData.sliders ?? [],
                                  ),
                                ),
                              ),
                            ),
                            // Below Slider Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'below_slider'),
                              ),
                            ),
                            // Below Slider Offer Images
                            if (map.containsKey("below_slider"))
                              SliverToBoxAdapter(
                                child: RepaintBoundary(
                                  child: OfferImagesWidget(
                                    offerImages: map["below_slider"]!.toList(),
                                  ),
                                ),
                              ),
                            // Categories
                            if (homeScreenProvider.homeScreenData.categories != null && homeScreenProvider.homeScreenData.categories!.isNotEmpty)
                              SliverToBoxAdapter(
                                child: RepaintBoundary(
                                  child: CategoryWidget(categories: homeScreenProvider.homeScreenData.categories),
                                ),
                              ),
                            // Below Category Offer Images
                            if (map.containsKey("below_category"))
                              SliverToBoxAdapter(
                                child: RepaintBoundary(
                                  child: OfferImagesWidget(
                                    offerImages: map["below_category"]!.toList(),
                                  ),
                                ),
                              ),
                            // Below Category Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'below_category'),
                              ),
                            ),
                            // Brands
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: BrandWidget(),
                              ),
                            ),
                            // Below Brands Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'custom_below_shop_by_brands'),
                              ),
                            ),
                            // Sellers
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SellerWidget(),
                              ),
                            ),
                            // Below Sellers Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'below_shop_by_seller'),
                              ),
                            ),
                            // Country of Origin
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: CountryOfOriginWidget(),
                              ),
                            ),
                            // Below Country Section
                            SliverToBoxAdapter(
                              child: RepaintBoundary(
                                child: SectionWidget(position: 'below_shop_by_country_of_origin'),
                              ),
                            ),
                            // Products Header
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  getSizedBox(height: 10),
                                  RepaintBoundary(
                                    child: TitleHeaderWithViewAllOption(
                                      title: getTranslatedValue(context, allProductsLabel),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          productListScreen,
                                          arguments: ["home", "0", "all_products"],
                                        );
                                      },
                                    ),
                                  ),
                                  getSizedBox(height: 10),
                                ],
                              ),
                            ),
                            // Products List
                            Consumer<ProductListProvider>(
                              builder: (context, productListProvider, _) {
                                List<ProductListItem> products = productListProvider.products;
                                // Limit to maximum 10 products
                                List<ProductListItem> displayProducts = products.length > 10
                                    ? products.sublist(0, 10)
                                    : products;
                                if (productListProvider.productState == ProductState.loaded ||
                                    productListProvider.productState == ProductState.loadingMore) {
                                  return SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index < displayProducts.length) {
                                          return RepaintBoundary(
                                            child: ProductListItemContainer(product: displayProducts[index]),
                                          );
                                        }
                                        return null;
                                      },
                                      childCount: displayProducts.length,
                                    ),
                                  );
                                } else if (productListProvider.productState == ProductState.loading) {
                                  return SliverToBoxAdapter(
                                    child: getProductListShimmer(context: context, isGrid: false),
                                  );
                                } else {
                                  return const SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  );
                                }
                              },
                            ),
                            // Bottom Spacing for Cart
                            SliverToBoxAdapter(
                              child: Consumer<CartProvider>(
                                builder: (context, cartProvider, _) {
                                  return cartProvider.totalItemsCount > 0 ? getSizedBox(height: 65) : const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        );
                      } else if (homeScreenProvider.homeScreenState == HomeScreenState.loading ||
                          homeScreenProvider.homeScreenState == HomeScreenState.initial) {
                        return CustomScrollView(
                          controller: widget.scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: getHomeScreenShimmer(context),
                            ),
                          ],
                        );
                      } else {
                        return CustomScrollView(
                          controller: widget.scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: NoInternetConnectionScreen(
                                height: context.height * 0.65,
                                message: homeScreenProvider.message,
                                callback: () async {
                                  Map<String, String> params = await Constant.getProductsDefaultParams();
                                  await context.read<HomeScreenProvider>().getHomeScreenApiProvider(context: context, params: params);
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          if (context.watch<CartProvider>().totalItemsCount > 0)
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: CartOverlay(),
            ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

