import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:fluttermulticity/config/ps_colors.dart';
import 'package:fluttermulticity/config/ps_config.dart';
import 'package:fluttermulticity/constant/ps_constants.dart';
import 'package:fluttermulticity/provider/blog/blog_provider.dart';
import 'package:fluttermulticity/provider/city/city_provider.dart';
import 'package:fluttermulticity/provider/city/popular_city_provider.dart';
import 'package:fluttermulticity/provider/city/recommanded_city_provider.dart';
import 'package:fluttermulticity/provider/item/discount_item_provider.dart';
import 'package:fluttermulticity/provider/item/feature_item_provider.dart';
import 'package:fluttermulticity/provider/item/search_item_provider.dart';
import 'package:fluttermulticity/provider/item/trending_item_provider.dart';
import 'package:fluttermulticity/repository/blog_repository.dart';
import 'package:fluttermulticity/repository/city_repository.dart';
import 'package:fluttermulticity/repository/item_collection_repository.dart';
import 'package:fluttermulticity/ui/city/item/city_horizontal_list_item.dart';
import 'package:fluttermulticity/ui/city/item/popular_city_horizontal_list_item.dart';
import 'package:fluttermulticity/ui/common/ps_admob_banner_widget.dart';
import 'package:fluttermulticity/ui/common/ps_frame_loading_widget.dart';
import 'package:fluttermulticity/ui/common/dialog/noti_dialog.dart';
import 'package:fluttermulticity/ui/common/ps_textfield_widget_with_icon.dart';
import 'package:fluttermulticity/ui/dashboard/home/blog_slider.dart';
import 'package:fluttermulticity/ui/items/item/item_horizontal_list_item.dart';
import 'package:fluttermulticity/utils/utils.dart';
import 'package:fluttermulticity/viewobject/blog.dart';
import 'package:fluttermulticity/viewobject/city.dart';
import 'package:fluttermulticity/viewobject/common/ps_value_holder.dart';
import 'package:fluttermulticity/viewobject/holder/city_parameter_holder.dart';
import 'package:fluttermulticity/viewobject/holder/intent_holder/city_intent_holder.dart';
import 'package:fluttermulticity/viewobject/holder/intent_holder/item_detail_intent_holder.dart';
import 'package:fluttermulticity/viewobject/holder/intent_holder/item_list_intent_holder.dart';
import 'package:fluttermulticity/viewobject/holder/item_parameter_holder.dart';
import 'package:fluttermulticity/viewobject/item.dart';
import 'package:flutter/material.dart';
import 'package:fluttermulticity/viewobject/item_collection_header.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttermulticity/api/common/ps_status.dart';
import 'package:fluttermulticity/constant/ps_dimens.dart';
import 'package:fluttermulticity/constant/route_paths.dart';
import 'package:fluttermulticity/repository/category_repository.dart';
import 'package:fluttermulticity/repository/item_repository.dart';

class HomeDashboardViewWidget extends StatefulWidget {
  const HomeDashboardViewWidget(
      this._scrollController,
      this.animationController,
      this.context,
      this.animationControllerForFab,
      this.onNotiClicked);

  final ScrollController _scrollController;
  final AnimationController animationController;
  final AnimationController animationControllerForFab;
  final BuildContext context;

  final Function onNotiClicked;

  @override
  _HomeDashboardViewWidgetState createState() =>
      _HomeDashboardViewWidgetState();
}

class _HomeDashboardViewWidgetState extends State<HomeDashboardViewWidget> {
  PsValueHolder valueHolder;
  CategoryRepository categoryRepo;
  ItemRepository itemRepo;
  CityRepository cityRepo;
  BlogRepository blogRepo;
  ItemCollectionRepository itemCollectionRepo;
  BlogProvider _blogProvider;
  SearchItemProvider _searchItemProvider;
  TrendingItemProvider _trendingItemProvider;
  FeaturedItemProvider _featuredItemProvider;
  DiscountItemProvider _discountItemProvider;
  PopularCityProvider _popularCityProvider;
  CityProvider _cityProvider;
  RecommandedCityProvider _recommandedCityProvider;

  final int count = 8;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onSelectNotification(String payload) async {
    if (context == null) {
      widget.onNotiClicked(payload);
    } else {
      return showDialog<dynamic>(
        context: context,
        builder: (_) {
          return NotiDialog(message: '$payload');
        },
      );
    }
  }

