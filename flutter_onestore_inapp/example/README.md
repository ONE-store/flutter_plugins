# flutter_onestore_inapp_example

Demonstrates how to use the flutter_onestore_inapp plugin.

## Getting Started

1. [Register Your App](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-registerapp) to Developer Center
2. [Register the In-App product](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-registerin-app)
3. Change **applicationId** to your 'package name' in app's build.gradle
    
   ```groovy
    defaultConfig {
        ..
        applicationId "your package name"
        ..
    }
   ```
   
4. Set your [**PublicKey**](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-checklicensekey-publickey-andoauthcredential) to app_config.dart

   ```dart
   class AppConfig {
     static const publicKey = 'input your publicKey';
   }
   ```
   
