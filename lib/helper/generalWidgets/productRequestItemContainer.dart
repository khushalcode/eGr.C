import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/productRequest.dart';

class ProductRequestItemContainer extends StatelessWidget {
  final ProductRequest? productRequest;
  final VoidCallback voidCallBack;

  const ProductRequestItemContainer({Key? key, this.productRequest, required this.voidCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check conditions
    bool hasImage = productRequest?.imageUrl != null && productRequest!.imageUrl!.isNotEmpty && productRequest!.imageUrl != "";

    bool hasDescription = productRequest?.description != null && productRequest!.description!.isNotEmpty && productRequest!.description != "";

    bool isRejected = productRequest?.status?.toLowerCase() == "rejected";

    // Show admin notes only if status is rejected and admin notes exist
    bool showAdminNotes = isRejected &&
                         productRequest?.adminNotes != null &&
                         productRequest!.adminNotes!.isNotEmpty &&
                         productRequest!.adminNotes != "";

    String status = productRequest?.status ?? "";
    Color statusColor = status.toLowerCase() == "accepted"
        ? ColorsRes.productRequestStatusAcceptedColor
        : status.toLowerCase() == "rejected"
            ? ColorsRes.productRequestStatusRejectedColor
            : ColorsRes.productRequestStatusPendingColor;
    Color statusBackgroundColor = status.toLowerCase() == "accepted"
        ? ColorsRes.productRequestStatusAcceptedBgColor
        : status.toLowerCase() == "rejected"
            ? ColorsRes.productRequestStatusRejectedBgColor
            : ColorsRes.productRequestStatusPendingBgColor;

    return GestureDetector(
      onTap: voidCallBack,
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom: 15),
        decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge overlay
            if (hasImage)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: setNetworkImg(
                      boxFit: BoxFit.cover,
                      image: productRequest?.imageUrl ?? "",
                      height: context.height / 4.5,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildStatusBadge(status, statusColor, statusBackgroundColor, context),
                  ),
                ],
              ),

            // Content area
            Padding(
              padding: EdgeInsetsDirectional.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge if no image
                  if (!hasImage)
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 10),
                      child: _buildStatusBadge(status, statusColor, statusBackgroundColor, context),
                    ),

                  // Date
                  if (productRequest?.createdAt != null && productRequest!.createdAt!.isNotEmpty)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 5),
                      child: CustomTextLabel(
                        text: productRequest!.createdAt!.toString().formatDate(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: ColorsRes.subTitleMainTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                  // Description
                  if (hasDescription)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
                        decoration: BoxDecoration(
                          color: ColorsRes.mainTextColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ColorsRes.mainTextColor.withValues(alpha: 0.2)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            dense: true,
                            visualDensity: VisualDensity(horizontal: -4, vertical: 0),
                            tilePadding: EdgeInsets.zero,
                            iconColor: ColorsRes.mainTextColor,
                            collapsedIconColor: ColorsRes.mainTextColor,expandedAlignment: Alignment.topLeft,
                            title: Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8.0),
                              child: CustomTextLabel(
                                jsonKey: descriptionLabel,
                                style: TextStyle(
                                  color: ColorsRes.mainTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10),
                                child: CustomTextLabel(
                                  text: productRequest!.description ?? "",
                                  style: TextStyle(color: ColorsRes.mainTextColor, height: 1.4,),textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Admin notes
                  if (showAdminNotes)
                    Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorsRes.appColorRed),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(dense: true, visualDensity: VisualDensity(horizontal: -4, vertical: 0),
                          tilePadding: EdgeInsets.zero,iconColor: ColorsRes.appColorRed,collapsedIconColor: ColorsRes.appColorRed,
                          title: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8.0),
                            child: CustomTextLabel(
                              jsonKey: reasonForRejectionLabel,
                              style: TextStyle(
                                color: ColorsRes.appColorRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10),
                              child: CustomTextLabel(
                                text: productRequest!.adminNotes??"",
                                style: TextStyle(color: ColorsRes.appColorRed, fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color statusColor, Color statusBackgroundColor, BuildContext context) {
    if (status.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsetsDirectional.all(5),
      decoration: BoxDecoration(
        color: statusBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: CustomTextLabel(
        jsonKey: getTranslatedValue(context, status),
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
