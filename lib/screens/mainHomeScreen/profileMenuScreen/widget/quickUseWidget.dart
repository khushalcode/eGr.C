import 'package:project/helper/utils/generalImports.dart';

class QuickUseWidget extends StatelessWidget {
  const QuickUseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Constant.session.isUserLoggedIn()
        ? Padding(
            padding: const EdgeInsetsDirectional.all(10),
            child: Row(
              children: [
                Expanded(
                  child: QuickActionButtonWidget(
                    icon: Container(
                      padding: EdgeInsetsDirectional.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: defaultImg(
                        image: AppAssets.ordersIcon,
                        iconColor: ColorsRes.mainTextColor,
                        height: 23,
                        width: 23,
                      ),
                    ),
                    label: allOrdersLabel,
                    onClickAction: () {
                      Navigator.pushNamed(
                        context,
                        orderHistoryScreen,
                      );
                    },
                    padding: const EdgeInsetsDirectional.only(
                      end: 5,
                    ),
                    context: context,
                  ),
                ),
                Expanded(
                  child: QuickActionButtonWidget(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsetsDirectional.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: defaultImg(
                            image: AppAssets.cartIcon,
                            iconColor: ColorsRes.mainTextColor,
                            height: 23,
                            width: 23,
                          ),
                        ),
                        // Cart Count Badge
                        if (context.watch<CartProvider>().totalItemsCount > 0)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Constant.session.getBoolData(SessionManager.isDarkTheme)? ColorsRes.appColorWhite :ColorsRes.appColorBlack,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                "${context.watch<CartProvider>().totalItemsCount > 99 ? "99+": context.watch<CartProvider>().totalItemsCount}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Constant.session.getBoolData(SessionManager.isDarkTheme)? ColorsRes.appColorBlack :ColorsRes.appColorWhite,
                                  fontSize: context.watch<CartProvider>().totalItemsCount > 99 ? 8 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: cartLabel,
                    onClickAction: () {
                      if (Constant.session.isUserLoggedIn()) {
                        Navigator.pushNamed(context, cartScreen);
                      } else {
                        // loginUserAccount(context, "cart");
                        Navigator.pushNamed(context, cartScreen);
                      }
                    },
                    padding: const EdgeInsetsDirectional.only(
                      start: 5,
                    ),
                    context: context,
                  ),
                ),
                Expanded(
                  child: QuickActionButtonWidget(
                    icon: Container(
                              padding: EdgeInsetsDirectional.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: defaultImg(
                        image: AppAssets.addressIcon,
                        iconColor: ColorsRes.mainTextColor,
                        height: 23,
                        width: 23,
                      ),
                    ),
                    label: addressLabel,
                    onClickAction: () => Navigator.pushNamed(
                      context,
                      addressListScreen,
                      arguments: "quick_widget",
                    ),
                    padding: const EdgeInsetsDirectional.only(
                      start: 5,
                      end: 5,
                    ),
                    context: context,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
