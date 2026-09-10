import 'package:project/helper/utils/generalImports.dart';

enum RecentlyVisitedState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class RecentlyVisitedProvider extends ChangeNotifier {
  RecentlyVisitedState recentlyVisitedState = RecentlyVisitedState.initial;
  String message = '';
  List<ProductListItem> recentlyVisitedProducts = [];

  getRecentlyVisitedProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    recentlyVisitedState = RecentlyVisitedState.loading;
    notifyListeners();

    try {
      Map<String, dynamic> getData =
          (await getRecentlyVisitedProductsApi(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        List<ProductListItem> tempRecentlyVisitedProducts = (getData['data'] as List)
            .map((e) => ProductListItem.fromJson(Map.from(e)))
            .toList();

        recentlyVisitedProducts = tempRecentlyVisitedProducts;

        if (recentlyVisitedProducts.isEmpty) {
          recentlyVisitedState = RecentlyVisitedState.empty;
        } else {
          recentlyVisitedState = RecentlyVisitedState.loaded;
        }

        notifyListeners();
      } else {
        recentlyVisitedState = RecentlyVisitedState.error;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      recentlyVisitedState = RecentlyVisitedState.error;
      notifyListeners();
    }
  }

  changeCurrentState(RecentlyVisitedState state) {
    recentlyVisitedState = state;
  }

  reset() {
    recentlyVisitedProducts.clear();
    recentlyVisitedState = RecentlyVisitedState.initial;
    notifyListeners();
  }
}
