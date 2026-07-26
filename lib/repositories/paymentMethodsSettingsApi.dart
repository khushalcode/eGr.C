import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getPaymentMethodsSettingsApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiPaymentMethodsSettings,
        params: params,
        isPost: false,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
