import 'package:fluttermulticity/api/common/ps_status.dart';
import 'package:fluttermulticity/config/ps_colors.dart';
import 'package:fluttermulticity/config/ps_config.dart';
import 'package:fluttermulticity/constant/ps_constants.dart';
import 'package:fluttermulticity/constant/ps_dimens.dart';
import 'package:fluttermulticity/constant/route_paths.dart';
import 'package:fluttermulticity/provider/history/history_provider.dart';
import 'package:fluttermulticity/repository/history_repsitory.dart';
import 'package:flutter/material.dart';
import 'package:fluttermulticity/ui/common/ps_frame_loading_widget.dart';
import 'package:fluttermulticity/ui/history/item/history_horizontal_list_item.dart';
import 'package:fluttermulticity/utils/utils.dart';
import 'package:fluttermulticity/viewobject/holder/intent_holder/item_detail_intent_holder.dart';
import 'package:fluttermulticity/viewobject/item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HistoryHorizontalListView extends StatefulWidget {
  const HistoryHorizontalListView(
      {Key key, @required this.animationController, @required this.animation})
      : super(key: key);
  final AnimationController animationController;
  final Animation<double> animation;
  @override
  _HistoryHorizontalListViewState createState() =>
      _HistoryHorizontalListViewState();
}

class _HistoryHorizontalListViewState extends State<HistoryHorizontalListView>
    with SingleTickerProviderStateMixin {
  HistoryRepository historyRepo;
  dynamic data;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // data = EasyLocalizationProvider.of(context).data;
    historyRepo = Provider.of<HistoryRepository>(context);

    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    return ChangeNotifierProvider<HistoryProvider>(
        lazy: false,
        create: (BuildContext context) {
          final HistoryProvider provider = HistoryProvider(
            repo: historyRepo,
          );
          provider.loadHistoryList();
          return provider;
        },
        child: Consumer<HistoryProvider>(
          builder:
              (BuildContext context, HistoryProvider provider, Widget child) {
            if (provider.historyList != null &&
                provider.historyList.data != null) {
              return AnimatedBuilder(
                  animation: widget.animationController,
                  child: (provider.historyList.data != null &&
                          provider.historyList.data.isNotEmpty)
                      ? Column(children: <Widget>[
                          _HistoryAndSeeAllWidget(),
                          Container(
                              height: PsDimens.space180,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.historyList.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (provider.historyList.status ==
                                        PsStatus.BLOCK_LOADING) {
                                      return Shimmer.fromColors(
                                          baseColor: Colors.grey[300],
                                          highlightColor: Colors.white,
                                          child: Row(children: const <Widget>[
                                            PsFrameUIForLoading(),
                                          ]));
                                    } else {
                                      return HistoryHorizontalListItem(
                                        animationController:
                                            widget.animationController,
                                        animation: widget.animation,
                                        history: provider
                                            .historyList.data.reversed
                                            .toList()[index],
                                        onTap: () {
                                          final Item item = provider
                                              .historyList.data.reversed
                                              .toList()[index];
                                          final ItemDetailIntentHolder holder =
                                              ItemDetailIntentHolder(
                                            item: item,
                                            heroTagImage:
                                                provider.hashCode.toString() +
                                                    item.id +
                                                    PsConst.HERO_TAG__IMAGE,
                                            heroTagTitle:
                                                provider.hashCode.toString() +
                                                    item.id +
                                                    PsConst.HERO_TAG__TITLE,
                                            heroTagOriginalPrice: provider
                                                    .hashCode
                                                    .toString() +
                                                item.id +
                                                PsConst
                                                    .HERO_TAG__ORIGINAL_PRICE,
                                            heroTagUnitPrice: provider.hashCode
                                                    .toString() +
                                                item.id +
                                                PsConst.HERO_TAG__UNIT_PRICE,
                                          );

                                          Navigator.pushNamed(
                                              context, RoutePaths.itemDetail,
                                              arguments: holder);
                                        },
                                      );
                                    }
                                  }))
                        ])
                      : Container(),
                  builder: (BuildContext context, Widget child) {
                    return FadeTransition(
                        opacity: widget.animation,
                        child: Transform(
                            transform: Matrix4.translationValues(
                                0.0, 100 * (1.0 - widget.animation.value), 0.0),
                            child: child));
                  });
            } else {
              return Container();
            }
          },
        ));
  }
}

class _HistoryAndSeeAllWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutePaths.historyList,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(Utils.getString(context, 'profile__history'),
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle1),
            InkWell(
              child: Text(
                Utils.getString(context, 'profile__view_all'),
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: PsColors.mainColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
