import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/subscriptionPlans.dart';
import 'package:project/repositories/subscriptionApi.dart';

enum SubscriptionPlansState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class SubscriptionPlansProvider extends ChangeNotifier {
  SubscriptionPlansState subscriptionPlansState = SubscriptionPlansState.initial;
  String message = '';
  subscriptionPlans? subscriptionPlansData;

  getSubscriptionPlansProvider({
    required BuildContext context,
  }) async {
    subscriptionPlansState = SubscriptionPlansState.loading;
    notifyListeners();

    try {
      Map<String, dynamic> getData =
          (await getSubscriptionPlansApi(context: context));

      if (getData[ApiAndParams.status].toString() == "1") {
        subscriptionPlansData = subscriptionPlans.fromJson(getData['data']);

        if (subscriptionPlansData?.plans == null || subscriptionPlansData!.plans!.isEmpty) {
          subscriptionPlansState = SubscriptionPlansState.empty;
        } else {
          subscriptionPlansState = SubscriptionPlansState.loaded;
        }

        notifyListeners();
      } else {
        subscriptionPlansState = SubscriptionPlansState.error;
        message = getData[ApiAndParams.message] ?? '';
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      subscriptionPlansState = SubscriptionPlansState.error;
      notifyListeners();
    }
  }

  changeCurrentState(SubscriptionPlansState state) {
    subscriptionPlansState = state;
  }

  reset() {
    subscriptionPlansData = null;
    subscriptionPlansState = SubscriptionPlansState.initial;
    notifyListeners();
  }
}
