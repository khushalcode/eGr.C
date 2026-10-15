import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/subscriptionDetail.dart';

enum ActiveSubscriptionState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class ActiveSubscriptionProvider extends ChangeNotifier {
  ActiveSubscriptionState activeSubscriptionState = ActiveSubscriptionState.initial;
  String message = '';
  subscriptionDetail? activeSubscriptionData;

  getActiveSubscriptionProvider({
    required BuildContext context,
  }) async {
    activeSubscriptionState = ActiveSubscriptionState.loading;
    notifyListeners();

    try {
      Map<String, dynamic> getData =
          (await getUserActivePlanApi(context: context));

      if (getData[ApiAndParams.status].toString() == "1") {
        activeSubscriptionData = subscriptionDetail.fromJson(getData['data']);

        if (activeSubscriptionData == null) {
          activeSubscriptionState = ActiveSubscriptionState.empty;
        } else {
          activeSubscriptionState = ActiveSubscriptionState.loaded;
        }

        notifyListeners();
      } else {
        activeSubscriptionState = ActiveSubscriptionState.error;
        message = getData[ApiAndParams.message] ?? '';
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      activeSubscriptionState = ActiveSubscriptionState.error;
      notifyListeners();
    }
  }

  changeCurrentState(ActiveSubscriptionState state) {
    activeSubscriptionState = state;
  }

  reset() {
    activeSubscriptionData = null;
    activeSubscriptionState = ActiveSubscriptionState.initial;
    notifyListeners();
  }
}
