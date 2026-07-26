import 'package:project/helper/utils/generalImports.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  const SubscriptionSuccessScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionSuccessScreen> createState() => _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto close after 3 seconds, refresh data, and return to subscription screen
    Future.delayed(Duration(seconds: 3), () async {
      if (mounted) {
        // Refresh user details to get updated subscription status
        await getUserDetail(context: context).then((value) {
          if (value[ApiAndParams.status].toString() == "1") {
            context.read<UserProfileProvider>().updateUserDataInSession(value, context).then((onValue){
              context.read<ActiveSubscriptionProvider>().getActiveSubscriptionProvider(context: context);
            });
          }
        });

        // Pop back to subscription screen with refresh flag
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.064),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              defaultImg(
                image: AppAssets.subscriptionSuccessIcon,
                height: screenHeight * 0.21,
                width: screenWidth * 0.48,
              ),
              getSizedBox(height: screenHeight * 0.04),
              // Success Title
              CustomTextLabel(
                text: getTranslatedValue(context, membershipSuccessTitleLabel).replaceAll("{subscriptionName}", Constant.session.getSubscriptionName()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontSize: screenWidth * 0.064,
                  fontWeight: FontWeight.w700,
                ),
              ),
              getSizedBox(height: screenHeight * 0.01),
              // Success Message
              CustomTextLabel(
                jsonKey: membershipSuccessSubtitleLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorsRes.subTitleMainTextColor,
                  fontSize: screenWidth * 0.043,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
