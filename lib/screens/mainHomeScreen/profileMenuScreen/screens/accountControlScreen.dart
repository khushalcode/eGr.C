import 'package:project/helper/utils/generalImports.dart';

class AccountControlScreen extends StatefulWidget {
  const AccountControlScreen({Key? key}) : super(key: key);

  @override
  State<AccountControlScreen> createState() => _AccountControlScreenState();
}

class _AccountControlScreenState extends State<AccountControlScreen> {
  List accountControlMenu = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) => setAccountControlMenuList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        centerTitle: true,
        title: CustomTextLabel(
          jsonKey: accountControlLabel,
          softWrap: true,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.all(10),
        children: [
          menuItemsContainer(
            title: "",
            menuItem: accountControlMenu,
          ),
        ],
      ),
    );
  }

  setAccountControlMenuList() {
    accountControlMenu = [];

    accountControlMenu = [
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.settingsIcon,
          "label": notificationsSettingsLabel,
          "clickFunction": (context) {
            Navigator.pushNamed(
                context, notificationsAndMailSettingsScreenScreen);
          },
          "isResetLabel": false
        },
      if (Constant.session.isUserLoggedIn())
        {
          "icon": AppAssets.deleteUserAccountIcon,
          "label": deleteUserAccountLabel,
          "clickFunction": Constant.session.deleteUserAccount,
          "isResetLabel": false,
        },
    ];

    if (mounted) {
      setState(() {});
    }
  }

  Widget menuItemsContainer({
    required String title,
    required List menuItem,
  }) {
    if (menuItem.isNotEmpty) {
      return Container(
        margin: EdgeInsetsDirectional.only(
          bottom: 10,
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
              decoration: DesignConfig.boxDecoration(
                  Theme.of(context).cardColor, 8,
                  isboarder: true, bordercolor: ColorsRes.cardBoarderColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  menuItem.length,
                  (index) {
                    Color? fontColor = menuItem[index]['fontColor'];
                    Color? iconColor = menuItem[index]['iconColor'];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            menuItem[index]['clickFunction'](context);
                          },
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                                top: 10, bottom: 10, start: 10, end: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsetsDirectional.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: defaultImg(
                                    image: menuItem[index]['icon'],
                                    iconColor:
                                        iconColor ?? ColorsRes.mainTextColor,
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
                                      color:
                                          fontColor ?? ColorsRes.mainTextColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.navigate_next,
                                  color: fontColor ??
                                      ColorsRes.mainTextColor
                                          .withValues(alpha: 0.5),
                                )
                              ],
                            ),
                          ),
                        ),
                        if (index != menuItem.length - 1)
                          getDivider(
                            height: 5,
                            color: fontColor ??
                                ColorsRes.mainTextColor.withValues(alpha: 0.1),
                          ),
                      ],
                    );
                  },
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
