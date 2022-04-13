import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:core';
import 'package:get/get.dart';
import 'package:flutter_starter/ui/auth/auth.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:flutter_starter/helpers/helpers.dart';

class SignInUI extends StatefulWidget {
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode nameFocusNode;

  const SignInUI({
    Key? key,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.nameFocusNode
  }) : super(key: key);

  @override
  SignInUIState createState() => SignInUIState();
}

class SignInUIState extends State<SignInUI> {
  final AuthController authController = AuthController.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _loginButtonPressed() async {
    String authCode = await AuthCodeClient.instance.request();
    var isKakaoInstalled = await isKakaoTalkInstalled();
    var tokenManager = DefaultTokenManager();

    if (isKakaoInstalled) {
      authCode = await AuthCodeClient.instance.requestWithTalk();
    } else {
      authCode = await AuthCodeClient.instance.request();
      var token = await AuthApi.instance.issueAccessToken(authCode);
      tokenManager.setToken(token);
      print(token);
    }

    print(authCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LogoGraphicHeader(),
                  SizedBox(height: 48.0),
                  CustomFormField(
                    controller: authController.emailController,
                    focusNode: widget.emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    validator: (value) => Validator.email(
                      email: value,
                    ),
                    label: 'Email',
                    hint: 'Enter your email',
                  ),
                  FormVerticalSpace(),
                  CustomFormField(
                    controller: authController.passwordController,
                    focusNode: widget.passwordFocusNode,
                    keyboardType: TextInputType.text,
                    inputAction: TextInputAction.done,
                    validator: (value) => Validator.password(
                      password: value,
                    ),
                    isObscure: true,
                    label: 'Password',
                    hint: 'Enter your password',
                  ),
                  FormVerticalSpace(),
                  PrimaryButton(
                      labelText: 'auth.signInButton'.tr,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          authController.signInWithEmailAndPassword(context);
                        }
                      }),
                  ElevatedButton(
                    onPressed: _loginButtonPressed,
                    style: ElevatedButton.styleFrom(primary: Colors.yellow),
                    child:

                    Text("카카오톡 로그인", style: TextStyle(color: Colors.black)),

                  ),
                  FormVerticalSpace(),
                  LabelButton(
                    labelText: 'auth.resetPasswordLabelButton'.tr,
                    onPressed: () => Get.to(ResetPasswordUI()),
                  ),
                  LabelButton(
                    labelText: 'auth.signUpLabelButton'.tr,
                    onPressed: () => Get.to(SignUpUI()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}