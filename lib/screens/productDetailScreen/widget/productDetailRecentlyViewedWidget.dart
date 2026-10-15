import 'package:project/helper/utils/generalImports.dart';

class ProductRecentlyViewedWidget extends StatefulWidget {
  final String productId;

  const ProductRecentlyViewedWidget({
    super.key,
    required this.productId,
  });

  @override
  State<ProductRecentlyViewedWidget> createState() => _ProductRecentlyViewedWidgetState();
}

class _ProductRecentlyViewedWidgetState extends State<ProductRecentlyViewedWidget> {
  Future<void> fetchRecentlyViewedProducts() async {
    try {
      final provider = context.read<RecentlyVisitedProvider>();
      provider.reset();

      Map<String, String> params = {ApiAndParams.productId: widget.productId};

      await provider.getRecentlyVisitedProvider(context: context, params: params);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Constant.session.isUserLoggedIn()) {
        fetchRecentlyViewedProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Constant.session.isUserLoggedIn()) {
      return const SizedBox.shrink();
    }

    return Consumer<RecentlyVisitedProvider>(
      builder: (context, recentlyVisitedProvider, _) {
        final products = recentlyVisitedProvider.recentlyVisitedProducts;

        if (products.isEmpty && recentlyVisitedProvider.recentlyVisitedState == RecentlyVisitedState.loading) {
          return const SizedBox.shrink(); // Initial loading can have a shimmer here if needed
        }

        if (products.isEmpty) {
          return const SizedBox.shrink(); // No recently viewed products
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: Constant.size10),
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              child: CustomTextLabel(
                jsonKey: recentlyViewedLabel,
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorsRes.mainTextColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
            RepaintBoundary(
              child: SizedBox(
                height: context.width * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(products.length, (index) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: HomeScreenProductListItem(
                          product: products[index],
                          position: index,
                          providerType: ProductListProviderType.recentlyVisited,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
