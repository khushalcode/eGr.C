import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/blog.dart';
import 'package:html/parser.dart' show parse;

String htmlToPlainText(String htmlString) {
  final document = parse(htmlString);
  return parse(document.body?.text ?? "").documentElement?.text ?? "";
}

class BlogItemContainer extends StatelessWidget {
  final Blog? blog;
  final VoidCallback voidCallBack;

  const BlogItemContainer({Key? key, this.blog, required this.voidCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidCallBack,
      child: Container(
        decoration: DesignConfig.boxDecoration(
            Theme.of(context).cardColor, 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: context.height/10,
                width: context.width/5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: setNetworkImg(
                    boxFit: BoxFit.cover,
                    image: blog?.imageUrl ?? "",
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 10, end: 10),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextLabel(
                      text: blog!.category!.name,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    CustomTextLabel(
                      text: blog?.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    CustomTextLabel(
                      text: htmlToPlainText(blog!.description!),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