  final TextEditingController userInputItemNameTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    categoryRepo = Provider.of<CategoryRepository>(context);
    itemRepo = Provider.of<ItemRepository>(context);
    cityRepo = Provider.of<CityRepository>(context);
    blogRepo = Provider.of<BlogRepository>(context);
    itemCollectionRepo = Provider.of<ItemCollectionRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<BlogProvider>(
              lazy: false,
              create: (BuildContext context) {
                _blogProvider = BlogProvider(
                    repo: blogRepo, limit: PsConfig.BLOG_ITEM_LOADING_LIMIT);
                _blogProvider.loadBlogList();

                return _blogProvider;
              }),
          ChangeNotifierProvider<SearchItemProvider>(
              lazy: false,
              create: (BuildContext context) {
                _searchItemProvider = SearchItemProvider(
                    repo: itemRepo,
                    limit: PsConfig.LATEST_PRODUCT_LOADING_LIMIT);
                _searchItemProvider.loadItemListByKey(
                    ItemParameterHolder().getLatestParameterHolder());
                return _searchItemProvider;
              }),
          ChangeNotifierProvider<TrendingItemProvider>(
              lazy: false,
              create: (BuildContext context) {
                _trendingItemProvider = TrendingItemProvider(
                    repo: itemRepo,
                    limit: PsConfig.TRENDING_PRODUCT_LOADING_LIMIT);
                _trendingItemProvider.loadItemList(PsConst.PROPULAR_ITEM_COUNT,
                    ItemParameterHolder().getTrendingParameterHolder());
                return _trendingItemProvider;
              }),
          ChangeNotifierProvider<FeaturedItemProvider>(
              lazy: false,
              create: (BuildContext context) {
                _featuredItemProvider = FeaturedItemProvider(
                    repo: itemRepo,
                    limit: PsConfig.FEATURE_PRODUCT_LOADING_LIMIT);
                _featuredItemProvider.loadItemList(
                    ItemParameterHolder().getFeaturedParameterHolder());
                return _featuredItemProvider;
              }),
          ChangeNotifierProvider<DiscountItemProvider>(
              lazy: false,
              create: (BuildContext context) {
                _discountItemProvider = DiscountItemProvider(
                    repo: itemRepo,
                    limit: PsConfig.DISCOUNT_PRODUCT_LOADING_LIMIT);
                _discountItemProvider.loadItemList(
                    ItemParameterHolder().getDiscountParameterHolder());
                return _discountItemProvider;
              }),
          ChangeNotifierProvider<PopularCityProvider>(
              lazy: false,
              create: (BuildContext context) {
                _popularCityProvider = PopularCityProvider(
                    repo: cityRepo, limit: PsConfig.POPULAR_CITY_LOADING_LIMIT);
                _popularCityProvider.loadPopularCityList();

                return _popularCityProvider;
              }),
          ChangeNotifierProvider<CityProvider>(
              lazy: false,
              create: (BuildContext context) {
                _cityProvider = CityProvider(
                    repo: cityRepo, limit: PsConfig.NEW_CITY_LOADING_LIMIT);
                _cityProvider
                    .loadCityListByKey(CityParameterHolder().getRecentCities());
                return _cityProvider;
              }),
          ChangeNotifierProvider<RecommandedCityProvider>(
              lazy: false,
              create: (BuildContext context) {
                _recommandedCityProvider = RecommandedCityProvider(
                    repo: cityRepo,
                    limit: PsConfig.RECOMMAND_CITY_LOADING_LIMIT);
                _recommandedCityProvider.loadRecommandedCityList();
                return _recommandedCityProvider;
              }),
        ],
        child: Scaffold(
            body: Container(
          color: PsColors.coreBackgroundColor,
          child: RefreshIndicator(
            onRefresh: () {
              _blogProvider.resetBlogList();
              _searchItemProvider.resetLatestItemList(
                  ItemParameterHolder().getLatestParameterHolder());
              _trendingItemProvider.resetTrendingItemList(
                  ItemParameterHolder().getTrendingParameterHolder());
              _featuredItemProvider.resetFeatureItemList(
                  ItemParameterHolder().getFeaturedParameterHolder());
              _discountItemProvider.resetDiscountItemList(
                  ItemParameterHolder().getDiscountParameterHolder());
              _popularCityProvider.resetPopularCityList();
              _cityProvider
                  .resetCityListByKey(CityParameterHolder().getRecentCities());
              return _recommandedCityProvider.resetRecommandedCityList();
            },
            child: CustomScrollView(
              controller: widget._scrollController,
              scrollDirection: Axis.vertical,
              slivers: <Widget>[
                _MyHomeHeaderWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 1, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  userInputItemNameTextEditingController:
                      userInputItemNameTextEditingController,
                  psValueHolder: valueHolder, //animation
                ),
                _HomeFeaturedItemHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 3, 1.0,
                              curve: Curves.fastOutSlowIn))),
                ),
                _HomePopularCityHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 2, 1.0,
                              curve: Curves.fastOutSlowIn))),
                ),
                _HomeRecommandedCityHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                ),
                _HomeNewCityHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 6, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),
                _HomeBlogSliderWidget(
                  animationController: widget.animationController,

                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 7, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),
                _HomeTrendingItemHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 5, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),
                _HomeNewPlaceHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),
                _HomeOnPromotionHorizontalListWidget(
                  animationController: widget.animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 3, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),
              ],
            ),
          ),
        )));
  }
}

