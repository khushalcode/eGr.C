import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/blog.dart';

import 'package:quill_html_editor/quill_html_editor.dart';

class BlogDetailScreen extends StatefulWidget {
  final Blog? blog;

  const BlogDetailScreen({Key? key, this.blog}) : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  late QuillEditorController quillEditorController;
  bool _isControllerReady = false;

  @override
  void initState() {
    quillEditorController = QuillEditorController();
    // Preload HTML content
    if (widget.blog?.description != null) {
      quillEditorController.setText(widget.blog!.description!);
    }
    quillEditorController.setText(widget.blog?.description ?? "").then((_) {
      if (mounted) {
        setState(() {
          _isControllerReady = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    quillEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String htmlContent = widget.blog!.description!;

    return Scaffold(
      appBar: getAppBar(
          title: CustomTextLabel(
            jsonKey: blogDetailLabel,
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
          context: context),
      /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            productListScreen,
            arguments: ["blog", widget.blog!.id.toString(), widget.blog!.name],
          );
        },
        icon: Icon(Icons.add_shopping_cart),
        label: CustomTextLabel(jsonKey: exploreProductsLabel,
          style: TextStyle(color: ColorsRes.appColorWhite),
        ),
      ), */
      body: Padding(
        padding: EdgeInsetsDirectional.only(top: 10, bottom: 10),
        child: ListView(children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 10, end: 10),
            child: CustomTextLabel(
                text: widget.blog!.title!,
                style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 10, end: 10),
            child: CustomTextLabel(
              text: widget.blog!.shortDescription!,
              style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: 10, bottom: 10, start: 10, end: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: setNetworkImg(boxFit: BoxFit.cover, image: widget.blog!.imageUrl ?? "", height: context.height / 3.5, width: context.width),
                ),
                // Category Badge
                PositionedDirectional(
                  bottom: 12,
                  end: 12,
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                    decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8),
                    child: CustomTextLabel(
                      text: widget.blog!.category!.name!,
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Published Date and Read Time Cards
          Container(
            padding: EdgeInsetsDirectional.only(top: 8, start: 8, bottom: 8, end: 8),
            margin: EdgeInsetsDirectional.only(start: 10, end: 10),
            decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8, isboarder: true, bordercolor: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.25)),
            child: Row(
              children: [
                // Published Date Card
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: ColorsRes.subTitleMainTextColor,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: CustomTextLabel(
                              jsonKey: publishDateLabel,
                              style: TextStyle(
                                color: ColorsRes.subTitleMainTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 16),
                          SizedBox(width: 8),
                          CustomTextLabel(
                            text: widget.blog!.createdAt!.toString().formatEstimateDateForBlogs(),
                            style: TextStyle(
                              color: ColorsRes.mainTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: context.height/20,
                  width: 1,
                  color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.2),
                ),
                SizedBox(width: 12),
                // Read Time Card
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: ColorsRes.subTitleMainTextColor,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: CustomTextLabel(
                              jsonKey: readTimeLabel,
                              style: TextStyle(
                                color: ColorsRes.subTitleMainTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          SizedBox(width: 8),
                          CustomTextLabel(
                            text: "${widget.blog!.readTime!}",
                            style: TextStyle(
                              color: ColorsRes.mainTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(color: Theme.of(context).cardColor,
            margin: EdgeInsetsDirectional.only(top: 10),
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: _isControllerReady
                ? _getHtmlContainer(htmlContent)
                : Center(
                    child: CircularProgressIndicator(color: ColorsRes.appColor),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _getHtmlContainer(String htmlContent) {
    return RepaintBoundary(
      child: QuillHtmlEditor(
        text: htmlContent,
        hintText: getTranslatedValue(context, descriptionGoesHereLabel),
        isEnabled: false,
        ensureVisible: false,
        minHeight: 10,
        autoFocus: false,
        textStyle: TextStyle(color: ColorsRes.mainTextColor),
        hintTextStyle: TextStyle(color: ColorsRes.subTitleMainTextColor),
        hintTextAlign: TextAlign.start,
        padding: EdgeInsets.zero,
        hintTextPadding: const EdgeInsets.only(left: 20),
        backgroundColor: Theme.of(context).cardColor,
        inputAction: InputAction.newline,
        loadingBuilder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorsRes.appColor,
            ),
          );
        },
        controller: quillEditorController,
      ),
    );
  }
}
