import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/productRequest.dart';
import 'package:project/repositories/productRequestApi.dart';

enum AddProductRequestState {
  initial,
  loading,
  loaded,
  error,
}

class AddProductRequestProvider extends ChangeNotifier {
  AddProductRequestState addProductRequestState = AddProductRequestState.initial;
  String message = '';
  ProductRequest? newlyAddedProductRequest;

  Future<bool> addProductRequest({
    required BuildContext context,
    required Map<String, dynamic> params,
  }) async {
    try {
      addProductRequestState = AddProductRequestState.loading;
      notifyListeners();

      // Separate text parameters from file parameters
      Map<String, String> textParams = {};
      List<String> fileNames = [];
      List<String> filePaths = [];

      params.forEach((key, value) {
        if (key == ApiAndParams.image && value != null && value.toString().isNotEmpty) {
          fileNames.add('image');
          filePaths.add(value.toString());
        } else if (value != null) {
          textParams[key] = value.toString();
        }
      });

      Map<String, dynamic> response = await addProductRequestApi(
        context: context,
        params: textParams,
        fileParamsNames: fileNames,
        fileParamsFilesPath: filePaths,
      );

      if (response[ApiAndParams.status].toString() == "1") {
        message = response[ApiAndParams.message] ?? getTranslatedValue(context, productRequestAddedSuccessfullyLabel);

        // Store the newly added product request data
        if (response[ApiAndParams.data] != null) {
          newlyAddedProductRequest = ProductRequest.fromJson(response[ApiAndParams.data]);
        }

        addProductRequestState = AddProductRequestState.loaded;
        notifyListeners();
        return true;
      } else {
        message = response[ApiAndParams.message] ?? getTranslatedValue(context, failedToAddProductRequestLabel);
        addProductRequestState = AddProductRequestState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      message = e.toString();
      addProductRequestState = AddProductRequestState.error;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    addProductRequestState = AddProductRequestState.initial;
    message = '';
    notifyListeners();
  }
}