class _HomeFeaturedItemHorizontalListWidget extends StatefulWidget {
  const _HomeFeaturedItemHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeFeaturedItemHorizontalListWidgetState createState() =>
      __HomeFeaturedItemHorizontalListWidgetState();
}

class __HomeFeaturedItemHorizontalListWidgetState
    extends State<_HomeFeaturedItemHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<FeaturedItemProvider>(
        builder: (BuildContext context, FeaturedItemProvider itemProvider,
            Widget child) {
          return AnimatedBuilder(
            animation: widget.animationController,
            child: (itemProvider.itemList.data != null &&
                    itemProvider.itemList.data.isNotEmpty)
                ? Column(
                    children: <Widget>[
                      _MyHeaderWidget(
                        headerName:
                            Utils.getString(context, 'dashboard__feature_item'),
                        viewAllClicked: () {
                          Navigator.pushNamed(
                              context, RoutePaths.filterItemList,
                              arguments: ItemListIntentHolder(
                                  checkPage: '0',
                                  appBarTitle: Utils.getString(
                                      context, 'dashboard__feature_item'),
                                  itemParameterHolder: ItemParameterHolder()
                                      .getFeaturedParameterHolder()));
                        },
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: PsDimens.space16),
                        child: Text(
                          Utils.getString(
                              context, 'dashboard__feature_item_description'),
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Container(
                          height: PsDimens.space300,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.only(left: PsDimens.space16),
                              itemCount: itemProvider.itemList.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (itemProvider.itemList.status ==
                                    PsStatus.BLOCK_LOADING) {
                                  return Shimmer.fromColors(
                                      baseColor: PsColors.grey,
                                      highlightColor: PsColors.white,
                                      child: Row(children: const <Widget>[
                                        PsFrameUIForLoading(),
                                      ]));
                                } else {
                                  final Item item =
                                      itemProvider.itemList.data[index];
                                  return ItemHorizontalListItem(
                                    coreTagKey:
                                        itemProvider.hashCode.toString() +
                                            item.id, //'feature',
                                    item: itemProvider.itemList.data[index],
                                    onTap: () async {
                                      print(itemProvider.itemList.data[index]
                                          .defaultPhoto.imgPath);
                                      final ItemDetailIntentHolder holder =
                                          ItemDetailIntentHolder(
                                        item: itemProvider.itemList.data[index],
                                        heroTagImage: '',
                                        heroTagTitle: '',
                                        heroTagOriginalPrice: '',
                                        heroTagUnitPrice: '',
                                      );

                                      final dynamic result =
                                          await Navigator.pushNamed(
                                              context, RoutePaths.itemDetail,
                                              arguments: holder);
                                      if (result == null) {
                                        setState(() {
                                          itemProvider.resetFeatureItemList(
                                              ItemParameterHolder()
                                                  .getFeaturedParameterHolder());
                                        });
                                      }
                                    },
                                  );
                                }
                              }))
                    ],
                  )
                : Container(),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - widget.animation.value), 0.0),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeNewCityHorizontalListWidget extends StatefulWidget {
  const _HomeNewCityHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeNewCityHorizontalListWidgetState createState() =>
      __HomeNewCityHorizontalListWidgetState();
}

