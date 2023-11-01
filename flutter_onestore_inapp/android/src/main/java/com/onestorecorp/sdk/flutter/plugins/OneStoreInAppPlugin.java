package com.onestorecorp.sdk.flutter.plugins;

import org.jetbrains.annotations.NotNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

public class OneStoreInAppPlugin implements FlutterPlugin, ActivityAware {

    private static final String PROXY_VALUE = "com.onestorecorp.sdk.flutter.plugins";

    private MethodChannel baseChannel;
    private MethodChannel authChannel;
    private MethodChannel licenseChannel;
    private MethodChannel purchaseChannel;

    private AuthCallHandlerImpl authCallHandler;
    private LicenseCallHandlerImpl licenseCallHandler;
    private PurchaseCallHandlerImpl purchaseCallHandler;

    @Override
    public void onAttachedToEngine(@NotNull FlutterPluginBinding binding) {
        baseChannel = new MethodChannel(binding.getBinaryMessenger(), PROXY_VALUE + "/base");
        authChannel = new MethodChannel(binding.getBinaryMessenger(), PROXY_VALUE + "/auth");
        licenseChannel = new MethodChannel(binding.getBinaryMessenger(), PROXY_VALUE + "/license");
        purchaseChannel = new MethodChannel(binding.getBinaryMessenger(), PROXY_VALUE + "/purchase");

        authCallHandler = new AuthCallHandlerImpl(binding.getApplicationContext());
        licenseCallHandler = new LicenseCallHandlerImpl(licenseChannel);
        purchaseCallHandler = new PurchaseCallHandlerImpl(binding.getApplicationContext(), purchaseChannel);
    }

    @Override
    public void onDetachedFromEngine(@NotNull FlutterPluginBinding binding) {
        baseChannel.setMethodCallHandler(null);
        authChannel.setMethodCallHandler(null);
        licenseChannel.setMethodCallHandler(null);
        purchaseChannel.setMethodCallHandler(null);

        baseChannel = null;
        authChannel = null;
        licenseChannel = null;
        purchaseChannel = null;

        authCallHandler = null;
        licenseCallHandler = null;
        purchaseCallHandler = null;
    }

    @Override
    public void onAttachedToActivity(@NotNull ActivityPluginBinding binding) {
        baseChannel.setMethodCallHandler(new BaseCallHandlerImpl());

        authCallHandler.setActivity(binding.getActivity());
        authChannel.setMethodCallHandler(authCallHandler);

        licenseCallHandler.setActivity(binding.getActivity());
        licenseChannel.setMethodCallHandler(licenseCallHandler);

        purchaseCallHandler.setActivity(binding.getActivity());
        purchaseChannel.setMethodCallHandler(purchaseCallHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        authCallHandler.setActivity(null);
        licenseCallHandler.setActivity(null);
        purchaseCallHandler.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NotNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        authCallHandler.setActivity(null);
        authCallHandler.onDetachedFromActivity();

        licenseCallHandler.setActivity(null);
        licenseCallHandler.onDetachedFromActivity();

        purchaseCallHandler.setActivity(null);
        purchaseCallHandler.onDetachedFromActivity();
    }
}
