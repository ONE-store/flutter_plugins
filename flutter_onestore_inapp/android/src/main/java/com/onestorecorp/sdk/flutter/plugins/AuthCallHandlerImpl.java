package com.onestorecorp.sdk.flutter.plugins;

import android.app.Activity;
import android.content.Context;

import com.gaa.sdk.auth.GaaSignInClient;
import com.gaa.sdk.base.Logger;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AuthCallHandlerImpl implements MethodChannel.MethodCallHandler {
    private static final String TAG = "AuthCallHandlerImpl";

    private final Context applicationContext;
    private GaaSignInClient signInClient;


    public AuthCallHandlerImpl(Context context) {
        this.applicationContext = context.getApplicationContext();
    }

    private Activity activity;

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void onDetachedFromActivity() {}

    @Override
    public void onMethodCall(@NotNull MethodCall call, @NotNull MethodChannel.Result result) {
        if (signInClient == null) {
            Logger.d(TAG, "create GaaSignInClient instance");
            signInClient = GaaSignInClient.getClient(applicationContext);
        }

        if ("launchSignInFlow".equals(call.method)) {
            launchSignInFlow(result);
        } else {
            result.notImplemented();
        }
    }

    private void launchSignInFlow(final MethodChannel.Result result) {
        signInClient.launchSignInFlow(activity, signInResult -> {
            Map<String, Object> resultData = new HashMap<>();
            resultData.put("code", signInResult.getCode());
            resultData.put("message", signInResult.getMessage());
            result.success(resultData);
        });
    }
}
