import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/auth/auth.dart';

class SignUpUI extends StatelessWidget {
  final AuthController authController = AuthController.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  get nameFocusNode => null;

  get emailFocusNode => null;

  get passwordFocusNode => null;


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
                    controller: authController.nameController,
                    focusNode: nameFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    validator: (value) => Validator.name(
                      name: value,
                    ),
                    label: 'Name',
                    hint: 'Enter your name',
                  ),
                  FormVerticalSpace(),
                  CustomFormField(
                    controller: authController.emailController,
                    focusNode: emailFocusNode,
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
                    focusNode: passwordFocusNode,
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
                      labelText: 'auth.signUpButton'.tr,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          SystemChannels.textInput.invokeMethod(
                              'TextInput.hide'); //to hide the keyboard - if any
                          authController.registerWithEmailAndPassword(context);
                        }
                      }),
                  FormVerticalSpace(),
                  LabelButton(
                    labelText: 'auth.signInLabelButton'.tr,
                    onPressed: () => Get.offAll(SignInUI(passwordFocusNode: passwordFocusNode, emailFocusNode: emailFocusNode, nameFocusNode: nameFocusNode,)),
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
