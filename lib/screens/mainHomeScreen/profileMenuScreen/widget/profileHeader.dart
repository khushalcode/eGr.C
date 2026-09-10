import 'package:project/helper/utils/generalImports.dart';


class ProfileHeader extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const ProfileHeader({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    String subscriptionType = Constant.session.hasActiveSubscription();
    return Container(
      decoration: DesignConfig.boxDecoration(ColorsRes.subScriptionCardColor, 12),
      margin: EdgeInsetsDirectional.only(top: 10, start: 10, end: 10, bottom: 10),
      child: Stack(
        children: [
          // Background decoration image on right side
          subscriptionType =="1"?PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: defaultImg(
              image: AppAssets.subscriptionMaxIcon,boxFit: BoxFit.fill
            ),
          ):const SizedBox.shrink(),
          // Main content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
                    children: [
            // Profile Info Section
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: DesignConfig.boxDecoration(ColorsRes.appColorWhite, 12),
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Constant.session.isUserLoggedIn()
                          ? Consumer<UserProfileProvider>(
                              builder: (context, value, child) {
                                return setNetworkImg(
                                  height: 80,
                                  width: 80,
                                  boxFit: BoxFit.cover,
                                  image: Constant.session.getData(
                                    SessionManager.keyUserImage,
                                  ),
                                );
                              },
                            )
                          : defaultImg(
                              height: 80,
                              width: 80,
                              image: AppAssets.defaultUserIcon,
                            ),
                    ),
                  ),
                ),
                getSizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer2<UserProfileProvider, LanguageProvider>(
                        builder: (context, userProfileProvide, languageProvider, child) {
                          return CustomTextLabel(
                            text: Constant.session.isUserLoggedIn()
                                ? userProfileProvide.getUserDetailBySessionKey(
                                    isBool: false,
                                    key: SessionManager.keyUserName,
                                  )
                                : getTranslatedValue(
                                    context,
                                    welcomeLabel,
                                  ),
                            style: TextStyle(
                              color: ColorsRes.appColorWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          );
                        }
                      ),
                      getSizedBox(height: 8),
                      if (Constant.session.isUserLoggedIn())
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              editProfileScreen,
                              arguments: [
                                Constant.session.isUserLoggedIn()
                                    ? "header"
                                    : "register_header",
                                null
                              ],
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextLabel(
                                jsonKey: editProfileLabel,
                                style: TextStyle(
                                  color: ColorsRes.appColorWhite,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              getSizedBox(width: 5),
                              Icon(
                                Icons.play_circle_filled_outlined,
                                size: 18,
                                color: ColorsRes.appColorWhite,
                              ),
                            ],
                          ),
                        ),
                      if (!Constant.session.isUserLoggedIn())
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              loginAccountScreen,
                              arguments: "register_header",
                            ).then((onValue) async {
                              // Refresh user data after login
                              if (onValue != null) {
                                await getUserDetail(context: context).then((value) {
                                  if (value[ApiAndParams.status].toString() == "1") {
                                    context.read<UserProfileProvider>().updateUserDataInSession(value, context);
                                  }
                                });

                                // Call the callback to refresh parent screen
                                if (onLoginSuccess != null) {
                                  onLoginSuccess!();
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsRes.appColorRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: CustomTextLabel(
                              jsonKey: loginLabel,
                              style: TextStyle(
                                color: ColorsRes.appColorWhite,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
            (Constant.session.isUserLoggedIn() && Constant.session.isSubscriptionPlansAvailable())?getSizedBox(height: 16): const SizedBox.shrink(),
            // Dotted Divider
            (Constant.session.isUserLoggedIn() && Constant.session.isSubscriptionPlansAvailable())?DashedDivider(color: ColorsRes.appColorWhite.withValues(alpha: .25), height: 1): const SizedBox.shrink(),
            (Constant.session.isUserLoggedIn() && Constant.session.isSubscriptionPlansAvailable())?getSizedBox(height: 16): const SizedBox.shrink(),
            // Subscribe eGrocerMAX Section
            (Constant.session.isUserLoggedIn() && Constant.session.isSubscriptionPlansAvailable())?Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    defaultImg(
                      image: AppAssets.subscriptionIcon,
                      height: 32,
                      width: 32,
                    ),
                    getSizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          CustomTextLabel(
                            jsonKey: (subscriptionType == "0") ? subscribeEGrocerMAXLabel: Constant.session.getSubscriptionName(),
                            style: TextStyle(
                              color: ColorsRes.appColorWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          (subscriptionType == "0") ? CustomTextLabel(
                            text: " ${Constant.session.getSubscriptionName()}",
                            style: TextStyle(
                              color: ColorsRes.appColorWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ):const SizedBox.shrink(),
                        ],
                      ),
                    ),
                      (subscriptionType == "1") ? Container(decoration: DesignConfig.boxDecoration(ColorsRes.appColorWhite, 80),padding: EdgeInsetsDirectional.only(start: 8, end: 8, top: 4, bottom: 4),
                        child: CustomTextLabel(
                                jsonKey: activeLabel,
                                style: TextStyle(
                                  color: ColorsRes.appColorBlack,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              )): (subscriptionType == "2") ? Container(decoration: DesignConfig.boxDecoration(ColorsRes.appColorRed, 80),padding: EdgeInsetsDirectional.only(start: 8, end: 8, top: 4, bottom: 4),
                        child: CustomTextLabel(
                                jsonKey: expiredLabel,
                                style: TextStyle(
                                  color: ColorsRes.appColorWhite,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              )): const SizedBox.shrink(),
                  ],
                ),
                getSizedBox(height: 4),
                (subscriptionType == "0" || subscriptionType == "2" ) ? Padding(
                  padding: EdgeInsetsDirectional.only(start: 44),
                  child: CustomTextLabel(
                    jsonKey: (subscriptionType == "0") ? subscribeEGrocerMAXDescLabel: membershipEndedMessage,
                    style: TextStyle(
                      color: ColorsRes.appColorWhite.withValues(alpha: .70),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ):Padding(
                  padding: EdgeInsetsDirectional.only(start: 44),
                  child: CustomTextLabel(
                    text: "${getTranslatedValue(context, expiresOnLabel)} ${Constant.session.getSubscriptionExpiryDate().formatDateForSubscription()}",
                    style: TextStyle(
                      color: ColorsRes.appColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                getSizedBox(height: 16),
                // Dotted Divider
                (subscriptionType == "2")?const SizedBox.shrink():DashedDivider(color: ColorsRes.appColorWhite.withValues(alpha: .25), height: 1),
                getSizedBox(height: 16),
                (subscriptionType == "0" || subscriptionType == "2" ) ? gradientBtnWidget(
                  context,
                  12,
                  callback: () {
                    Navigator.pushNamed(context, subscriptionScreen);
                  },
                  otherWidgets: Padding(
                    padding: const EdgeInsetsDirectional.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomTextLabel(
                            text: (subscriptionType == "0") ? getTranslatedValue(context, exploreMAXBenefitsLabel) : getTranslatedValue(context, renewEGrocerMaxLabel)
                                                      .replaceAll("{subscriptionName}", Constant.session.getSubscriptionName()),
                            style: TextStyle(
                              color: ColorsRes.appColorWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),textAlign: TextAlign.center
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: ColorsRes.appColorWhite,
                        ),
                      ],
                    ),
                  ),
                ): GestureDetector(
                  onTap:(){
                    Navigator.pushNamed(context, subscriptionScreen);
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                              Expanded(
                                child: CustomTextLabel(
                                    jsonKey: viewDetailsLabel,
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),),
                              ),
                              Icon(
                                Icons.play_circle_filled_outlined,
                                size: 18,
                                color: ColorsRes.appColorWhite,
                              ),
                            ]),
                ),
              ],
            ): const SizedBox.shrink(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
