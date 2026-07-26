import 'package:project/helper/utils/generalImports.dart';

class QuickActionButtonWidget extends StatelessWidget {
  final Widget? icon;
  final String? label;
  final Function onClickAction;
  final EdgeInsetsDirectional padding;
  final BuildContext context;

  QuickActionButtonWidget({super.key, this.icon, this.label, required this.onClickAction, required this.padding, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: DesignConfig.boxDecoration(Theme.of(context).scaffoldBackgroundColor,8,
          isboarder: true, bordercolor: ColorsRes.cardBoarderColor,
        ),
        padding: const EdgeInsets.all(6),
        child: InkWell(
          splashColor: ColorsRes.appColorLightHalfTransparent,
          highlightColor: ColorsRes.appColorTransparent,
          onTap: () {
            onClickAction();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getSizedBox(
                height: 8,
              ),
              icon ?? SizedBox.shrink(),
              getSizedBox(
                height: 8,
              ),
              CustomTextLabel(
                jsonKey: label,
                style: TextStyle(color: ColorsRes.mainTextColor, fontWeight: FontWeight.w400, fontSize: 14),
              ),
              getSizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