class __HomeNewCityHorizontalListWidgetState
    extends State<_HomeNewCityHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<CityProvider>(
        builder:
            (BuildContext context, CityProvider cityProvider, Widget child) {
          return AnimatedBuilder(
              animation: widget.animationController,
              child: Column(children: <Widget>[
                _MyHeaderWidget(
                  headerName:
                      Utils.getString(context, 'dashboard__latest_city'),
                  viewAllClicked: () {
                    Navigator.pushNamed(context, RoutePaths.citySearch,
                        arguments: CityIntentHolder(
                          appBarTitle: Utils.getString(
                              context, 'dashboard__latest_city'),
                          cityParameterHolder:
                              CityParameterHolder().getRecentCities(),
                        ));
                  },
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: PsDimens.space16),
                  child: Text(
                    Utils.getString(
                        context, 'dashboard__latest_city_description'),
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Container(
                    height: PsDimens.space320,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: PsDimens.space16),
                        itemCount: cityProvider.cityList.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (cityProvider.cityList.status ==
                              PsStatus.BLOCK_LOADING) {
                            return Shimmer.fromColors(
                                baseColor: PsColors.grey,
                                highlightColor: PsColors.white,
                                child: Row(children: const <Widget>[
                                  PsFrameUIForLoading(),
                                ]));
                          } else {
                            final City city = cityProvider.cityList.data[index];

                            return CityHorizontalListItem(
                              coreTagKey: cityProvider.hashCode.toString() +
                                  city.id, //'latest',
                              city: city,
                              onTap: () async {
                                cityProvider.replaceCityInfoData(
                                  cityProvider.cityList.data[index].id,
                                  cityProvider.cityList.data[index].name,
                                  cityProvider.cityList.data[index].lat,
                                  cityProvider.cityList.data[index].lng,
                                );
                                Navigator.pushNamed(
                                  context,
                                  RoutePaths.itemHome,
                                  arguments: city,
                                );
                              },
                            );
                          }
                        }))
              ]),
              // : Container(),
              builder: (BuildContext context, Widget child) {
                if (cityProvider.cityList.data != null &&
                    cityProvider.cityList.data.isNotEmpty) {
                  return FadeTransition(
                    opacity: widget.animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - widget.animation.value), 0.0),
                      child: child,
                    ),
                  );
                } else {
                  return Container();
                }
              });
        },
      ),
    );
  }
}

class _HomeBlogSliderWidget extends StatelessWidget {
  const _HomeBlogSliderWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // const int count = 5;
    // final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
    //     .animate(CurvedAnimation(
    //         parent: animationController,
    //         curve: const Interval((1 / count) * 1, 1.0,
    //             curve: Curves.fastOutSlowIn)));

    return SliverToBoxAdapter(
      child: Consumer<BlogProvider>(builder:
          (BuildContext context, BlogProvider blogProvider, Widget child) {
        return AnimatedBuilder(
            animation: animationController,
            child: (blogProvider.blogList != null &&
                    blogProvider.blogList.data.isNotEmpty)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _MyHeaderWidget(
                        headerName:
                            Utils.getString(context, 'dashboard__blog_item'),
                        viewAllClicked: () {
                          Navigator.pushNamed(
                            context,
                            RoutePaths.blogList,
                          );
                        },
                      ),
                      Container(
                        // decoration: BoxDecoration(
                        //   boxShadow: <BoxShadow>[
                        //     BoxShadow(
                        //         color: PsColors.mainLightShadowColor,
                        //         offset: const Offset(1.1, 1.1),
                        //         blurRadius: PsDimens.space8),
                        //   ],
                        // ),
                        // margin: const EdgeInsets.only(
                        //     top: PsDimens.space8,
                        //     bottom: PsDimens.space20),
                        width: double.infinity,
                        child: BlogSliderView(
                          blogList: blogProvider.blogList.data,
                          onTap: (Blog blog) {
                            Navigator.pushNamed(
                              context,
                              RoutePaths.blogDetail,
                              arguments: blog,
                            );
                          },
                        ),
                      ),
                      // const PsAdMobBannerWidget(),
                    ],
                  )
                : Container(),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - animation.value), 0.0),
                    child: child,
                  ));
            });
      }),
    );
  }
}

