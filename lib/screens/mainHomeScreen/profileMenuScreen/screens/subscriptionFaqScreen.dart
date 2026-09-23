import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/subscriptionFaqsProvider.dart';
import 'package:project/models/subscriptionFaqs.dart';

class SubscriptionFaqScreen extends StatefulWidget {
  const SubscriptionFaqScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionFaqScreen> createState() => _SubscriptionFaqScreenState();
}

class _SubscriptionFaqScreenState extends State<SubscriptionFaqScreen> {
  ScrollController scrollController = ScrollController();

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

    // _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<SubscriptionFaqsProvider>().hasMoreData) {
          context
              .read<SubscriptionFaqsProvider>()
              .getSubscriptionFaqsProvider(params: {}, context: context);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      context.read<SubscriptionFaqsProvider>().getSubscriptionFaqsProvider(params: {}, context: context);
    });

    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: faqTitleLabel,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: setRefreshIndicator(
        refreshCallback: () {
          context.read<SubscriptionFaqsProvider>().offset = 0;
          context.read<SubscriptionFaqsProvider>().subscriptionFaqs = [];
          return context
              .read<SubscriptionFaqsProvider>()
              .getSubscriptionFaqsProvider(params: {}, context: context);
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          padding: EdgeInsets.zero,
          child: Consumer<SubscriptionFaqsProvider>(
            builder: (context, subscriptionFaqsProvider, _) {
              List<SubscriptionFaqs> faqs = subscriptionFaqsProvider.subscriptionFaqs;

              if (subscriptionFaqsProvider.subscriptionFaqsState == SubscriptionFaqsState.initial ||
                  subscriptionFaqsProvider.subscriptionFaqsState == SubscriptionFaqsState.loading) {
                return getFaqListShimmer();
              } else if (subscriptionFaqsProvider.subscriptionFaqsState == SubscriptionFaqsState.loaded ||
                  subscriptionFaqsProvider.subscriptionFaqsState == SubscriptionFaqsState.loadingMore) {
                return Column(
                  children: List.generate(faqs.length, (index) {
                    return _buildFaqItem(faqs[index]);
                  }),
                );
              } else {
                return DefaultBlankItemMessageScreen(
                  image: "no_faq_icon",
                  title: noFaqFoundTitleLabel,
                  description: noFaqFoundMessageLabel,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(SubscriptionFaqs faq) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
      decoration: DesignConfig.boxDecoration(
        Theme.of(context).cardColor,
        8,
        isboarder: true,
        bordercolor: ColorsRes.cardBoarderColor,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Remove top & bottom lines
        ),
        child: ExpansionTile(
          initiallyExpanded: faq.isExpanded,
          onExpansionChanged: (bool expanded) {
            setState(() => faq.isExpanded = expanded);
          },
          title: CustomTextLabel(
            text: faq.question ?? '',
            style: TextStyle(
              color: ColorsRes.mainTextColor,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            maxLines: (faq.isExpanded) ? null : 2,
          ),
          trailing: Icon(
            (faq.isExpanded) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: ColorsRes.mainTextColor,
          ),
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 16,
                top: 5,
                bottom: 16,
                end: 16,
              ),
              child: CustomTextLabel(
                text: faq.answer ?? '',
                style: TextStyle(
                  color: ColorsRes.subTitleMainTextColor,
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getFaqListShimmer() {
    return Column(
      children: List.generate(20, (index) => faqItemShimmer()),
    );
  }

  faqItemShimmer() {
    return CustomShimmer(
      margin: EdgeInsets.symmetric(
        vertical: Constant.size5,
        horizontal: Constant.size10,
      ),
      height: 50,
      width: context.width,
    );
  }
}