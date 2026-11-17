import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}){
    _notification = authServiceInterface.isSharedPrefNotificationActive();
  }

  bool _notification = true;
  bool get notification => _notification;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _guestLoading = false;
  bool get guestLoading => _guestLoading;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isActiveRememberMeOtp = false;
  bool get isActiveRememberMeOtp => _isActiveRememberMeOtp;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  var countryDialCode= "+962";

  bool _isOtpViewEnable = false;
  bool get isOtpViewEnable => _isOtpViewEnable;

  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async {
    _isLoading = true;
    update();
    try {
      ResponseModel responseModel = await authServiceInterface.registration(signUpBody);
      return responseModel;
    } catch (e) {
      return ResponseModel(false, e.toString());
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<ResponseModel> login({required String emailOrPhone, required String password, required String loginType, required String fieldType, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(emailOrPhone: emailOrPhone, password: password, loginType: loginType, fieldType: fieldType, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> otpLogin({required String phone, required String loginType, required String otp, required String verified, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(phone: phone, otp: otp, loginType: loginType, verified: verified, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void resetOtpView({bool isUpdate = true}) {
    _isOtpViewEnable = false;
    if(isUpdate) {
      update();
    }
  }

  void enableOtpView({bool enable = false}) {
    _isOtpViewEnable = enable;
    update();
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> loginWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.loginWithSocialMedia(socialLogInBody, isCustomerVerificationOn: Get.find<SplashController>().configModel!.customerVerification??false);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void toggleIsNumberLogin({bool? value, bool willUpdate = true}){
    if(value == null){
      _isNumberLogin = !_isNumberLogin;
    }else{
      _isNumberLogin = value;
    }
    initCountryCode();
    if(willUpdate){
      update();
    }
  }

  Future<ResponseModel> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(name: name, phone: phone, email: email, loginType: loginType, referCode: referCode, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void _getUserAndCartData(ResponseModel responseModel) {
    if(responseModel.isSuccess && responseModel.authResponseModel != null && responseModel.authResponseModel!.isPhoneVerified!
        && responseModel.authResponseModel!.isEmailVerified! && responseModel.authResponseModel!.isPersonalInfo!
        && responseModel.authResponseModel!.isExistUser == null) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getAllCarts();
      Get.find<HomeController>().getCashBackOfferList();
    }
  }

  void initCountryCode({String? countryCode}){
    countryDialCode = countryCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country ?? "JO").dialCode ?? "+962";
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleRememberMeOtp() {
    _isActiveRememberMeOtp = !_isActiveRememberMeOtp;
    update();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  Future<void> loginWithToken(String token) async {
    await authServiceInterface.loginWithToken(token);
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn() && !authServiceInterface.isLoggedIn();
  }

  String getGuestId() {
    return authServiceInterface.getSharedPrefGuestId();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    if(!ResponsiveHelper.isDesktop(Get.context)){
      Get.find<SplashController>().setModule(null);
    }
    Get.find<ProController>().saveRenewBottomSheetStatus(false);
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  Future<bool> clearSharedAddress() async {
    return await authServiceInterface.clearSharedAddress();
  }

  Future<void> saveUserNumberAndPasswordSharedPref(String number, String password, String countryCode) async {
    await authServiceInterface.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  void saveUserNumberAndPassword(String number, String password, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(number, password, countryCode);
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  Future<void> saveOtpUserNumber(String number, String countryCode) async {
    await authServiceInterface.saveOtpUserNumber(number, countryCode);
  }

  String getOtpUserNumber() {
    return authServiceInterface.getOtpUserNumber();
  }

  String getOtpUserCountryCode() {
    return authServiceInterface.getOtpUserCountryCode();
  }

  Future<bool> clearOtpUserNumber() async {
    return await authServiceInterface.clearOtpUserNumber();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<void> updateZone() async {
    await authServiceInterface.updateZone();
  }

  Future<void> saveGuestNumber(String number) async {
    await authServiceInterface.saveGuestContactNumber(number);
  }

  String getGuestNumber() {
    return authServiceInterface.getGuestContactNumber();
  }

  Future<void> saveDmTipIndex(String i) async {
    await authServiceInterface.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return authServiceInterface.getDmTipIndex();
  }

  void saveEarningPoint(String point){
    authServiceInterface.saveEarningPoint(point);
  }

  String getEarningPint() {
    return authServiceInterface.getEarningPint();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  Future<String?> saveDeviceToken() async {
    return await authServiceInterface.saveDeviceToken();
  }

  String? _firebaseSessionId;
  String? get firebaseSessionId => _firebaseSessionId;
  void setFirebaseSessionId(String? id) {
    _firebaseSessionId = id;
    update();
  }

  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, String? token, String loginType, {bool fromSignUp = true, bool canRoute = true, UpdateUserModel? updateUserModel, String? password}) async {
    // Sanitize phone number to standard E.164 without leading zeros
    String cleanNumber = phoneNumber.trim();
    if (cleanNumber.startsWith('+9620')) {
      cleanNumber = '+962${cleanNumber.substring(5)}';
    } else if (cleanNumber.startsWith('009620')) {
      cleanNumber = '+962${cleanNumber.substring(6)}';
    } else if (cleanNumber.startsWith('00962')) {
      cleanNumber = '+962${cleanNumber.substring(5)}';
    } else if (cleanNumber.startsWith('9620')) {
      cleanNumber = '+962${cleanNumber.substring(4)}';
    } else if (cleanNumber.startsWith('962')) {
      cleanNumber = '+962${cleanNumber.substring(3)}';
    } else if (cleanNumber.startsWith('07') && cleanNumber.length == 10) {
      cleanNumber = '+962${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+$cleanNumber';
    }

    String encodedPass = '';
    if (password != null && password.isNotEmpty) {
      encodedPass = base64Encode(utf8.encode(password));
    }

    _isLoading = true;
    update();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: cleanNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('Firebase SMS auto retrieval completed: ${credential.smsCode}');
          if (credential.smsCode != null && credential.smsCode!.isNotEmpty) {
            Get.find<VerificationController>().updateVerificationCode(credential.smsCode!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          update();

          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          if (e.code == 'invalid-phone-number') {
            showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
          } else {
            showCustomSnackBar(e.message?.replaceAll('_', ' ') ?? 'verification_failed'.tr);
          }
        },
        codeSent: (String vId, int? resendToken) {
          _firebaseSessionId = vId;
          _isLoading = false;
          update();

          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          if (updateUserModel != null) {
            updateUserModel.sessionInfo = vId;
          }

          if (canRoute) {
            if (ResponsiveHelper.isDesktop(Get.context)) {
              Get.back();
              Get.dialog(VerificationScreen(
                number: cleanNumber, email: null, token: token, fromSignUp: fromSignUp, fromForgetPassword: !fromSignUp,
                loginType: loginType, password: password ?? '', firebaseSession: vId, userModel: updateUserModel,
              ));
            } else {
              Get.toNamed(RouteHelper.getVerificationRoute(
                cleanNumber, '', token, fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword, encodedPass, loginType,
                session: vId, updateUserModel: updateUserModel,
              ));
            }
          } else {
            showCustomSnackBar('otp_sent_successfully'.tr, isError: false);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _firebaseSessionId = verificationId;
          debugPrint('Firebase SMS timeout: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('FirebaseAuth verifyPhoneNumber error: $e');
      _isLoading = false;
      update();
      showCustomSnackBar('firebase_auth_failed'.tr);
    }
  }

}