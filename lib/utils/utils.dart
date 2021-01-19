import 'dart:collection';
import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttermulticity/api/common/ps_resource.dart';
import 'package:fluttermulticity/config/ps_config.dart';
import 'package:fluttermulticity/constant/ps_constants.dart';
import 'package:fluttermulticity/constant/route_paths.dart';
import 'package:fluttermulticity/db/common/ps_shared_preferences.dart';
import 'package:fluttermulticity/provider/common/notification_provider.dart';
import 'package:fluttermulticity/ui/common/dialog/chat_noti_dialog.dart';
import 'package:fluttermulticity/ui/common/dialog/noti_dialog.dart';
import 'package:fluttermulticity/viewobject/common/ps_object.dart';
import 'package:fluttermulticity/viewobject/common/ps_value_holder.dart';
import 'package:fluttermulticity/viewobject/holder/noti_register_holder.dart';
import 'package:fluttermulticity/viewobject/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  Utils._();

  static String getString(BuildContext context, String key) {
    if (key != '') {
      return tr(key) ?? '';
    } else {
      return '';
    }
  }

  static bool checkEmailFormat(String email) {
    bool emailFormat;
    if (email != '') {
      emailFormat = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
    }
    return emailFormat;
  }

  static DateTime previous;
  static void psPrint(String msg) {
    final DateTime now = DateTime.now();
    int min = 0;
    if (previous == null) {
      previous = now;
    } else {
      min = now.difference(previous).inMilliseconds;
      previous = now;
    }

    print('$now ($min)- $msg');
  }

  static String getPriceFormat(String price) {
    return PsConst.psFormat.format(double.parse(price));
  }

  static String getPriceTwoDecimal(String price) {
    return PsConst.priceTwoDecimalFormat.format(double.parse(price));
  }

  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static String getDateFormat(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return DateFormat(PsConfig.dateFormat).format(date);
  }

  static String getTimeOfDayformat(TimeOfDay tod) {
    final DateTime now = DateTime.now();
    final DateTime dt =
        DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final DateFormat format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static String convertColorToString(Color color) {
    String convertedColorString = '';

    String colorString = color.toString().toUpperCase();

    colorString = colorString.replaceAll(')', '');

    convertedColorString = colorString.substring(colorString.length - 6);

    return '#' + convertedColorString;
  }

  static Future<bool> requestWritePermission() async {
    final Permission _storage = Permission.storage;
    final PermissionStatus permissionss = await _storage.request();

    if (permissionss != null && permissionss == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<File> getImageFileFromAssets(Asset asset, int imageSize) async {
    final int imageWidth = imageSize;

    final ByteData byteData = await asset.getByteData(quality: 80);

    final bool status = await Utils.requestWritePermission();

    if (status) {
      final Directory _appTempDir = await getTemporaryDirectory();

      final Directory _appTempDirFolder =
          Directory('${_appTempDir.path}/${PsConfig.tmpImageFolderName}');

      if (!_appTempDirFolder.existsSync()) {
        await _appTempDirFolder.create(recursive: true);
      }
      final File file = File('${_appTempDirFolder.path}/${asset.name}');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      print(file.path);
      final ImageProperties properties =
          await FlutterNativeImage.getImageProperties(file.path);
      final File compressedFile = await FlutterNativeImage.compressImage(
          file.path,
          quality: 80,
          targetWidth: imageWidth,
          targetHeight:
              (properties.height * imageWidth / properties.width).round());

      final ImageProperties properties2 =
          await FlutterNativeImage.getImageProperties(compressedFile.path);
      print('width : ${properties2.width}');
      return compressedFile;
    } else {
      // Toast
      // We don't have permission to read/write images.
      Fluttertoast.showToast(
          msg: 'We don\'t have permission to read/write images.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white);
      return null;
    }

    // });
    // return null;
  }

  static Brightness getBrightnessForAppBar(BuildContext context) {
    if (Platform.isAndroid) {
      return Brightness.dark;
    } else {
      return Theme.of(context).brightness;
    }
  }

  static dynamic getBannerAdUnitId() {
    if (Platform.isIOS) {
      return PsConfig.iosAdMobUnitIdApiKey;
    } else {
      return PsConfig.androidAdMobUnitIdApiKey;
    }
  }

  static dynamic getAdAppId() {
    if (Platform.isIOS) {
      return PsConfig.iosAdMobAdsIdKey;
    } else {
      return PsConfig.androidAdMobAdsIdKey;
    }
  }

  static int getTimeStampDividedByOneThousand(DateTime dateTime) {
    final double dividedByOneThousand = dateTime.millisecondsSinceEpoch / 1000;
    final int doubleToInt = dividedByOneThousand.round();
    return doubleToInt;
  }

  static Future<bool> checkInternetConnectivity() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult == ConnectivityResult.none) {
      print('No Connection');
      return false;
    } else {
      return false;
    }
  }

  static dynamic launchURL() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.packageName);
    final String url =
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static dynamic launchAppStoreURL(
      {String iOSAppId, bool writeReview = false}) async {
    LaunchReview.launch(writeReview: writeReview, iOSAppId: iOSAppId);
  }

  static dynamic navigateOnUserVerificationView(
      BuildContext context, Function onLoginSuccess) async {
    PsValueHolder psValueHolder =
        Provider.of<PsValueHolder>(context, listen: false);

    if (psValueHolder == null ||
        psValueHolder.userIdToVerify == null ||
        psValueHolder.userIdToVerify == '') {
      if (psValueHolder == null ||
          psValueHolder == null ||
          psValueHolder.loginUserId == null ||
          psValueHolder.loginUserId == '') {
        final dynamic returnData = await Navigator.pushNamed(
          context,
          RoutePaths.login_container,
        );

        if (returnData != null && returnData is User) {
          final User user = returnData;
          psValueHolder = Provider.of<PsValueHolder>(context, listen: false);
          psValueHolder.loginUserId = user.userId;
        }
      } else {
        onLoginSuccess();
      }
    } else {
      Navigator.pushNamed(context, RoutePaths.user_verify_email_container,
          arguments: psValueHolder.userIdToVerify);
    }
  }

  static String checkUserLoginId(PsValueHolder psValueHolder) {
    if (psValueHolder.loginUserId == null || psValueHolder.loginUserId == '') {
      return 'nologinuser';
    } else {
      return psValueHolder.loginUserId;
    }
  }

  // static String checkUserLoginId2(PsValueHolder psValueHolder) {
  //   if (psValueHolder.loginUserId == null) {
  //     return 'nologinuser';
  //   } else {
  //     return psValueHolder.loginUserId;
  //   }
  // }

  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  static PsResource<List<T>> removeDuplicateObj<T>(
      PsResource<List<T>> resource) {
    final Map<String, String> _keyMap = HashMap<String, String>();
    final List<T> _tmpDataList = <T>[];

    if (resource != null && resource.data != null) {
      for (T obj in resource.data) {
        if (obj is PsObject) {
          final String _primaryKey = obj.getPrimaryKey();

          if (!_keyMap.containsKey(_primaryKey)) {
            _keyMap[_primaryKey] = _primaryKey;
            _tmpDataList.add(obj);
          }
        }
      }
    }

    resource.data = _tmpDataList;

    return resource;
  }

  static int isAppleSignInAvailable = 0;
  static Future<void> checkAppleSignInAvailable() async {
    final bool _isAvailable = await AppleSignIn.isAvailable();

    isAppleSignInAvailable = _isAvailable ? 1 : 2;
  }

  // static Future<void> _onSelectNotification(
  //     BuildContext context, String payload) async {
  //   if (context != null) {
  //     showDialog<dynamic>(
  //         context: context,
  //         builder: (_) {
  //           return ChatNotiDialog(
  //               description: '$payload',
  //               leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
  //               rightButtonText: Utils.getString(context, 'chat_noti__open'),
  //               onAgreeTap: () {
  //                 Navigator.pushNamed(
  //                   context,
  //                   RoutePaths.notiList,
  //                 );
  //               });
  //         });
  //   }
  // }

  static Future<void> _onSelectBroadCastNotification(
      BuildContext context, String payload) async {
    if (context != null) {
      showDialog<dynamic>(
          context: context,
          builder: (_) {
            return ChatNotiDialog(
                description: '$payload',
                leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
                rightButtonText: Utils.getString(context, 'chat_noti__open'),
                onAgreeTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.notiList,
                  );
                });
          });
    }
  }

  static Future<void> _onSelectApprovalNotification(
      BuildContext context, String payload) async {
    if (context != null) {
      showDialog<dynamic>(
          context: context,
          builder: (_) {
            return NotiDialog(message: '$payload');
          });
    }
  }

  static void subscribeToTopic(bool isEnable) {
    if (isEnable) {
      final FirebaseMessaging _fcm = FirebaseMessaging();
      if (Platform.isIOS) {
        _fcm.requestNotificationPermissions(const IosNotificationSettings());
      }
      _fcm.subscribeToTopic('broadcast');
    }
  }

  static void fcmConfigure(
      BuildContext context, FirebaseMessaging _fcm, String loginUserId) {
    // final FirebaseMessaging _fcm = FirebaseMessaging();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(const IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');

        final String notiMessage = _parseNotiMessage(message);

        //_onSelectNotification(context, notiMessage);
        Utils.takeDataFromNoti(context, message, loginUserId);

        PsSharedPreferences.instance.replaceNotiMessage(
          notiMessage,
        );
      },
      //onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');

        final String notiMessage = _parseNotiMessage(message);

        //_onSelectNotification(context, notiMessage);
        Utils.takeDataFromNoti(context, message, loginUserId);

        PsSharedPreferences.instance.replaceNotiMessage(
          notiMessage,
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');

        final String notiMessage = _parseNotiMessage(message);

        // _onSelectNotification(context, notiMessage);
        Utils.takeDataFromNoti(context, message, loginUserId);

        PsSharedPreferences.instance.replaceNotiMessage(
          notiMessage,
        );
      },
    );
  }

  static String _parseNotiMessage(Map<String, dynamic> message) {
    final dynamic data = message['notification'] ?? message;
    String notiMessage = '';
    if (Platform.isAndroid) {
      notiMessage = message['data']['message'];
      notiMessage ??= '';
    } else if (Platform.isIOS) {
      notiMessage = data['body'];
      notiMessage ??= data['message'];
      notiMessage ??= '';
    }
    return notiMessage;
  }

  static dynamic takeDataFromNoti(
      BuildContext context, Map<String, dynamic> message, String loginUserId) {
    final dynamic data = message['notification'] ?? message;
    if (Platform.isAndroid) {
      final String flag = message['data']['flag']; //backend flag
      final String notiMessage = message['data']['message'];

      if (flag == 'broadcast') {
        _onSelectBroadCastNotification(context, notiMessage);
      } else if (flag == 'approval') {
        _onSelectApprovalNotification(context, notiMessage);
      }
    } else if (Platform.isIOS) {
      final String flag = data['flag'];
      String notiMessage = data['body'];
      notiMessage ??= data['message'];
      notiMessage ??= '';

      if (flag == 'broadcast') {
        _onSelectBroadCastNotification(context, notiMessage);
      } else if (flag == 'approval') {
        _onSelectApprovalNotification(context, notiMessage);
      }
    }
  }

  static Future<void> saveDeviceToken(
      FirebaseMessaging _fcm, NotificationProvider notificationProvider) async {
    // Get the token for this device
    final String fcmToken = await _fcm.getToken();
    await notificationProvider.replaceNotiToken(fcmToken);

    final NotiRegisterParameterHolder notiRegisterParameterHolder =
        NotiRegisterParameterHolder(
            platformName: PsConst.PLATFORM,
            deviceId: fcmToken,
            loginUserId:
                Utils.checkUserLoginId(notificationProvider.psValueHolder));
    print('Token Key $fcmToken');
    if (fcmToken != null) {
      await notificationProvider
          .rawRegisterNotiToken(notiRegisterParameterHolder.toMap());
    }
    return true;
  }
}
