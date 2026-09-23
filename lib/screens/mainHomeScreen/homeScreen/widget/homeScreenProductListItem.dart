import 'package:project/helper/utils/generalImports.dart';

enum ProductListProviderType {
  productList,
  recentlyVisited,
}

class HomeScreenProductListItem extends StatelessWidget {
  final ProductListItem product;
  final int position;
  final double? padding;
  final double? borderRadius;
  final ProductListProviderType? providerType;

  const HomeScreenProductListItem({
    Key? key,
    required this.product,
    required this.position,
    this.padding,
    this.borderRadius,
    this.providerType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Variants>? variants = product.variants;

    if (variants == null || variants.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine which consumer to use based on providerType
    if (providerType == ProductListProviderType.recentlyVisited) {
      return Consumer<RecentlyVisitedProvider>(
        builder: (context, recentlyVisitedProvider, _) {
          return _buildProductItem(context);
        },
      );
    } else {
      // Default to ProductListProvider
      return Consumer<ProductListProvider>(
        builder: (context, productListProvider, _) {
          return _buildProductItem(context);
        },
      );
    }
  }

  Widget _buildProductItem(BuildContext context) {
    List<Variants>? variants = product.variants;
    return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, productDetailScreen, arguments: [product.id.toString(), product.name, product]);
                },
                child: ChangeNotifierProvider<SelectedVariantItemProvider>(
                  create: (context) => SelectedVariantItemProvider(),
                  child: Container(
                    height: context.width * 0.85,
                    width: context.width * 0.45,
                    margin: EdgeInsets.symmetric(horizontal: padding ?? 5, vertical: padding ?? 5),
                    decoration: DesignConfig.boxDecoration(
                      Theme.of(context).cardColor,
                      borderRadius ?? 10,
                      isboarder: true,
                      bordercolor: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.3),
                      borderwidth: 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Consumer<SelectedVariantItemProvider>(
                                builder: (context, selectedVariantItemProvider, child) {
                                  return Stack(
                                    children: [
                                      Container(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            borderRadius ?? 7,
                                          ),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          child: setNetworkImg(
                                            boxFit: BoxFit.cover,
                                            image: product.imageUrl ?? "",
                                            height: context.width,
                                            width: context.width,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorsRes.appColorWhite,
                                          borderRadius: BorderRadiusDirectional.all(
                                            Radius.circular(
                                              borderRadius ?? 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        bottom: 5,
                                        end: 5,
                                        child: Column(
                                          children: [
                                            if (product.indicator.toString() == "1")
                                              defaultImg(
                                                height: 24,
                                                width: 24,
                                                image: AppAssets.productVegIndicatorIcon,
                                                boxFit: BoxFit.cover,
                                              ),
                                            if (product.indicator.toString() == "2")
                                              defaultImg(height: 24, width: 24, image: AppAssets.productNonVegIndicatorIcon, boxFit: BoxFit.cover),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height/5.3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (product.variants!.first.fewQuantityLeft!) ...[
                                  getSizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                                      child: CustomTextLabel(
                                        jsonKey: fewLeftLabel,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: ColorsRes.appColorRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(start: 5, bottom: 5, top: (product.variants!.first.fewQuantityLeft!)?0:5, end: 5),
                                    child: CustomTextLabel(
                                      text: product.name ?? "",
                                      softWrap: true,
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
                                    ),
                                  ),
                                  if(product.productRating!)
                                  ProductListRatingBuilderWidget(
                                    averageRating: product.averageRating.toString().toDouble,
                                    totalRatings: product.ratingCount.toString().toInt,
                                    size: 13,
                                    spacing: 3,
                                  ),
                                  // getSizedBox(height: 10),
                                  Spacer(),
                                  ProductVariantDropDownMenuGrid(
                                    variants: variants,
                                    from: "",
                                    product: product,
                                    isGrid: true,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        PositionedDirectional(
                          end: 5,
                          top: 5,
                          child: ProductWishListIcon(
                            product: product,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            double discountPercentage = 0.0;
                            if (product.variants!.first.discountedPrice.toString().toDouble > 0.0) {
                              discountPercentage = product.variants!.first.price
                                  .toString()
                                  .toDouble
                                  .calculateDiscountPercentage(product.variants!.first.discountedPrice.toString().toDouble);
                            }

                            if (discountPercentage > 0.0) {
                              return PositionedDirectional(
                                start: 5,
                                top: 5,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                    start: 7,
                                    end: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorsRes.appColorRed,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: CustomTextLabel(
                                    text: "${discountPercentage.toStringAsFixed(1)}% ${getTranslatedValue(context, offLabel)}",
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }
}
