import 'package:project/helper/utils/generalImports.dart';

Future getProductRequestList(
    {required BuildContext context,
    required Map<String, String> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiUserProductRequestsList,
        params: params,
        isPost: false,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> addProductRequestApi(
    {required BuildContext context,
    required Map<String, String> params,
    required List<String> fileParamsNames,
    required List<String> fileParamsFilesPath}) async {
  try {
    var response = await sendApiMultiPartRequest(
        apiName: ApiAndParams.apiUserProductRequestAdd,
        params: params,
        fileParamsNames: fileParamsNames,
        fileParamsFilesPath: fileParamsFilesPath,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
