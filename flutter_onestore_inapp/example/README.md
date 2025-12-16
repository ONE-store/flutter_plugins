# flutter_onestore_inapp_example

Demonstrates how to use the flutter_onestore_inapp plugin.

## Getting Started

1. [Register Your App](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-registerapp)
   to Developer Center
2. [Register the In-App product](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-registerin-app)
3. Change **applicationId** to your 'package name' in app's build.gradle

   ```groovy
    defaultConfig {
        ..
        applicationId "your package name"
        ..
    }
   ```

4. Set your [**PublicKey
   **](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-checklicensekey-publickey-andoauthcredential)
   to app_config.dart

   ```dart
   class AppConfig {
     static const publicKey = 'input your publicKey';
   }
   ```

5. If you want to test Global server, you need to add the corresponding option to androidManifest.xml.

   ```xml
   <application>
         <!--
            WARNING: Remove this option for release binaries!
            Options for in-app testing on your global store (Available from IAP v21.02.00)
             - onestore_00 : South Korea (Default)
             - onestore_01 : Singapore, Taiwan
             - onestore_02 : United States (Digital Turbine)
             - onestore_03 : ONE Billing Lab (Available from IAP v21.04.00)

            If not set, defaults to South Korea.
         -->
         <meta-data android:name="onestore:dev_option" android:value="onestore_01" />
   </application>
   ```

> **Warning**
This option must be removed from release versions.