class _HomeRecommandedCityHorizontalListWidget extends StatefulWidget {
  const _HomeRecommandedCityHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeRecommandedCityHorizontalListWidgetState createState() =>
      __HomeRecommandedCityHorizontalListWidgetState();
}

class __HomeRecommandedCityHorizontalListWidgetState
    extends State<_HomeRecommandedCityHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<RecommandedCityProvider>(
        builder: (BuildContext context, RecommandedCityProvider provider,
            Widget child) {
          return AnimatedBuilder(
            animation: widget.animationController,
            child: (provider.recommandedCityList.data != null &&
                    provider.recommandedCityList.data.isNotEmpty)
                ? Column(
                    children: <Widget>[
                      Container(
                        color: Utils.isLightMode(context)
                            ? Colors.yellow[50]
                            : Colors.black12,
                        child: Column(
                          children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__promotion_city'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.citySearch,
                                    arguments: CityIntentHolder(
                                        appBarTitle: Utils.getString(context,
                                            'dashboard__promotion_city'),
                                        cityParameterHolder:
                                            CityParameterHolder()
                                                .getFeaturedCities()));
                              },
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.only(left: PsDimens.space16),
                              child: Text(
                                Utils.getString(context,
                                    'dashboard__promotion_city_description'),
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Container(
                                height: PsDimens.space300,
                                color: Utils.isLightMode(context)
                                    ? Colors.yellow[50]
                                    : Colors.black12,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    itemCount: provider
                                        .recommandedCityList.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (provider.recommandedCityList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        final City item = provider
                                            .recommandedCityList.data[index];
                                        return CityHorizontalListItem(
                                          coreTagKey:
                                              provider.hashCode.toString() +
                                                  item.id, //'feature',
                                          city: provider
                                              .recommandedCityList.data[index],
                                          onTap: () async {
                                            provider.replaceCityInfoData(
                                              provider.recommandedCityList
                                                  .data[index].id,
                                              provider.recommandedCityList
                                                  .data[index].name,
                                              provider.recommandedCityList
                                                  .data[index].lat,
                                              provider.recommandedCityList
                                                  .data[index].lng,
                                            );
                                            Navigator.pushNamed(
                                              context,
                                              RoutePaths.itemHome,
                                              arguments: provider
                                                  .recommandedCityList
                                                  .data[index],
                                            );
                                          },
                                        );
                                      }
                                    }))
                          ],
                        ),
                      ),
                      // const PsAdMobBannerWidget(),
                    ],
                  )
                : Container(),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - widget.animation.value), 0.0),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeTrendingItemHorizontalListWidget extends StatefulWidget {
  const _HomeTrendingItemHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeTrendingItemHorizontalListWidgetState createState() =>
      __HomeTrendingItemHorizontalListWidgetState();
}

