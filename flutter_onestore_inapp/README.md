# flutter\_onestore\_inapp

[![GitHub CI](https://github.com/ONE-store/flutter_plugins/actions/workflows/flutter.yml/badge.svg)](https://github.com/ONE-store/flutter_plugins/actions)
[![GitHub release (with filter)](https://img.shields.io/github/v/release/ONE-store/flutter_plugins)](https://github.com/ONE-store/flutter_plugins/releases/tag/flutter_onestore_inapp-v0.2.0)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/flutter_onestore_inapp)](https://pub.dev/packages/flutter_onestore_inapp/versions/0.2.0)
[![Pub Points](https://img.shields.io/pub/points/flutter_onestore_inapp)](https://pub.dev/packages/flutter_onestore_inapp/score)


A flutter plugin for ONE store In-App Purchase.

> For more information, see the [**Developer Center**](https://dev.onestore.co.kr/devpoc/index.omp).

## Getting started

### Pre-Preparations for ONE store IAP

> - [Membership Registration](https://onestore-dev.gitbook.io/dev/v/eng/docs/member) 
> - [Register App](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/pre-preparations-for-one-store-iap#prepreparationsforonestoreiap-registerapp)


### Installation

> - Add package
>   - Run this command with flutter:
>
>       ```
>         $ flutter pub add flutter_onestore_inapp
>       ```
> 
>   - Add dependency to **pubspec.yaml**[README.md](README.md)
>
>       ```dart
>         dependencies:
>           ..
>           flutter_onestore_inapp: ^0.2.1
>           ..
>       ```
>
>   - Click 'pub get' to download the package or run 'flutter pub get' from the command line.
>
> - Add dependencies to **build.gradle**
>
>   - Add the maven address to the **project's** build.gradle
>   
>       ```groovy
>         allprojects {
>           repositories {
>           ..
>           maven { url 'https://repo.onestore.co.kr/repository/onestore-sdk-public' }
>           }
>         }
>       ```
> 
> - Add **<queries>** to **AndroidManifest.xml**
>   - [If the Target SDK version is 30 (OS 11) or higher](https://dev.onestore.co.kr/devpoc/support/news/noticeView.omp?pageNo=4&noticeId=32968&viewPageNo=&searchValue=), the \<queries\> below must be added for the in-app library to operate properly.
>
>       ```xml
>         <manifest>
>             ...
>             <queries>
>                 <intent>
>                     <action android:name="com.onestore.ipc.iap.IapService.ACTION" />
>                 </intent>
>                 <intent>
>                     <action android:name="android.intent.action.VIEW" />
>       
>                     <data android:scheme="onestore" />
>                 </intent>
>             </queries>
>             ...
>             <application>
>                 ...
>             </application>
>         </manifest>
>       ```


## Usage

> Import it and use in Dart code.
>
>   ```dart
>     import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';
>   ```

- [Request Login](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-2)
- [Update purchase data](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-3)
- [Query Product Details](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-4)
- [Launch Purchase Flow](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-5)
- [Query Purchases](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-7)
- [Update Subscription](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-8)
- [Open the subscription management](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-9)
- [Install ONE store service (OSS)](https://onestore-dev.gitbook.io/dev/tools/tools/v21/14.-flutter-sdk-v21#undefined-10)

> [References](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references)


## Proguard Rules
**It's already obfuscated and in aar, so add the package to the proguard rules.**

```text
# Core proGuard rules
-keep class com.gaa.sdk.base.** { *; }
-keep class com.gaa.sdk.auth.** { *; }

# Purchasing proGuard rules
-keep class com.gaa.sdk.iap.** { *; }

# Licensing proGuard rules
-keep class com.onestore.extern.licensing.** { *; }
```


## Note

This plugin uses
[json_serializable](https://pub.dev/packages/json_serializable) for the
many data structs passed between the underlying platform layers and Dart. After
editing any of the serialized data structs, rebuild the serializers by running
`flutter packages pub run build_runner build --delete-conflicting-outputs`.   
`flutter packages pub run build_runner watch --delete-conflicting-outputs` will
watch the filesystem for changes.

