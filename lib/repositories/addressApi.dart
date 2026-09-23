import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getAddressApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAddress,
        params: params,
        isPost: false,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> addAddressApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAddressAdd,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> updateAddressApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAddressUpdate,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> deleteAddressApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAddressRemove,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
