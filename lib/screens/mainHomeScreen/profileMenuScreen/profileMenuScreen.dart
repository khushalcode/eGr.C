import 'package:project/helper/generalWidgets/bottomSheetChangePasswordContainer.dart';
import 'package:project/helper/utils/generalImports.dart';


class ProfileScreen extends StatefulWidget {
  final ScrollController scrollController;

  const ProfileScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List personalDataMenu = [];
  List settingsMenu = [];
  List helpAndSupportMenu = [];
  List aboutAndCommunityMenu = [];
  List accountControlMenu = [];
  List deleteMenuItem = [];
  bool _isSharing = false; // Add this in your state

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) => setProfileMenuList());
    super.initState();
  }

  Future<void> _onRefresh() async {
    try {
      // Call user details API to refresh user profile data
      await getUserDetail(context: context).then((value) {
        if (value[ApiAndParams.status].toString() == "1") {
          context.read<UserProfileProvider>().updateUserDataInSession(value, context);

          // Show success message
          /* showMessage(
            context,
            getTranslatedValue(context, "Profile updated successfully"),
            MessageType.success,
          ); */
        }
      });
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  void shareApp(BuildContext context) async {
    if (_isSharing) return; // Prevent multiple clicks
    _isSharing = true;

    try {
      String shareAppMessage = getTranslatedValue(context, shareAppMessageLabel);

      if (Platform.isAndroid) {
        shareAppMessage = "$shareAppMessage${Constant.playStoreUrl}";
      } else if (Platform.isIOS) {
        shareAppMessage = "$shareAppMessage${Constant.appStoreUrl}";
      }

      await SharePlus.instance.share(
        ShareParams(text: shareAppMessage, subject: "Share app"),
      );
    } catch (e) {
      debugPrint("Error sharing app: $e");
    } finally {
      _isSharing = false; // Re-enable sharing after the dialog is closed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: getAppBar(
        context: context,
        centerTitle: true,
        title: CustomTextLabel(
          jsonKey: myProfileLabel,
          softWrap: true,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
        showBackButton: false,
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, _) {
          setProfileMenuList();
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: ColorsRes.appColor,
            child: ListView(
              controller: widget.scrollController,
              children: [
                Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      ProfileHeader(
                        onLoginSuccess: () {
                          // Trigger a rebuild by calling setState
                          setState(() {});
                        },
                      ),
                      QuickUseWidget(),
                    ],
                  ),
                ),
                menuItemsContainer(
                  title: personalDataLabel,
                  menuItem: personalDataMenu,
                ),
                menuItemsContainer(
                  title: appSettingsLabel,
                  menuItem: settingsMenu,
                ),
                menuItemsContainer(
                  title: helpAndSupportLabel,
                  menuItem: helpAndSupportMenu,
                ),
                menuItemsContainer(
                  title: aboutAndCommunityLabel,
                  menuItem: aboutAndCommunityMenu,
                ),
                menuItemsContainer(
                  title: accountControlLabel,
                  menuItem: accountControlMenu,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  setProfileMenuList() {
    personalDataMenu = [];
    settingsMenu = [];
    helpAndSupportMenu = [];
    aboutAndCommunityMenu = [];
    accountControlMenu = [];
    deleteMenuItem = [];

    personalDataMenu = [
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.walletHistoryIcon,
          "label": myWalletLabel,
          "value": Consumer<SessionManager>(
            builder: (context, sessionManager, child) {
              return sessionManager.getData(SessionManager.keyWalletBalance)=="0"?SizedBox.shrink():Container(
                padding: EdgeInsetsDirectional.only(top: 4, start: 8, bottom:4, end: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(80),
                ),
                child: CustomTextLabel(
                  text:
                      "${sessionManager.getData(SessionManager.keyWalletBalance)}"
                          .currency,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorsRes.appColorWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          "clickFunction": (context) {
            Navigator.pushNamed(context, walletHistoryListScreen);
          },
          "isResetLabel": false
        },
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.transactionIcon,
          "label": transactionHistoryLabel,
          "clickFunction": (context) {
            Navigator.pushNamed(context, transactionListScreen);
          },
          "isResetLabel": false
        },
    ];

    settingsMenu = [
      if (Constant.session.isUserLoggedIn() && (/* Constant.session.getData(SessionManager.keyLoginType) == "phone" */context.read<AppSettingsProvider>().settingsData!.phoneAuthPassword=="1" || Constant.session.getData(SessionManager.keyLoginType) == "email"))
        {
          "icon": AppAssets.passwordIcon,
          "label": changePasswordLabel,
          "clickFunction": (context) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
              backgroundColor: Theme.of(context).cardColor,
              builder: (BuildContext context) {
                return Wrap(
                  children: [
                    BottomSheetChangePasswordContainer(),
                  ],
                );
              },
            );
          },
          "isResetLabel": false
        },
      {
        "icon": AppAssets.themeIcon,
        "label": changeThemeLabel,
        "clickFunction": (context) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,useSafeArea: true,
            shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
            backgroundColor: Theme.of(context).cardColor,
            builder: (BuildContext context) {
              return Wrap(
                children: [
                  BottomSheetThemeListContainer(),
                ],
              );
            },
          );
        },
        "isResetLabel": true,
      },
      if (context.read<LanguageProvider>().languages.length > 1)
        {
          "icon": AppAssets.translateIcon,
          "label": changeLanguageLabel,
          "clickFunction": (context) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
              backgroundColor: Theme.of(context).cardColor,
              builder: (BuildContext context) {
                return Wrap(
                  children: [
                    BottomSheetLanguageListContainer(),
                  ],
                );
              },
            );
          },
          "isResetLabel": true,
        },
    ];

    // Help & Support Section
    helpAndSupportMenu = [
      {
        "icon": AppAssets.contactIcon,
        "label": contactUsLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(
            context,
            webViewScreen,
            arguments: getTranslatedValue(
              context,
              contactUsLabel,
            ),
          );
        }
      },
      {
        "icon": AppAssets.faqIcon,
        "label": faqLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, faqListScreen);
        }
      },
      {
        "icon": AppAssets.productRequestIcon,
        "label": productRequestLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, productRequestsScreen,
              arguments: getTranslatedValue(
                context,
                productRequestLabel,
              ));
        }
      },
      {
        "icon": AppAssets.privacyIcon,
        "label": policiesLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, webViewScreen,
              arguments: getTranslatedValue(
                context,
                policiesLabel,
              ));
        }
      },
      {
        "icon": AppAssets.termsIcon,
        "label": termsAndConditionsLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, webViewScreen,
              arguments: getTranslatedValue(
                context,
                termsAndConditionsLabel,
              ));
        }
      },
    ];

    // About & Community Section
    aboutAndCommunityMenu = [
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.referFriendIcon,
          "label": referAndEarnLabel,
          "clickFunction": (context) {
            Navigator.pushNamed(context, referAndEarn);
          },
          "isResetLabel": false
        },
      {
        "icon": AppAssets.notificationIcon,
        "label": notificationLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, notificationListScreen);
        },
        "isResetLabel": false
      },
      {
        "icon": AppAssets.aboutIcon,
        "label": aboutUsLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(
            context,
            webViewScreen,
            arguments: getTranslatedValue(
              context,
              aboutUsLabel,
            ),
          );
        },
        "isResetLabel": false
      },
      {
        "icon": AppAssets.blogIcon,
        "label": blogsLabel,
        "clickFunction": (context) {
          Navigator.pushNamed(context, blogListScreen,
              arguments: getTranslatedValue(
                context,
                blogsLabel,
              ));
        }
      },
      {
        "icon": AppAssets.rateUsIcon,
        "label": rateUsLabel,
        "clickFunction": (BuildContext context) {
          launchUrl(
              Uri.parse(Platform.isAndroid
                  ? Constant.playStoreUrl
                  : Constant.appStoreUrl),
              mode: LaunchMode.externalApplication);
        },
      },
      {
        "icon": AppAssets.shareIcon,
        "label": shareAppLabel,
        "clickFunction": (BuildContext context) {
          shareApp(context);
        },
      },
    ];

    accountControlMenu = [
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.logoutIcon,
          "label": logoutLabel,
          "clickFunction": Constant.session.logoutUser,
          "isResetLabel": false
        },
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.settingsIcon,
          "label": settingsLabel,
          "clickFunction": (context) {
            Navigator.pushNamed(context, accountControlScreen);
          },
          "isResetLabel": false
        },
    ];

    deleteMenuItem = [];
  }

  Widget menuItemsContainer({
    required String title,
    required List menuItem,
    Color? iconColor,
    Color? fontColor,
  }) {
    if (menuItem.isNotEmpty) {
      return Container(
        // decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8, isboarder: true, bordercolor: ColorsRes.cardBoarderColor),
        // padding: EdgeInsetsDirectional.only(start: 10, end: 10),
        margin: EdgeInsetsDirectional.only(
          start: 10,
          end: 10,
          bottom: 10,
          top: Constant.session.isUserLoggedIn() ? 0 : 10,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            if (title.isNotEmpty) getSizedBox(height: 10),
            if (title.isNotEmpty)
              CustomTextLabel(
                jsonKey: title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorsRes.mainTextColor,
                ),
              ),
            if (title.isNotEmpty) getSizedBox(height: 10),
            Container(
              decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8, isboarder: true, bordercolor: ColorsRes.cardBoarderColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  menuItem.length,
                  (index) => Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          menuItem[index]['clickFunction'](context);
                        },
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: 10, bottom: 10, start: 10, end: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsetsDirectional.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: defaultImg(
                                  image: menuItem[index]['icon'],
                                  iconColor: iconColor ?? ColorsRes.mainTextColor,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              getSizedBox(width: 15),
                              Expanded(
                                child: CustomTextLabel(
                                  jsonKey: menuItem[index]['label'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: fontColor ?? ColorsRes.mainTextColor,
                                  ),
                                ),
                              ),
                              if (menuItem[index]['value'] != null)
                                menuItem[index]['value'],
                              if (menuItem[index]['value'] != null)
                                getSizedBox(width: 10),
                              Icon(
                                Icons.navigate_next,
                                color: fontColor ??
                                    ColorsRes.mainTextColor.withValues(alpha:0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      if (index != menuItem.length - 1)
                        getDivider(
                          height: 5,
                          color: fontColor ??
                              ColorsRes.mainTextColor.withValues(alpha:0.1),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
