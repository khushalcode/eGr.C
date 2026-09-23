import 'package:project/helper/utils/generalImports.dart';

import 'package:project/screens/ordersHistoryScreen/activeOrdersListScreen.dart';
import 'package:project/screens/ordersHistoryScreen/previousOrdersListScreen.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  int currentIndex = 0;
  List<Widget> pages = [];
  int currentFilterIndex = 0; // 0: All, 1: Home Delivery, 2: Store Pickup
  late ActiveOrdersProvider activeOrdersProvider;
  late PreviousOrdersProvider previousOrdersProvider;

  @override
  void initState() {
    activeOrdersProvider = ActiveOrdersProvider();
    previousOrdersProvider = PreviousOrdersProvider();
    
    pages = [
      ChangeNotifierProvider<ActiveOrdersProvider>.value(
        value: activeOrdersProvider,
        child: const ActiveOrderListScreen(),
      ),
      ChangeNotifierProvider<PreviousOrdersProvider>.value(
        value: previousOrdersProvider,
        child: const PreviousOrderListScreen(),
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: ordersHistoryLabel,
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
          showBackButton: true,
          actions: [
            GestureDetector(
              onTap: () => _openFilterSheet(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.filter_list,
                  color: ColorsRes.mainTextColor,
                ),
              ),
            ),
          ]),
      body: Column(
        children: [
          getSizedBox(height: 10),
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsetsDirectional.all(10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    child: OrderTypeButtonWidget(
                      isActive: currentIndex == 0,
                      child: Center(
                        child: CustomTextLabel(
                          jsonKey: activeOrdersLabel,
                          softWrap: true,
                          style: TextStyle(
                            color: currentIndex == 0
                                ? ColorsRes.appColorWhite
                                : ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 1;
                      });
                    },
                    child: OrderTypeButtonWidget(
                      isActive: currentIndex == 1,
                      child: Center(
                        child: CustomTextLabel(
                          jsonKey: previousOrdersLabel,
                          softWrap: true,
                          style: TextStyle(
                            color: currentIndex == 1
                                ? ColorsRes.appColorWhite
                                : ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    List<String> filterOptions = [
      allOrdersLabel,
      homeDeliveryLabel,
      storePickupLabel
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
      builder: (BuildContext context1) {
        return Wrap(
          children: [
            Container(
              decoration: DesignConfig.boxDecorationSpecific(
                Theme.of(context).cardColor,
                10, true, false,
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: CustomTextLabel(
                      jsonKey: filterLabel,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorsRes.mainTextColor,
                          ),
                    ),
                  ),
                  ...List.generate(
                    filterOptions.length,
                    (index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          setState(() {
                            currentFilterIndex = index;
                          });
                          _applyFilter();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                currentFilterIndex == index
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: ColorsRes.appColor,
                              ),
                              getSizedBox(width: 10),
                              Expanded(
                                child: CustomTextLabel(
                                  jsonKey: filterOptions[index],
                                  softWrap: true,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        fontSize: 16,
                                        color: ColorsRes.mainTextColor,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter() {
    // Clear existing orders
    activeOrdersProvider.orders.clear();
    activeOrdersProvider.offset = 0;
    previousOrdersProvider.orders.clear();
    previousOrdersProvider.offset = 0;

    // Get filter parameters
    Map<String, String> filterParams = _getFilterParams();

    // Refresh both providers with filter
    activeOrdersProvider.getOrders(
      params: {
        ApiAndParams.type: ApiAndParams.active,
        ...filterParams,
      },
      context: context,
    );

    previousOrdersProvider.getOrders(
      params: {
        ApiAndParams.type: ApiAndParams.previous,
        ...filterParams,
      },
      context: context,
    );
  }

  Map<String, String> _getFilterParams() {
    switch (currentFilterIndex) {
      case 1: // Home Delivery
        return {ApiAndParams.orderDeliveryType: "doorstep"};
      case 2: // Store Pickup
        return {ApiAndParams.orderDeliveryType: "selfpickup"};
      default: // All Orders
        return {};
    }
  }
}
