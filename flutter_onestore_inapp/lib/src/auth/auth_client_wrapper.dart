import '../onestore_channel.dart';
import 'signin_result.dart';

/// MethodChannel을 사용하는 클래스는 모두 OneStoreMethodChannel을 상속받는다.
class OneStoreAuthClient extends OneStoreChannel {
  OneStoreAuthClient() : super('auth');

  // launchSignInFlow 호출
  Future<SignInResult> launchSignInFlow() async {
    return SignInResult.fromJson(
        await channel.invokeMapMethod('launchSignInFlow') ??
            <String, dynamic>{});
  }
}
