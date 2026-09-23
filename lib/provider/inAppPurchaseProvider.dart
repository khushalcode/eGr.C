import 'package:project/helper/utils/generalImports.dart';

enum InAppPurchaseState {
  initial,
  loading,
  success,
  failure,
}

class InAppPurchaseProvider extends ChangeNotifier {
  InAppPurchaseState inAppPurchaseState = InAppPurchaseState.initial;
  String message = '';
  String responseMessage = '';
  String error = '';
  String status = "0";

  Future inAppPurchase({
    required int packageId,
    required String method,
    required String purchaseToken,
  }) async {
    inAppPurchaseState = InAppPurchaseState.loading;
    notifyListeners();

    try {
      PackageInfo packageInfo;
      packageInfo = await PackageInfo.fromPlatform();

      Map<String, String> params = {};
      params[ApiAndParams.deviceType] = "IOS";
      params[ApiAndParams.appVersion] = packageInfo.version;
      params[ApiAndParams.paymentMethod] = method;
      params[ApiAndParams.transactionId] = purchaseToken;
      params[ApiAndParams.type] = ApiAndParams.subscriptionType;
      params[ApiAndParams.subscriptionPlanId] = packageId.toString();

      Map<String, dynamic> response = await addInAppPurchaseApi(
        context: navigatorKey.currentContext!,
        params: params,
      );

      if (response[ApiAndParams.status].toString() == "1") {
        responseMessage = response[ApiAndParams.message] ??
            "Purchase completed successfully";
        inAppPurchaseState = InAppPurchaseState.success;

        // Update user details to get latest subscription info
        await getUserDetail(context: navigatorKey.currentContext!).then((value) {
          if (value[ApiAndParams.status].toString() == "1") {
            navigatorKey.currentContext!
                .read<UserProfileProvider>()
                .updateUserDataInSession(value, navigatorKey.currentContext!);
          }
        });
        status = response[ApiAndParams.status].toString();
        notifyListeners();
        return response;
      } else {
        error = response[ApiAndParams.message] ?? "Purchase failed";
        status = response[ApiAndParams.status].toString();
        inAppPurchaseState = InAppPurchaseState.failure;
        notifyListeners();
        return {"status": "0", "message": response[ApiAndParams.message].toString()};
      }
    } catch (e) {
      error = e.toString();
      status = "0";
      inAppPurchaseState = InAppPurchaseState.failure;
      notifyListeners();
      return {"status":"0","message": e.toString()};
    }
  }

  void reset() {
    inAppPurchaseState = InAppPurchaseState.initial;
    message = '';
    responseMessage = '';
    error = '';
    notifyListeners();
  }
}
