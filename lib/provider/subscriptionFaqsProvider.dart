import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/subscriptionFaqs.dart';
import 'package:project/repositories/subscriptionApi.dart';

enum SubscriptionFaqsState {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

class SubscriptionFaqsProvider extends ChangeNotifier {
  SubscriptionFaqsState subscriptionFaqsState = SubscriptionFaqsState.initial;
  String message = '';
  List<SubscriptionFaqs> subscriptionFaqs = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getSubscriptionFaqsProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    if (offset == 0) {
      subscriptionFaqsState = SubscriptionFaqsState.loading;
    } else {
      subscriptionFaqsState = SubscriptionFaqsState.loadingMore;
    }
    notifyListeners();

    try {
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await getSubscriptionFaqsApi(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(getData[ApiAndParams.total].toString());
        List<SubscriptionFaqs> tempFaqs = (getData['data'] as List)
            .map((e) => SubscriptionFaqs.fromJson(Map.from(e)))
            .toList();

        subscriptionFaqs.addAll(tempFaqs);

        hasMoreData = totalData > subscriptionFaqs.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        subscriptionFaqsState = SubscriptionFaqsState.loaded;
        notifyListeners();
      } else {
        subscriptionFaqsState = SubscriptionFaqsState.error;
        message = getData[ApiAndParams.message] ?? '';
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      subscriptionFaqsState = SubscriptionFaqsState.error;
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
    }
  }

  changeCurrentState(SubscriptionFaqsState state) {
    subscriptionFaqsState = state;
  }

  reset() {
    subscriptionFaqs.clear();
    subscriptionFaqsState = SubscriptionFaqsState.initial;
    offset = 0;
    hasMoreData = false;
    totalData = 0;
    notifyListeners();
  }
}
