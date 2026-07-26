import 'package:image_picker_platform_interface/src/types/image_source.dart' as ip;
import 'package:project/helper/generalWidgets/productRequestItemContainer.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/addProductRequestProvider.dart';
import 'package:project/provider/productRequestProvider.dart';
import 'package:project/screens/ordersHistoryScreen/widgets/orderListShimmer.dart';

class ProductRequestListScreen extends StatefulWidget {
  const ProductRequestListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductRequestListScreen> createState() => _ProductRequestListScreenState();
}

class _ProductRequestListScreenState extends State<ProductRequestListScreen> {
  ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedImagePath = "";
  bool isLoading = false;

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<ProductRequestListProvider>().hasMoreData) {
          productRequestListApiCall(reset: false);
        }
      }
    }
  }

  productRequestListApiCall({bool? reset}) {
    if(reset==true){
      context.read<ProductRequestListProvider>().productRequestList.clear();
      context.read<ProductRequestListProvider>().offset = 0;
    }
    context.read<ProductRequestListProvider>().getProductRequestApiProvider(params: {}, context: context);
  }

  apiCall(){
    productRequestListApiCall(reset: true);
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    Future.delayed(Duration.zero).then((value) {
      productRequestListApiCall(reset: false);
    });
  }

  @override
  dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(StateSetter? modalStateSetter) async {
    final pickerContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
      backgroundColor: Theme.of(context).cardColor,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getSizedBox(
                height: 10,
              ),
              Center(
                child: CustomTextLabel(
                  jsonKey: selectOptionLabel,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: Theme.of(bottomSheetContext).textTheme.titleMedium!.merge(
                        TextStyle(
                          letterSpacing: 0.5,
                          color: ColorsRes.mainTextColor,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                ),
              ),
              getSizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: () async {
                      // No permission needed for gallery on Android 13+ (uses photo picker)
                      ImagePicker()
                          .pickImage(source: ip.ImageSource.gallery)
                          .then((value) {
                        if (value != null) {
                          Navigator.pop(bottomSheetContext, value);
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 50,
                          color: ColorsRes.subTitleMainTextColor,
                        ),
                        getSizedBox(height: 8),
                        CustomTextLabel(
                          jsonKey: galleryLabel,
                          style: TextStyle(
                            color: ColorsRes.mainTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  getSizedBox(width: 10),
                  // Camera Button
                  GestureDetector(
                    onTap: () async {
                      // Close the bottom sheet first
                      Navigator.pop(bottomSheetContext);

                      // Then handle camera
                      await hasCameraPermissionGiven(pickerContext).then(
                        (value) async {
                          if (Platform.isAndroid) {
                            if (value.isGranted) {
                              try {
                                final pickedFile = await ImagePicker().pickImage(
                                  source: ip.ImageSource.camera,
                                  preferredCameraDevice: CameraDevice.rear,
                                  maxHeight: 1024,
                                  maxWidth: 1024,
                                );
                                if (pickedFile != null) {
                                  selectedImagePath = pickedFile.path;
                                  if (modalStateSetter != null) {
                                    modalStateSetter(() {});
                                  } else {
                                    setState(() {});
                                  }
                                }
                              } catch (e) {
                                // Handle error silently
                              }
                            } else if (value.isDenied) {
                              await Permission.camera.request();
                            } else if (value.isPermanentlyDenied) {
                              if (!Constant.session.getBoolData(SessionManager.keyPermissionCameraHidePromptPermanently)) {
                                showModalBottomSheet(
                                  context: pickerContext,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        PermissionHandlerBottomSheet(
                                          titleJsonKey: cameraPermissionTitleLabel,
                                          messageJsonKey: cameraPermissionMessageLabel,
                                          sessionKeyForAskNeverShowAgain: SessionManager.keyPermissionCameraHidePromptPermanently,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          } else if (Platform.isIOS) {
                            try {
                              final pickedFile = await ImagePicker().pickImage(
                                source: ip.ImageSource.camera,
                                preferredCameraDevice: CameraDevice.rear,
                                maxHeight: 1024,
                                maxWidth: 1024,
                              );
                              if (pickedFile != null) {
                                selectedImagePath = pickedFile.path;
                                if (modalStateSetter != null) {
                                  modalStateSetter(() {});
                                } else {
                                  setState(() {});
                                }
                              }
                            } catch (e) {
                              // Handle error silently
                            }
                          }
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 50,
                          color: ColorsRes.subTitleMainTextColor,
                        ),
                        getSizedBox(height: 8),
                        CustomTextLabel(
                          jsonKey: cameraLabel,
                          style: TextStyle(
                            color: ColorsRes.mainTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        selectedImagePath = value.path;
        if (modalStateSetter != null) {
          modalStateSetter(() {});
        } else {
          setState(() {});
        }
      }
    });
  }

  Future<void> _submitProductRequest() async {
    // Check if at least one field is filled
    bool hasDescription = _descriptionController.text.trim().isNotEmpty;
    bool hasImage = selectedImagePath.isNotEmpty;

    if (!hasDescription && !hasImage) {
      showMessage(context, getTranslatedValue(context, provideDescriptionOrImageLabel), MessageType.warning);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> params = {};

      // Add description only if it's not empty
      if (hasDescription) {
        params[ApiAndParams.description] = _descriptionController.text.trim();
      }

      // Add image only if it's selected
      if (hasImage) {
        params[ApiAndParams.image] = selectedImagePath;
      }

      bool success = await context.read<AddProductRequestProvider>().addProductRequest(
        context: context,
        params: params,
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        showMessage(context, context.read<AddProductRequestProvider>().message, MessageType.success);

        // Get the newly added product request from the provider
        final newProductRequest = context.read<AddProductRequestProvider>().newlyAddedProductRequest;

        // Add it to the existing list if available
        if (newProductRequest != null) {
          context.read<ProductRequestListProvider>().addNewProductRequestToList(newProductRequest);
        }

        Navigator.pop(context);

        // Clear form
        _descriptionController.clear();
        selectedImagePath = "";
      } else {
        showMessage(context, context.read<AddProductRequestProvider>().message, MessageType.error);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  void _showAddProductRequestBottomSheet() {
    // Reset form state
    _descriptionController.clear();
    selectedImagePath = "";
    isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext bottomSheetContext) {
        return ChangeNotifierProvider(
          create: (_) => AddProductRequestProvider(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextLabel(
                              jsonKey: addProductRequestLabel,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: ColorsRes.mainTextColor),
                            ),
                          ],
                        ),
                        getSizedBox(height: 10),
                        // Description Field
                        CustomTextLabel(
                          jsonKey: productDescriptionLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorsRes.mainTextColor,
                          ),
                        ),
                        getSizedBox(height: 10),
                        editBoxWidget(
                          context,
                          _descriptionController,
                          (value) => null, // No validation required, field is optional
                          getTranslatedValue(context, productDescriptionLabel),
                          getTranslatedValue(context, enterProductDescriptionLabel), // No error label needed
                          TextInputType.multiline,
                          maxLines: 5,
                          minLines: 5,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(250), // limit to 250 chars
                          ],
                        ),
                        getSizedBox(height: 20),

                        // Image Selection
                        CustomTextLabel(
                          jsonKey: productImageLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorsRes.mainTextColor,
                          ),
                        ),
                        getSizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            await _pickImage(setModalState);
                          },
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorsRes.subTitleMainTextColor,
                                width: 1,
                              ),
                            ),
                            child: selectedImagePath.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 60,
                                        color: ColorsRes.subTitleMainTextColor,
                                      ),
                                      getSizedBox(height: 10),
                                      CustomTextLabel(
                                        jsonKey: tapToSelectImageLabel,
                                        style: TextStyle(
                                          color: ColorsRes.subTitleMainTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(selectedImagePath),
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedImagePath = "";
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorsRes.appColorRed,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        getSizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: gradientBtnWidget(
                            context,
                            10,
                            title: isLoading
                                ? getTranslatedValue(context, submittingLabel)
                                : getTranslatedValue(context, submitRequestLabel),
                            callback: () async {
                              if (!isLoading) {
                                setModalState(() {
                                  isLoading = true;
                                });
                                await _submitProductRequest();
                                setModalState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                        getSizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: productRequestLabel,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: setRefreshIndicator(
        refreshCallback: () async{
          context.read<ProductRequestListProvider>().productRequestList.clear();
          context.read<ProductRequestListProvider>().offset = 0;
          await apiCall();
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(10),
          child: productRequestWidget()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductRequestBottomSheet,
        backgroundColor: ColorsRes.appColor,
        child: Icon(
          Icons.add,
          color: ColorsRes.mainIconColor,
        ),
      ),
    );
  }

//productRequestList ui
  Widget productRequestWidget() {
    return Consumer<ProductRequestListProvider>(
      builder: (context, productRequestListProvider, _) {

        if (productRequestListProvider.productRequestState == ProductRequestState.loading) {
          return OrderListShimmer();
        } else if (productRequestListProvider.productRequestList.isEmpty) {
          return DefaultBlankItemMessageScreen(
            title: emptyProductListMessageLabel,
            description: emptyProductListDescriptionLabel,
            image: "no_product_icon",
            buttonTitle: tryAgainLabel,
            callback: () {
              productRequestListApiCall(reset: true);
            },
          );
        } else {
          return ListView.builder(
            controller: scrollController,
            itemCount: productRequestListProvider.productRequestList.length,
            itemBuilder: (BuildContext context, int index) {
              final productRequest = productRequestListProvider.productRequestList[index];

              return Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5,
                  end: 5,
                  top: 5,
                  bottom: 10,
                ),
                child: ProductRequestItemContainer(
                  productRequest: productRequest,
                  voidCallBack: () {
                    // Navigator.pushNamed(
                    //   context,
                    //   productRequestDetailScreen,
                    //   arguments: [
                    //     productRequest
                    //   ],
                    // );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

}