class __HomeTrendingItemHorizontalListWidgetState
    extends State<_HomeTrendingItemHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<TrendingItemProvider>(
        builder: (BuildContext context, TrendingItemProvider itemProvider,
            Widget child) {
          return AnimatedBuilder(
            animation: widget.animationController,
            child: (itemProvider.itemList.data != null &&
                    itemProvider.itemList.data.isNotEmpty)
                ? Column(
                    children: <Widget>[
                      _MyHeaderWidget(
                        headerName: Utils.getString(
                            context, 'dashboard__trending_item'),
                        viewAllClicked: () {
                          Navigator.pushNamed(
                              context, RoutePaths.filterItemList,
                              arguments: ItemListIntentHolder(
                                  checkPage: '0',
                                  appBarTitle: Utils.getString(
                                      context, 'dashboard__trending_item'),
                                  itemParameterHolder: ItemParameterHolder()
                                      .getTrendingParameterHolder()));
                        },
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: PsDimens.space16),
                        child: Text(
                          Utils.getString(
                              context, 'dashboard__trending_item_description'),
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Container(
                        height: PsDimens.space320,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.only(left: PsDimens.space16),
                            itemCount: itemProvider.itemList.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (itemProvider.itemList.status ==
                                  PsStatus.BLOCK_LOADING) {
                                return Shimmer.fromColors(
                                    baseColor: PsColors.grey,
                                    highlightColor: PsColors.white,
                                    child: Row(children: const <Widget>[
                                      PsFrameUIForLoading(),
                                    ]));
                              } else {
                                final Item item =
                                    itemProvider.itemList.data[index];
                                return ItemHorizontalListItem(
                                  coreTagKey: itemProvider.hashCode.toString() +
                                      item.id,
                                  item: itemProvider.itemList.data[index],
                                  onTap: () async {
                                    print(itemProvider.itemList.data[index]
                                        .defaultPhoto.imgPath);
                                    final ItemDetailIntentHolder holder =
                                        ItemDetailIntentHolder(
                                      item: itemProvider.itemList.data[index],
                                      heroTagImage: '',
                                      heroTagTitle: '',
                                      heroTagOriginalPrice: '',
                                      heroTagUnitPrice: '',
                                    );
                                    final dynamic result =
                                        await Navigator.pushNamed(
                                            context, RoutePaths.itemDetail,
                                            arguments: holder);
                                    if (result == null) {
                                      itemProvider.resetTrendingItemList(
                                          ItemParameterHolder()
                                              .getTrendingParameterHolder());
                                    }
                                  },
                                );
                              }
                            }),
                      )
                    ],
                  )
                : Container(),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - widget.animation.value), 0.0),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeOnPromotionHorizontalListWidget extends StatefulWidget {
  const _HomeOnPromotionHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeOnPromotionHorizontalListWidgetState createState() =>
      __HomeOnPromotionHorizontalListWidgetState();
}

class __HomeOnPromotionHorizontalListWidgetState
    extends State<_HomeOnPromotionHorizontalListWidget> {
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
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    return SliverToBoxAdapter(child: Consumer<DiscountItemProvider>(builder:
        (BuildContext context, DiscountItemProvider itemProvider,
            Widget child) {
      return AnimatedBuilder(
          animation: widget.animationController,
          child: (itemProvider.itemList.data != null &&
                  itemProvider.itemList.data.isNotEmpty)
              ? Column(children: <Widget>[
                  _MyHeaderWidget(
                    headerName:
                        Utils.getString(context, 'dashboard__promotion_item'),
                    viewAllClicked: () {
                      Navigator.pushNamed(context, RoutePaths.filterItemList,
                          arguments: ItemListIntentHolder(
                              checkPage: '0',
                              appBarTitle: Utils.getString(
                                  context, 'dashboard__promotion_item'),
                              itemParameterHolder: ItemParameterHolder()
                                  .getDiscountParameterHolder()));
                    },
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: PsDimens.space16),
                    child: Text(
                      Utils.getString(
                          context, 'dashboard__promotion_item_description'),
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Container(
                      height: PsDimens.space320,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.only(left: PsDimens.space16),
                          itemCount: itemProvider.itemList.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (itemProvider.itemList.status ==
                                PsStatus.BLOCK_LOADING) {
                              return Shimmer.fromColors(
                                  baseColor: PsColors.grey,
                                  highlightColor: PsColors.white,
                                  child: Row(children: const <Widget>[
                                    PsFrameUIForLoading(),
                                  ]));
                            } else {
                              final Item item =
                                  itemProvider.itemList.data[index];
                              return ItemHorizontalListItem(
                                coreTagKey:
                                    itemProvider.hashCode.toString() + item.id,
                                item: itemProvider.itemList.data[index],
                                onTap: () async {
                                  print(itemProvider.itemList.data[index]
                                      .defaultPhoto.imgPath);
                                  final ItemDetailIntentHolder holder =
                                      ItemDetailIntentHolder(
                                    item: itemProvider.itemList.data[index],
                                    heroTagImage: '',
                                    heroTagTitle: '',
                                    heroTagOriginalPrice: '',
                                    heroTagUnitPrice: '',
                                  );
                                  final dynamic result =
                                      await Navigator.pushNamed(
                                          context, RoutePaths.itemDetail,
                                          arguments: holder);
                                  if (result == null) {
                                    itemProvider.resetDiscountItemList(
                                        ItemParameterHolder()
                                            .getDiscountParameterHolder());
                                  }
                                },
                              );
                            }
                          })),
                  const PsAdMobBannerWidget(
                    // admobBannerSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                    admobSize: NativeAdmobType.full,
                  ),
                  // Visibility(
                  //   visible: PsConfig.showAdMob &&
                  //       isSuccessfullyLoaded &&
                  //       isConnectedToInternet,
                  //   child: AdmobBanner(
                  //     adUnitId: Utils.getBannerAdUnitId(),
                  //     adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                  //     listener: (AdmobAdEvent event,
                  //         Map<String, dynamic> map) {
                  //       print('BannerAd event is $event');
                  //       if (event == AdmobAdEvent.loaded) {
                  //         isSuccessfullyLoaded = true;
                  //       } else {
                  //         isSuccessfullyLoaded = false;
                  //         setState(() {});
                  //       }
                  //     },
                  //   ),
                  // ),
                ])
              : Container(),
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - widget.animation.value), 0.0),
                  child: child,
                ));
          });
    }));
  }
}

