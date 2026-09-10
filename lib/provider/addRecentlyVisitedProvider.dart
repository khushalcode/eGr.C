import 'package:project/helper/utils/generalImports.dart';

enum AddRecentlyVisitedState {
  initial,
  loading,
  loaded,
  error,
}

class AddRecentlyVisitedProvider extends ChangeNotifier {
  AddRecentlyVisitedState addRecentlyVisitedState =
      AddRecentlyVisitedState.initial;
  String message = '';

  Future<bool> addRecentlyVisitedProduct({
    required BuildContext context,
    required Map<String, dynamic> params,
  }) async {
    try {
      bool returnState = false;
      addRecentlyVisitedState = AddRecentlyVisitedState.loading;
      notifyListeners();

      Map<String, dynamic> map = await addRecentlyVisitedProductApi(
          context: context, params: params);

      if (map[ApiAndParams.status].toString() == "1") {
        addRecentlyVisitedState = AddRecentlyVisitedState.loaded;
        notifyListeners();
        returnState = true;
      } else {
        message = Constant.somethingWentWrong;
        addRecentlyVisitedState = AddRecentlyVisitedState.error;
        notifyListeners();
        returnState = false;
      }
      return returnState;
    } catch (e) {
      message = e.toString();
      addRecentlyVisitedState = AddRecentlyVisitedState.error;
      notifyListeners();
      rethrow;
    }
  }

  resetState() {
    addRecentlyVisitedState = AddRecentlyVisitedState.initial;
    message = '';
    notifyListeners();
  }
}
