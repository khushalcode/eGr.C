import 'package:project/helper/utils/generalImports.dart';

Future registerFcmKey(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    await sendApiRequest(
      apiName: ApiAndParams.apiAddFcmToken,
      params: params,
      isPost: true,
      context: context,
    );
  } catch (e) {
    rethrow;
  }
}

Future logoutApi(
    {required BuildContext context, required String fcmToken}) async {
  try {
    await sendApiRequest(
      apiName: ApiAndParams.apiLogout,
      params: {ApiAndParams.fcmToken: fcmToken},
      isPost: true,
      context: context,
    );
  } catch (e) {
    rethrow;
  }
}