class _MyHomeHeaderWidget extends StatefulWidget {
  const _MyHomeHeaderWidget(
      {Key key,
      @required this.animationController,
      @required this.animation,
      @required this.userInputItemNameTextEditingController,
      @required this.psValueHolder})
      : super(key: key);

  final TextEditingController userInputItemNameTextEditingController;
  final PsValueHolder psValueHolder;
  final AnimationController animationController;
  final Animation<double> animation;
  @override
  __MyHomeHeaderWidgetState createState() => __MyHomeHeaderWidgetState();
}

class __MyHomeHeaderWidgetState extends State<_MyHomeHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space8,
    );
    return SliverToBoxAdapter(
        child: AnimatedBuilder(
            animation: widget.animationController,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                  left: PsDimens.space12,
                  right: PsDimens.space12,
                  top: PsDimens.space64),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(PsDimens.space12),
              //   // color:  Colors.white54
              //   color: Utils.isLightMode(context)
              //       ? Colors.white54
              //       : Colors.black54,
              // ),
              child: Column(
                children: <Widget>[
                  _spacingWidget,
                  // _spacingWidget,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Utils.getString(context, 'app_name'),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: PsDimens.space32),
                      ),
                      _spacingWidget,
                      Container(
                        margin: const EdgeInsets.only(
                            left: PsDimens.space20,
                            right: PsDimens.space20,
                            bottom: PsDimens.space32),
                        child: Text(
                          Utils.getString(
                              context, 'dashboard__app_description'),
                          textAlign: TextAlign.right,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: PsColors.mainColor),
                        ),
                      ),
                    ],
                  ),

                  _spacingWidget,
                  PsTextFieldWidgetWithIcon(
                    hintText:
                        Utils.getString(context, 'dashboard__search_keyword'),
                    textEditingController:
                        widget.userInputItemNameTextEditingController,
                    psValueHolder: widget.psValueHolder,
                  ),
                  _spacingWidget
                ],
              ),
            ),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - widget.animation.value), 0.0),
                    child: child,
                  ));
            }));
  }
}

