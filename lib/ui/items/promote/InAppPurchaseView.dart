import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttermulticity/api/common/ps_resource.dart';
import 'package:fluttermulticity/config/ps_colors.dart';
import 'package:fluttermulticity/constant/ps_constants.dart';
import 'package:fluttermulticity/constant/ps_dimens.dart';
import 'package:fluttermulticity/provider/promotion/item_promotion_provider.dart';
import 'package:fluttermulticity/repository/item_paid_history_repository.dart';
import 'package:fluttermulticity/ui/common/base/ps_widget_with_multi_provider.dart';
import 'package:fluttermulticity/ui/common/dialog/error_dialog.dart';
import 'package:fluttermulticity/ui/common/dialog/success_dialog.dart';
import 'package:fluttermulticity/ui/common/dialog/warning_dialog_view.dart';
import 'package:fluttermulticity/ui/common/ps_dropdown_base_with_controller_widget.dart';
import 'package:fluttermulticity/utils/ps_progress_dialog.dart';
import 'package:fluttermulticity/utils/utils.dart';
import 'package:fluttermulticity/viewobject/common/ps_value_holder.dart';
import 'package:fluttermulticity/viewobject/holder/item_paid_history_parameter_holder.dart';
import 'package:fluttermulticity/viewobject/item_paid_history.dart';
import 'package:fluttermulticity/viewobject/ps_app_info.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class InAppPurchaseView extends StatefulWidget {
  const InAppPurchaseView(this.itemId, this.appInfo);
  final String itemId;
  final PSAppInfo appInfo;
  @override
  _InAppPurchaseViewState createState() => _InAppPurchaseViewState();
}

class _InAppPurchaseViewState extends State<InAppPurchaseView> {
  /// Is the API available on the device
  bool available = true;

  /// The In App Purchase plugin
  final InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = <ProductDetails>[];

  /// Updates to purchases
  StreamSubscription<List<PurchaseDetails>> _subscription;

  ItemPaidHistoryRepository repo1;
  PsValueHolder psValueHolder;
  ItemPromotionProvider itemPromotionProvider;
  TextEditingController startDateController = TextEditingController();
  String amount;
  String status = '';

  String testId = 'android.test.purchased';
  String prdIdforIOS;
  String prdIdforAndroid;
  Map<String, String> dayMap = <String, String>{};
  final bool _kAutoConsume = true;
  String startDate;

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    PsProgressDialog.dismissDialog();
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        //
        // Call PS Server
        //
        print('NEW PURCHASE');
        print(purchaseDetails.status);

        if (itemPromotionProvider.selectedDate != null) {
          startDate = itemPromotionProvider.selectedDate;
        }

        final DateTime dateTime = DateTime.now();
        final int resultStartTimeStamp =
            Utils.getTimeStampDividedByOneThousand(dateTime);

