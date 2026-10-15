import 'package:project/helper/utils/generalImports.dart';

class CheckoutScreen extends StatefulWidget {
  final String? selfPickupMode, total, doorstepDeliveryMode;
  const CheckoutScreen({Key? key, this.selfPickupMode, this.total, this.doorstepDeliveryMode}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late UserAddressData? selectedAddress;
  String _selectedMethod = "0";

  @override
  void initState() {
    super.initState();

    // Auto-select self-pickup if doorstep delivery is disabled
    if (widget.doorstepDeliveryMode == "0") {
      _selectedMethod = "1";
    }

    Future.delayed(Duration.zero).then(
      (value) async {
        // Load data based on selected delivery method
        if (_selectedMethod == "0") {
          // Doorstep delivery - load home delivery data
          await _handleDeliveryTypeChange("0");
        } else if (_selectedMethod == "1") {
          // Self-pickup - load self-pickup data
          await _handleDeliveryTypeChange("1");
        }

        // Load payment methods
        await context.read<PaymentMethodsProvider>().getPaymentMethods(context: context, from: "checkout").then(
          (value) {
            setState(() {});
            StripeService.init(
              stripeId: context.read<PaymentMethodsProvider>().paymentMethods?.data.stripePublishableKey ?? "",
              secretKey: context.read<PaymentMethodsProvider>().paymentMethods?.data.stripeSecretKey ?? "",
            );
          },
        );
      },
    );
  }

  Widget _buildOption({required String value, required String title}) {
    final bool isSelected = _selectedMethod == value;

    return GestureDetector(
      onTap: () async {
        // Handle doorstep delivery (value = "0")
        if (value == "0") {
          if (widget.doorstepDeliveryMode == "0") {
            // Doorstep delivery is disabled, show message
            showMessage(
              context,
              getTranslatedValue(context, doorStepDeliveryNoteLabel),
              MessageType.warning,
            );
          } else {
            // Doorstep delivery is enabled
            setState(() {
              _selectedMethod = value;
            });
            // For home delivery (value = "0"), call all required APIs including slots and address
            await _handleDeliveryTypeChange(value);
          }
        }
        // Handle self pickup (value = "1")
        else if (value == "1") {
          if (widget.selfPickupMode == "1") {
            // Self pickup is enabled
            setState(() {
              _selectedMethod = value;
            });
            // For self pickup (value = "1"), only call basic required APIs
            await _handleDeliveryTypeChange(value);
          } else {
            // Self pickup is disabled
            showMessage(
              context,
              getTranslatedValue(context, storePickupNoteLabel),
              MessageType.warning,
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 10, 5),
        decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: Constant.borderRadius7,
            border: Border.all(
              width: isSelected ? 1 : 0.3,
              color: isSelected ? ColorsRes.appColor : ColorsRes.grey,
            )),
        child: Row(
          children: [
            CustomRadio(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              inactiveColor: ColorsRes.mainTextColor,
              value: value,
              groupValue: _selectedMethod,
              activeColor: ColorsRes.appColor,
              onChanged: (value) async {
                // Handle doorstep delivery (value = "0")
                if (value == "0") {
                  if (widget.doorstepDeliveryMode == "0") {
                    // Doorstep delivery is disabled, show message
                    showMessage(
                      context,
                      getTranslatedValue(context, doorStepDeliveryNoteLabel),
                      MessageType.warning,
                    );
                  } else {
                    // Doorstep delivery is enabled
                    setState(() {
                      _selectedMethod = value!;
                    });
                    // For home delivery (value = "0"), call all required APIs including slots and address
                    await _handleDeliveryTypeChange(value!);
                  }
                }
                // Handle self pickup (value = "1")
                else if (value == "1") {
                  if (widget.selfPickupMode == "1") {
                    // Self pickup is enabled
                    setState(() {
                      _selectedMethod = value!;
                    });
                    // For self pickup (value = "1"), only call basic required APIs
                    await _handleDeliveryTypeChange(value!);
                  } else {
                    // Self pickup is disabled
                    showMessage(
                      context,
                      getTranslatedValue(context, storePickupNoteLabel),
                      MessageType.warning,
                    );
                  }
                }
              },
            ),
            Expanded(
              child: CustomTextLabel(
                jsonKey: title,
                style: TextStyle(
                  color: isSelected ? ColorsRes.mainTextColor : ColorsRes.grey,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openMap(String lat, String lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _handleDeliveryTypeChange(String deliveryType) async {
    try {
      if (deliveryType == "0") {
        // Home delivery - call all required APIs including slots and address
        await _loadHomeDeliveryData();
      } else if (deliveryType == "1") {
        // Self pickup - skip slots and address APIs, only call basic APIs
        await _loadSelfPickupData();
      }
    } catch (e) {
      // Handle error
      debugPrint("Error handling delivery type change: $e");
    }
  }

  Future<void> _loadHomeDeliveryData() async {
    // Get time slots for home delivery
    await context.read<CheckoutProvider>().getTimeSlotsSettings(context: context);

    // Get address and calculate delivery charges
    await context.read<CheckoutProvider>().getSingleAddressProvider(context: context).then(
      (selectedAddress) async {
        // Get free delivery value from selected time slot
        String isFreeDeliveryValue = "0"; // Default to not free
        final checkoutProvider = context.read<CheckoutProvider>();

        if (checkoutProvider.timeSlotsData != null &&
            checkoutProvider.timeSlotsData!.timeSlots.isNotEmpty) {
          int selectedTimeIndex = checkoutProvider.selectedTime;
          isFreeDeliveryValue = checkoutProvider.timeSlotsData!
                                .timeSlots[selectedTimeIndex]
                                .isFreeDelivery;
        }

        Map<String, String> params = {
          ApiAndParams.latitude: selectedAddress?.latitude?.toString() ?? Constant.session.getData(SessionManager.keyLatitude),
          ApiAndParams.longitude: selectedAddress?.longitude?.toString() ?? Constant.session.getData(SessionManager.keyLongitude),
          ApiAndParams.isCheckout: "1",
          ApiAndParams.isSelfPickup: "0", // Home delivery type
          ApiAndParams.isFreeDelivery: isFreeDeliveryValue
        };

        if (Constant.selectedPromoCodeId != "0") {
          params[ApiAndParams.promoCodeId] = Constant.selectedPromoCodeId;
        }

        await context.read<CheckoutProvider>().getOrderChargesProvider(
              context: context,
              params: params,
            );
      },
    );

    setState(() {});
  }

  Future<void> _loadSelfPickupData() async {
    // For self pickup, only get order charges without address/location dependency
    Map<String, String> params = {
      ApiAndParams.isCheckout: "1",
      ApiAndParams.isSelfPickup: "1", // Self pickup delivery type
      ApiAndParams.isFreeDelivery: "0" // Self pickup doesn't have free delivery concept
    };

    if (Constant.selectedPromoCodeId != "0") {
      params[ApiAndParams.promoCodeId] = Constant.selectedPromoCodeId;
    }

    // Get order charges for self pickup (no delivery charges)
    await context.read<CheckoutProvider>().getOrderChargesProvider(
          context: context,
          params: params,
        );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            if (!context.read<CheckoutProvider>().isPaymentUnderProcessing) {
              Navigator.pop(context);
            } else {
              showMessage(context, getTranslatedValue(context, noBackUntilPaymentDoneLabel), MessageType.warning);
            }
          }
        },
        child: Scaffold(
          appBar: getAppBar(
            context: context,
            title: CustomTextLabel(
              jsonKey: checkoutLabel,
              softWrap: true,
              style: TextStyle(
                color: ColorsRes.mainTextColor,
              ),
            ),
            onTap: () async {
              if (context.read<CheckoutProvider>().isPaymentUnderProcessing) {
                showMessage(context, getTranslatedValue(context, noBackUntilPaymentDoneLabel), MessageType.warning);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          body: Consumer<CheckoutProvider>(
            builder: (context, checkoutProvider, _) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsetsDirectional.only(
                            start: 10,
                            end: 10,
                            top: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextLabel(
                                jsonKey: chooseDeliveryMethodLabel,
                                style: TextStyle(
                                  color: ColorsRes.mainTextColor,
                                  fontSize: 17,
                                ),
                              ),
                              getSizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOption(value: "0", title: homeDeliveryLabel),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildOption(value: "1", title: storePickupLabel),
                                  ),
                                ],
                              ),
                              getSizedBox(height: 10),
                              CustomTextLabel(
                                jsonKey: storePickupNoteLabel,
                                style: TextStyle(
                                  color: ColorsRes.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (checkoutProvider.deliveryChargeData?.userBalance.toString() != "0" &&
                            checkoutProvider.deliveryChargeData?.userBalance.toString() != null)
                          Container(
                            decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                            padding: const EdgeInsets.all(10),
                            margin: EdgeInsetsDirectional.only(
                              start: 10,
                              end: 10,
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                defaultImg(
                                  image: AppAssets.walletIcon,
                                  iconColor: ColorsRes.appColor,
                                ),
                                getSizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextLabel(
                                        jsonKey: walletBalanceLabel,
                                      ),
                                      CustomTextLabel(
                                        jsonKey: "${context.read<CheckoutProvider>().availableWalletAmount}".currency,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorsRes.appColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                getSizedBox(width: 10),
                                CustomCheckbox(
                                  value: checkoutProvider.usedWallet ?? false,
                                  onChanged: (value) {
                                    checkoutProvider.userWalletAmount(value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        if (_selectedMethod == "1" && context.read<CheckoutProvider>().sellerSelfPickup != null)
                          Container(
                            decoration: DesignConfig.boxDecoration(
                              Theme.of(context).cardColor,
                              Constant.size10,
                              isboarder: false,
                              bordercolor: ColorsRes.subTitleMainTextColor,
                            ),
                            margin: EdgeInsetsDirectional.all(Constant.size10),
                            padding: EdgeInsetsDirectional.all(Constant.size15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      color: ColorsRes.appColor,
                                      size: 20,
                                    ),
                                    getSizedBox(width: Constant.size8),

                                    Expanded(
                                      child: CustomTextLabel(
                                        jsonKey: pickupFromStoreLabel,
                                        style: TextStyle(
                                          color: ColorsRes.mainTextColor,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    // const Spacer(),
                                    gradientBtnWidget(
                                      context,
                                      Constant.size5,
                                      callback: () {
                                        final lat = context.read<CheckoutProvider>().sellerSelfPickup?.pickupLatitude;
                                        final lng = context.read<CheckoutProvider>().sellerSelfPickup?.pickupLongitude;
                                        if (lat != null && lng != null) {
                                          _openMap(lat, lng);
                                        }
                                      },
                                      height: 35,
                                      width: 90,
                                      otherWidgets: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_outlined,
                                            color: ColorsRes.mainIconColor,
                                            size: 14,
                                          ),
                                          getSizedBox(width: Constant.size3),
                                          CustomTextLabel(
                                            text: getTranslatedValue(context, directionLabel),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ColorsRes.mainIconColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                getDivider(color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.15)),
                                getSizedBox(height: Constant.size5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: ColorsRes.appColor,
                                      size: 20,
                                    ),
                                    getSizedBox(width: Constant.size8),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomTextLabel(
                                            text:
                                                "${context.read<CheckoutProvider>().sellerSelfPickup?.sellerName!.toCapitalized() ?? /* getTranslatedValue(context, "store_name_not_available") */""}",
                                            style: TextStyle(fontSize: 14, color: ColorsRes.subTitleMainTextColor, fontWeight: FontWeight.w700),
                                            maxLines: 3,
                                            softWrap: true,
                                          ),
                                          CustomTextLabel(
                                            text:
                                                "${context.read<CheckoutProvider>().sellerSelfPickup!.pickupStoreAddress ?? /* getTranslatedValue(context, "address_not_available") */""}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: ColorsRes.subTitleMainTextColor,
                                            ),
                                            maxLines: 3,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ), /* 
                                    gradientBtnWidget(
                                      context,
                                      Constant.size5,
                                      callback: () {
                                        final lat = context.read<CheckoutProvider>().sellerSelfPickup?.pickupLatitude;
                                        final lng = context.read<CheckoutProvider>().sellerSelfPickup?.pickupLongitude;
                                        if (lat != null && lng != null) {
                                          _openMap(lat, lng);
                                        }
                                      },
                                      height: 35,
                                      width: 90,
                                      otherWidgets: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_outlined,
                                            color: ColorsRes.mainIconColor,
                                            size: 14,
                                          ),
                                          getSizedBox(width: Constant.size3),
                                          CustomTextLabel(
                                            text: getTranslatedValue(context, directionLabel),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ColorsRes.mainIconColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ), */
                                  ],
                                ),
                                getSizedBox(height: Constant.size12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      color: ColorsRes.appColor,
                                      size: 18,
                                    ),
                                    getSizedBox(width: Constant.size8),
                                    CustomTextLabel(
                                      text: context.read<CheckoutProvider>().sellerSelfPickup?.sellerMobile ??/* 
                                          getTranslatedValue(context, "phone_not_available") */"",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorsRes.subTitleMainTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                getSizedBox(height: Constant.size12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_outlined,
                                      color: ColorsRes.appColor,
                                      size: 18,
                                    ),
                                    getSizedBox(width: Constant.size8),
                                    CustomTextLabel(
                                      text:
                                          "${getTranslatedValue(context, openHoursLabel)}: ${context.read<CheckoutProvider>().sellerSelfPickup?.openingTime ?? "--"} - ${context.read<CheckoutProvider>().sellerSelfPickup?.closingTime ?? "--"}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorsRes.subTitleMainTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (checkoutProvider.checkoutAddressState == CheckoutAddressState.addressLoading &&
                            checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsLoading &&
                            context.read<PaymentMethodsProvider>().paymentMethodsState == PaymentMethodsState.loading)
                          CheckoutShimmer(),
                        if (_selectedMethod == "0" &&
                            context.read<PaymentMethodsProvider>().paymentMethodsState == PaymentMethodsState.loaded &&
                            (checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsLoaded ||
                                checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsError) &&
                            (checkoutProvider.checkoutAddressState == CheckoutAddressState.addressLoaded ||
                                checkoutProvider.checkoutAddressState == CheckoutAddressState.addressBlank ||
                                checkoutProvider.checkoutAddressState == CheckoutAddressState.addressError))
                          AddressWidget(),
                        if (context.read<PaymentMethodsProvider>().paymentMethodsState == PaymentMethodsState.loaded &&
                            (checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsLoaded ||
                                checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsError) &&
                            (checkoutProvider.checkoutAddressState == CheckoutAddressState.addressLoaded ||
                                checkoutProvider.checkoutAddressState == CheckoutAddressState.addressBlank ||
                                checkoutProvider.checkoutAddressState == CheckoutAddressState.addressError))
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 10, end: 10),
                            child: Column(
                              children: [
                                if (_selectedMethod == "0" && checkoutProvider.isTimeSlotSetting==true) GetTimeSlots(),
                                OrderNoteWidget(
                                  edtOrderNote: context.read<CheckoutProvider>().edtOrderNote,
                                ),
                              ],
                            ),
                          ),
                        if (checkoutProvider.totalAmount != 0.0 &&
                            (context.read<PaymentMethodsProvider>().paymentMethodsState == PaymentMethodsState.loaded &&
                                (checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsLoaded ||
                                    checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsError) &&
                                (checkoutProvider.checkoutAddressState == CheckoutAddressState.addressLoaded ||
                                    checkoutProvider.checkoutAddressState == CheckoutAddressState.addressBlank ||
                                    checkoutProvider.checkoutAddressState == CheckoutAddressState.addressError)))
                          PaymentMethodsWidget(
                            isPaymentUnderProcessing: checkoutProvider.isPaymentUnderProcessing,
                          ),
                        if (context.read<PaymentMethodsProvider>().paymentMethodsState == PaymentMethodsState.loaded &&
                            ((_selectedMethod == "0" &&
                                    checkoutProvider.checkoutDeliveryChargeState == CheckoutDeliveryChargeState.deliveryChargeLoaded &&
                                    (checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsLoaded ||
                                        checkoutProvider.checkoutTimeSlotsState == CheckoutTimeSlotsState.timeSlotsError) &&
                                    (checkoutProvider.checkoutAddressState == CheckoutAddressState.addressLoaded ||
                                        checkoutProvider.checkoutAddressState == CheckoutAddressState.addressBlank ||
                                        checkoutProvider.checkoutAddressState == CheckoutAddressState.addressError) &&
                                    checkoutProvider.selectedAddress?.id != null) ||
                                (_selectedMethod == "1")))
                          DeliveryChargesWidget(orderType: _selectedMethod),
                        if (checkoutProvider.checkoutDeliveryChargeState == CheckoutDeliveryChargeState.deliveryChargeLoading)
                          DeliveryChargeShimmer(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.only(
                      start: 15,
                      end: 15,
                      bottom: 10,
                      top: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextLabel(
                              jsonKey: totalLabel,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                            getSizedBox(width: 10),
                            CustomTextLabel(
                              text: context.read<CheckoutProvider>().totalAmount == 0.0
                                  ? widget.total.toString().currency
                                  : context
                                      .read<CheckoutProvider>()
                                      .totalAmount
                                      .toString()
                                      .currency, //context.read<CheckoutProvider>().totalAmount.toString().currency,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorsRes.appColor,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        PlaceOrderButtonWidget(
                          context: context,
                          selectedMethod: _selectedMethod,
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ));
  }
}
