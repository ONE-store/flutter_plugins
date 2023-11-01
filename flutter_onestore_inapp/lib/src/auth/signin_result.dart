import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signin_result.g.dart';

@JsonSerializable()
@AuthResponseConverter()
@immutable
class SignInResult {
  final AuthResponse code;
  final String message;

  const SignInResult({required this.code, required this.message});

  factory SignInResult.fromJson(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const SignInResult(
          code: AuthResponse.error,
          message: 'Invalid billing result map from method channel.');
    }
    return _$SignInResultFromJson(map);
  }

  bool isSuccess() => code == AuthResponse.ok;

  @override
  String toString() => 'SingInResult(code=$code, message=$message)';
}

@JsonEnum(alwaysCreate: true)
enum AuthResponse {
  @JsonValue(0)
  ok,
  @JsonValue(1)
  userCanceled,
  @JsonValue(2)
  serviceUnavailable,
  @JsonValue(5)
  developerError,
  @JsonValue(6)
  error,
  @JsonValue(9)
  fail,
  @JsonValue(10)
  needLogin,
  @JsonValue(11)
  needUpdate,
  @JsonValue(101)
  errorInstall,
  @JsonValue(104)
  downloading,
  @JsonValue(105)
  installing,
  @JsonValue(99999)
  emergencyError,
  @JsonValue(1006)
  updateOrInstallFail,
  @JsonValue(1007)
  serviceDisconnected,
  @JsonValue(1008)
  featureNotSupported,
  @JsonValue(1009)
  serviceTimeout,
  @JsonValue(1010)
  clientNotEnabled,
  @JsonValue(12500)
  signInFailed,
  @JsonValue(12501)
  signInCanceled,
  @JsonValue(12502)
  signInCurrentlyInProgress,
}

class AuthResponseConverter implements JsonConverter<AuthResponse, int?> {
  const AuthResponseConverter();

  @override
  AuthResponse fromJson(int? json) {
    if (json == null) return AuthResponse.error;

    return $enumDecode(_$AuthResponseEnumMap, json);
  }

  @override
  int toJson(AuthResponse object) => _$AuthResponseEnumMap[object]!;
}
