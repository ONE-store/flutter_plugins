package com.onestorecorp.sdk.flutter.plugins;

import android.app.Activity;

import com.gaa.sdk.base.Logger;
import com.onestore.extern.licensing.AppLicenseChecker;
import com.onestore.extern.licensing.LicenseCheckerListener;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class LicenseCallHandlerImpl implements MethodChannel.MethodCallHandler, LicenseCheckerListener {
    private static final String TAG = "LicenseCallHandlerImpl";
    private MethodChannel methodChannel;
    private Activity activity;

    private AppLicenseChecker checker;

    public LicenseCallHandlerImpl(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void onDetachedFromActivity() {
        destroy();
    }

    @Override
    public void onMethodCall(@NotNull MethodCall call, @NotNull MethodChannel.Result result) {
        switch (call.method) {
            case "queryLicense": queryLicense(call.arguments.toString()); break;
            case "strictQueryLicense": strictQueryLicense(call.arguments.toString()); break;
            case "destroy": destroy(); break;
            default: result.notImplemented(); break;
        }
    }

    private void initAppLicenseChecker(String publicKey) {
        if (checker == null) {
            checker = AppLicenseChecker.get(activity, publicKey, this);
        }
    }

    private void queryLicense(String publicKey) {
        initAppLicenseChecker(publicKey);
        checker.queryLicense();
    }

    private void strictQueryLicense(String publicKey) {
        initAppLicenseChecker(publicKey);
        checker.strictQueryLicense();
    }

    private void destroy() {
        Logger.d(TAG, "destroy");
        if (checker != null) checker.destroy();
        checker = null;
    }

    @Override
    public void granted(String license, String signature) {
        Map<String, Object> resultData = new HashMap<>();
        resultData.put("license", license);
        resultData.put("signature", signature);
        methodChannel.invokeMethod("onGranted", resultData);
    }

    @Override
    public void denied() {
        methodChannel.invokeMethod("onDenied", null);
    }

    @Override
    public void error(int code, String message) {
        Map<String, Object> resultData = new HashMap<>();
        resultData.put("code", code);
        resultData.put("message", message);
        methodChannel.invokeMethod("onError", resultData);
    }

}
