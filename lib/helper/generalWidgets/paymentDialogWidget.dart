import 'package:project/helper/utils/generalImports.dart';
class PaymentCancelDialog extends StatelessWidget {
  const PaymentCancelDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Icon
          Icon(
            Icons.cancel_outlined,
            color: ColorsRes.appColor,
            size: screenWidth * 0.15,
          ),
          getSizedBox(height: screenHeight * 0.02),
          // Title
          CustomTextLabel(
            jsonKey: purchaseCanceledLabel,
            style: TextStyle(
              color: ColorsRes.mainTextColor,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          getSizedBox(height: screenHeight * 0.015),
          // Message
          CustomTextLabel(
            jsonKey: purchaseHasBeenCanceledLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorsRes.subTitleMainTextColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
            ),
          ),
          getSizedBox(height: screenHeight * 0.025),
          // OK Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              decoration: BoxDecoration(
                color: ColorsRes.appColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: CustomTextLabel(
                  jsonKey: okLabel,
                  style: TextStyle(
                    color: ColorsRes.appColorWhite,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentErrorDialog extends StatelessWidget {
  final String? errorMessage;

  const PaymentErrorDialog({
    Key? key,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Icon
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: screenWidth * 0.15,
          ),
          getSizedBox(height: screenHeight * 0.02),
          // Title
          CustomTextLabel(
            jsonKey: purchaseErrorLabel,
            style: TextStyle(
              color: ColorsRes.mainTextColor,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          getSizedBox(height: screenHeight * 0.015),
          // Error Message
          Text(
            errorMessage ?? "An error occurred during purchase",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorsRes.subTitleMainTextColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
            ),
          ),
          getSizedBox(height: screenHeight * 0.025),
          // OK Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              decoration: BoxDecoration(
                color: ColorsRes.appColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: CustomTextLabel(
                  jsonKey: okLabel,
                  style: TextStyle(
                    color: ColorsRes.appColorWhite,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
