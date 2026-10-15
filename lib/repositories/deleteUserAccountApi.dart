import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getDeleteAccountApi(
    {required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiDeleteAccount,
        params: {},
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
