import 'package:get/get.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:flutter_starter/ui/auth/auth.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_starter/ui/auth/sign_in_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/signin', page: () => SignInUI(passwordFocusNode: passwordFocusNode, emailFocusNode: emailFocusNode, nameFocusNode: nameFocusNode,)),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => ChatScreen()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
    GetPage(name: '/user_info', page: () => HomeUI()),
    GetPage(name: '/summary_ui', page: () => ResultSummary())
  ];

  static get passwordFocusNode => null;

  static get emailFocusNode => null;

  static get nameFocusNode => null;
}