class _HomePopularCityHorizontalListWidget extends StatelessWidget {
  const _HomePopularCityHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<PopularCityProvider>(
        builder: (BuildContext context, PopularCityProvider popularCityProvider,
            Widget child) {
          return AnimatedBuilder(
            animation: animationController,
            child: (popularCityProvider.popularCityList.data != null &&
                    popularCityProvider.popularCityList.data.isNotEmpty)
                ? Column(children: <Widget>[
                    _MyHeaderWidget(
                      headerName:
                          Utils.getString(context, 'dashboard__popular_city'),
                      viewAllClicked: () {
                        Navigator.pushNamed(context, RoutePaths.citySearch,
                            arguments: CityIntentHolder(
                                appBarTitle: Utils.getString(
                                    context, 'dashboard__popular_city'),
                                cityParameterHolder:
                                    CityParameterHolder().getPopularCities()));
                      },
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: PsDimens.space16),
                      child: Text(
                        Utils.getString(
                            context, 'dashboard__popular_city_description'),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(PsDimens.space16),
                      child: Container(
                          height: 500,
                          width: MediaQuery.of(context).size.width,
                          child: CustomScrollView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            slivers: <Widget>[
                              SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 400,
                                          childAspectRatio: 0.9),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (popularCityProvider
                                              .popularCityList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        return PopularCityHorizontalListItem(
                                          city: popularCityProvider
                                              .popularCityList.data[index],
                                          onTap: () {
                                            popularCityProvider
                                                .replaceCityInfoData(
                                              popularCityProvider
                                                  .popularCityList
                                                  .data[index]
                                                  .id,
                                              popularCityProvider
                                                  .popularCityList
                                                  .data[index]
                                                  .name,
                                              popularCityProvider
                                                  .popularCityList
                                                  .data[index]
                                                  .lat,
                                              popularCityProvider
                                                  .popularCityList
                                                  .data[index]
                                                  .lng,
                                            );
                                            Navigator.pushNamed(
                                              context,
                                              RoutePaths.itemHome,
                                              arguments: popularCityProvider
                                                  .popularCityList.data[index],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    childCount: popularCityProvider
                                        .popularCityList.data.length,
                                  ))
                            ],
                          )),
                    )
                  ])
                : Container(),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation.value), 0.0),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeNewPlaceHorizontalListWidget extends StatefulWidget {
  const _HomeNewPlaceHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeNewPlaceHorizontalListWidgetState createState() =>
      __HomeNewPlaceHorizontalListWidgetState();
}

class __HomeNewPlaceHorizontalListWidgetState
    extends State<_HomeNewPlaceHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<SearchItemProvider>(
        builder: (BuildContext context, SearchItemProvider itemProvider,
            Widget child) {
          return AnimatedBuilder(
              animation: widget.animationController,
              child: Column(children: <Widget>[
                _MyHeaderWidget(
                  headerName:
                      Utils.getString(context, 'dashboard__popular_item'),
                  viewAllClicked: () {
                    Navigator.pushNamed(context, RoutePaths.filterItemList,
                        arguments: ItemListIntentHolder(
                          checkPage: '0',
                          appBarTitle: Utils.getString(
                              context, 'dashboard__popular_item'),
                          itemParameterHolder:
                              ItemParameterHolder().getLatestParameterHolder(),
                        ));
                  },
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: PsDimens.space16),
                  child: Text(
                    Utils.getString(
                        context, 'dashboard__popular_item_description'),
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Container(
                    height: PsDimens.space320,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: PsDimens.space16),
                        itemCount: itemProvider.itemList.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (itemProvider.itemList.status ==
                              PsStatus.BLOCK_LOADING) {
                            return Shimmer.fromColors(
                                baseColor: PsColors.grey,
                                highlightColor: PsColors.white,
                                child: Row(children: const <Widget>[
                                  PsFrameUIForLoading(),
                                ]));
                          } else {
                            final Item item = itemProvider.itemList.data[index];

                            return ItemHorizontalListItem(
                              coreTagKey: itemProvider.hashCode.toString() +
                                  item.id, //'latest',
                              item: item,
                              onTap: () async {
                                print(item.defaultPhoto.imgPath);

                                final ItemDetailIntentHolder holder =
                                    ItemDetailIntentHolder(
                                  item: item,
                                  heroTagImage: '',
                                  heroTagTitle: '',
                                  heroTagOriginalPrice: '',
                                  heroTagUnitPrice: '',
                                );

                                final dynamic result =
                                    await Navigator.pushNamed(
                                        context, RoutePaths.itemDetail,
                                        arguments: holder);
                                if (result == null) {
                                  setState(() {
                                    itemProvider.resetLatestItemList(
                                        ItemParameterHolder()
                                            .getLatestParameterHolder());
                                  });
                                }
                              },
                            );
                          }
                        }))
              ]),
              // : Container(),
              builder: (BuildContext context, Widget child) {
                if (itemProvider.itemList.data != null &&
                    itemProvider.itemList.data.isNotEmpty) {
                  return FadeTransition(
                    opacity: widget.animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - widget.animation.value), 0.0),
                      child: child,
                    ),
                  );
                } else {
                  return Container();
                }
              });
        },
      ),
    );
  }
}

class _MyHeaderWidget extends StatefulWidget {
  const _MyHeaderWidget({
    Key key,
    @required this.headerName,
    this.itemCollectionHeader,
    @required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function viewAllClicked;
  final ItemCollectionHeader itemCollectionHeader;

  @override
  __MyHeaderWidgetState createState() => __MyHeaderWidgetState();
}

class __MyHeaderWidgetState extends State<_MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.viewAllClicked();
      },
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
            Text(
              Utils.getString(context, 'dashboard__view_all'),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
