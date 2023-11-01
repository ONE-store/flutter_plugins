// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signin_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInResult _$SignInResultFromJson(Map json) => SignInResult(
      code: const AuthResponseConverter().fromJson(json['code'] as int?),
      message: json['message'] as String,
    );

const _$AuthResponseEnumMap = {
  AuthResponse.ok: 0,
  AuthResponse.userCanceled: 1,
  AuthResponse.serviceUnavailable: 2,
  AuthResponse.developerError: 5,
  AuthResponse.error: 6,
  AuthResponse.fail: 9,
  AuthResponse.needLogin: 10,
  AuthResponse.needUpdate: 11,
  AuthResponse.errorInstall: 101,
  AuthResponse.downloading: 104,
  AuthResponse.installing: 105,
  AuthResponse.emergencyError: 99999,
  AuthResponse.updateOrInstallFail: 1006,
  AuthResponse.serviceDisconnected: 1007,
  AuthResponse.featureNotSupported: 1008,
  AuthResponse.serviceTimeout: 1009,
  AuthResponse.clientNotEnabled: 1010,
  AuthResponse.signInFailed: 12500,
  AuthResponse.signInCanceled: 12501,
  AuthResponse.signInCurrentlyInProgress: 12502,
};
