import 'package:project/helper/utils/generalImports.dart';

Future getSubscriptionPlansApi({required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiSubscriptionPlans,
      params: {},
      isPost: false,
      context: context,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getSubscriptionFaqsApi({
  required BuildContext context,
  required Map<String, dynamic> params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiSubscriptionFaqs,
      params: params,
      isPost: false,
      context: context,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> initialTransactionForSubscription({required BuildContext context, required Map<String, dynamic> params}) async {
  try {
    params[ApiAndParams.type] = ApiAndParams.subscriptionType;

    var response = await sendApiRequest(apiName: ApiAndParams.apiInitiateTransaction, params: params, isPost: false, context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getUserActivePlanApi({required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiUserActivePlan,
      params: {},
      isPost: false,
      context: context,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> addInAppPurchaseApi({
  required BuildContext context,
  required Map<String, dynamic> params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiAddTransaction,
      params: params,
      isPost: true,
      context: context,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
