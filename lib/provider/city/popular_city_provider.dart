import 'dart:async';
import 'package:fluttermulticity/repository/city_repository.dart';
import 'package:fluttermulticity/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttermulticity/api/common/ps_resource.dart';
import 'package:fluttermulticity/api/common/ps_status.dart';
import 'package:fluttermulticity/provider/common/ps_provider.dart';
import 'package:fluttermulticity/viewobject/city.dart';
import 'package:fluttermulticity/viewobject/holder/city_parameter_holder.dart';

class PopularCityProvider extends PsProvider {
  PopularCityProvider({@required CityRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('PopularCityProvider : $hashCode');
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    popularCityListStream =
        StreamController<PsResource<List<City>>>.broadcast();

    subscription =
        popularCityListStream.stream.listen((PsResource<List<City>> resource) {
      updateOffset(resource.data.length);

      _popularCityList = Utils.removeDuplicateObj<City>(resource);

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  CityRepository _repo;
  PsResource<List<City>> _popularCityList =
      PsResource<List<City>>(PsStatus.NOACTION, '', <City>[]);

  PsResource<List<City>> get popularCityList => _popularCityList;
  StreamSubscription<PsResource<List<City>>> subscription;
  StreamController<PsResource<List<City>>> popularCityListStream;
  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('Popular Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadPopularCityList() async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getCityList(
        popularCityListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        CityParameterHolder().getPopularCities());
  }

  Future<dynamic> nextPopularCityList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo.getCityList(
          popularCityListStream,
          isConnectedToInternet,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          CityParameterHolder().getPopularCities());
    }
  }

  Future<void> resetPopularCityList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo.getCityList(
        popularCityListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        CityParameterHolder().getPopularCities());

    isLoading = false;
  }
}