        if (await Utils.checkInternetConnectivity()) {
          final ItemPaidHistoryParameterHolder itemPaidHistoryParameterHolder =
              ItemPaidHistoryParameterHolder(
                  itemId: widget.itemId,
                  amount: amount,
                  howManyDay: dayMap[purchaseDetails.productID],
                  paymentMethod: PsConst.PAYMENT_IN_APP_PURCHASE_METHOD,
                  paymentMethodNounce: '',
                  startDate: startDate,
                  startTimeStamp: resultStartTimeStamp.toString(),
                  razorId: '',
                  purchasedId: purchaseDetails.purchaseID,
                  isPaystack: PsConst.ZERO);

          final PsResource<ItemPaidHistory> padiHistoryDataStatus =
              await itemPromotionProvider
                  .postItemHistoryEntry(itemPaidHistoryParameterHolder.toMap());

          if (padiHistoryDataStatus.data != null) {
            // progressDialog.dismiss();
            PsProgressDialog.dismissDialog();
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext contet) {
                  return SuccessDialog(
                    message: Utils.getString(context, 'item_promote__success'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  );
                });
          } else {
            PsProgressDialog.dismissDialog();
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: padiHistoryDataStatus.message,
                  );
                });
          }
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                      Utils.getString(context, 'error_dialog__no_internet'),
                );
              });
        }
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
      if (Platform.isAndroid) {
        if (!_kAutoConsume) {
          await InAppPurchaseConnection.instance
              .consumePurchase(purchaseDetails);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
      }
    }
  }

  /// Initialize data
  Future<void> _initialize() async {
    // Check availability of In App Purchases
    available = await _iap.isAvailable();

    if (available) {
      await _getProducts();

      // Listen to new purchases
      _subscription = _iap.purchaseUpdatedStream.listen(
          (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (dynamic error) {
        // handle error here.
      });

      await _removeUnfinishTransaction();
    }
  }

  Map<String, dynamic> getIdAndDayList(String idAndDayString) {
    final List<String> idList = <String>[];
    final Map<String, String> dayMap = <String, String>{};
    final Set<String> ids = <String>{};

    if (idAndDayString != null && idAndDayString.contains('##')) {
      final List<String> idandDayList = idAndDayString.split('##');

      for (String idAndDay in idandDayList) {
        if (idAndDay != null && idAndDay.contains('@@')) {
          final List<String> idAndDaySplit = idAndDay.split('@@');
          idList.add(idAndDaySplit[0]);
          dayMap[idAndDaySplit[0]] = idAndDaySplit[1];
        }
      }

      for (int i = 0; i < idList.length; i++) {
        ids.add(idList[i]);
      }
    }

    return <String, dynamic>{'idSet': ids, 'dayMap': dayMap};
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    ProductDetailsResponse response;
    Map<String, dynamic> idAndDayList;
    if (Platform.isAndroid) {
      idAndDayList = getIdAndDayList(widget.appInfo.inAppPurchasedPrdIdAndroid);
    } else {
      idAndDayList = getIdAndDayList(widget.appInfo.inAppPurchasedPrdIdIOS);
    }

    if (idAndDayList != null) {
      dayMap = idAndDayList['dayMap'];
      response = await _iap.queryProductDetails(idAndDayList['idSet']);
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  Future<void> _removeUnfinishTransaction() async {
    final SKPaymentQueueWrapper paymentWrapper = SKPaymentQueueWrapper();
    try {
      final List<SKPaymentTransactionWrapper> transactions =
          await paymentWrapper.transactions();
      for (SKPaymentTransactionWrapper transaction in transactions) {
        try {
          await paymentWrapper.finishTransaction(transaction);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// Purchase a product
  Future<void> _buyProduct(ProductDetails prod) async {
    ///
    /// Show Progress Dialog
    ///
    await PsProgressDialog.showDialog(context);

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);

    if (Platform.isIOS) {
      await _removeUnfinishTransaction();
    }

    try {
      //Android
      final bool status =
          await _iap.buyConsumable(purchaseParam: purchaseParam);
      print(status);
    } catch (e) {
      print('error');
      if (Platform.isIOS) {
        await _removeUnfinishTransaction();
        try {
          final bool status =
              await _iap.buyConsumable(purchaseParam: purchaseParam);
          print(status);
        } catch (e) {
          print('error 2');
          print(e);
        }
      }
    }
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ItemPaidHistoryRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          brightness: Utils.getBrightnessForAppBar(context),
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: PsColors.mainColorWithWhite),
          title: Text(
            Utils.getString(
                context, 'item_promote__purchase_promotion_packages'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6.copyWith(
                fontWeight: FontWeight.bold,
                color: PsColors.mainColorWithWhite),
          )),
      body: PsWidgetWithMultiProvider(
        child: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ItemPromotionProvider>(
              lazy: false,
              create: (BuildContext context) {
                itemPromotionProvider =
                    ItemPromotionProvider(itemPaidHistoryRepository: repo1);

                return itemPromotionProvider;
              },
            ),
          ],
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: PsDimens.space12),
                child: PsDropdownBaseWithControllerWidget(
                    title: Utils.getString(
                        context, 'item_promote__ads_start_date'),
                    textEditingController: startDateController,
                    isMandatory: true,
                    onTap: () async {
                      final DateTime today = DateTime.now();
                      Utils.psPrint('Today is ' + today.toString());
                      // final DateTime oneDaysAgo =
                      //     today.subtract(const Duration(days: 1));
                      final DateTime dateTime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: today,
                          lastDate: DateTime(2025));

                      if (dateTime != null) {
                        itemPromotionProvider.selectedDate =
                            DateFormat.yMMMMd('en_US').format(dateTime);

                        Utils.psPrint('Today Date format is ' +
                            itemPromotionProvider.selectedDate);
                      }
                      setState(() {
                        startDateController.text =
                            itemPromotionProvider.selectedDate;
                      });
                    }),
              ),
              for (ProductDetails prod in _products) ...<Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: PsDimens.space150,
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12,
                      right: PsDimens.space12,
                      bottom: PsDimens.space8),
                  decoration: BoxDecoration(
                    color: Utils.isLightMode(context)
                        ? Colors.white60
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(PsDimens.space4),
                    border: Border.all(
                        color: Utils.isLightMode(context)
                            ? Colors.grey[200]
                            : Colors.black87),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: PsDimens.space8,
                          left: PsDimens.space16,
                        ),
                        child: Text(
                          prod.title,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: PsDimens.space4,
                          left: PsDimens.space16,
                        ),
                        child: Text(
                          prod.description,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: PsDimens.space4,
                          left: PsDimens.space16,
                        ),
                        child: Text(
                          prod.price,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      // const SizedBox(height: PsDimens.space8),
                      Padding(
                        padding: const EdgeInsets.only(left: PsDimens.space230),
                        child: MaterialButton(
                          color: PsColors.mainColor,
                          height: 30,
                          shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(PsDimens.space2)),
                          ),
                          child: Text(
                            Utils.getString(
                                context, 'item_promote__purchase_buy'),
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white),
                          ),
                          onPressed: () {
                            if (itemPromotionProvider.selectedDate == null) {
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                      message: Utils.getString(context,
                                          'item_promote__choose_start_date'),
                                      onPressed: () {},
                                    );
                                  });
                            } else {
                              amount = prod.price;
                              return _buyProduct(ProductDetails(
                                  id: prod.id,
                                  price: prod.price,
                                  title: prod.title,
                                  description: prod.description));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          )),
        ),
      ),
    );
  }
}