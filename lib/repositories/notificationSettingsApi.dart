import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getAppNotificationSettingsRepository(
    {required Map<String, dynamic> params,
    required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiNotificationSettings,
        params: params,
        isPost: false,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> updateAppNotificationSettingsRepository(
    {required Map<String, dynamic> params,
    required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiNotificationSettingsUpdate,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
