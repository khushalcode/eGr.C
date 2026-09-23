import 'package:project/helper/utils/generalImports.dart';

class SectionProductListStyle1 extends StatelessWidget {
  final List<ProductListItem> products;

  const SectionProductListStyle1({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,padding: EdgeInsetsDirectional.only(start: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(products.length, (index) {
            ProductListItem product = products[index];
            return HomeScreenProductListItem(
              product: product,
              position: index,
            );
          }),
        ),
      ),
    );
  }
}
