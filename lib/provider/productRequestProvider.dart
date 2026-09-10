import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/productRequest.dart';
import 'package:project/repositories/productRequestApi.dart';

enum ProductRequestState {
  initial,
  loading,
  loadingMore,
  loaded,
  empty,
  error,
}

class ProductRequestListProvider extends ChangeNotifier {
  ProductRequestState productRequestState = ProductRequestState.initial;
  String message = '';
  List<ProductRequest> productRequestList = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getProductRequestApiProvider({
    required Map<String, String> params,
    required BuildContext context,
  }) async {
    try {
      if (offset == 0) {
        productRequestState = ProductRequestState.loading;
        notifyListeners();
      } else {
        productRequestState = ProductRequestState.loadingMore;
        notifyListeners();
      }

      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> productRequestData =
          await getProductRequestList(context: context, params: params);

      if (productRequestData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(productRequestData[ApiAndParams.total].toString());
        List<ProductRequest> tempProductRequest = List.from(productRequestData[ApiAndParams.data])
            .map((e) => ProductRequest.fromJson(e))
            .toList();

        productRequestList.addAll(tempProductRequest);

        hasMoreData = totalData > productRequestList.length;
        if (hasMoreData) {
          offset += (Constant.defaultDataLoadLimitAtOnce + 20);
        }

        productRequestState = ProductRequestState.loaded;
        notifyListeners();
      } else {
        message = productRequestData[ApiAndParams.status];
        productRequestState = ProductRequestState.empty;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      productRequestState = ProductRequestState.error;
      notifyListeners();
      rethrow;
    }
  }

  void addNewProductRequestToList(ProductRequest productRequest) {
    productRequestList.insert(0, productRequest);
    totalData += 1;
    notifyListeners();
  }
}
