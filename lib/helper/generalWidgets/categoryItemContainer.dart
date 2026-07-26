import 'package:project/helper/utils/generalImports.dart';

class CategoryItemContainer extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback voidCallBack;

  const CategoryItemContainer(
      {Key? key, required this.category, required this.voidCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidCallBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsetsDirectional.all(10),
              child: SizedBox(
                height: context.height,
                width: context.width/5,
                child: ClipRRect(
                  borderRadius: Constant.mightHaveNoBackground(category.imageUrl!)
            ? BorderRadius.circular(8): BorderRadius.circular(100),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: setNetworkImg(
                    image: category.imageUrl ?? "",
                    boxFit: Constant.mightHaveNoBackground(category.imageUrl!)
            ? null: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CustomTextLabel(
              text: category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
