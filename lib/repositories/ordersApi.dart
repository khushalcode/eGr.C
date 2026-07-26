import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> fetchOrders(
    {required Map<String, String> params,
    required BuildContext context}) async {
  try {
    final response = await sendApiRequest(
        apiName: ApiAndParams.apiOrdersHistory,
        params: params,
        isPost: false,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> updateOrderStatus(
    {required Map<String, String> params,
    required BuildContext context}) async {
  try {
    final response = await sendApiRequest(
        apiName: ApiAndParams.apiUpdateOrderStatus,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future deleteAwaitingOrderApi(
    {required Map<String, String> params,
    required BuildContext context}) async {
  try {
    final response = await sendApiRequest(
        apiName: ApiAndParams.apiDeleteOrder,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
