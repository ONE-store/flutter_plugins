package com.onestorecorp.sdk.flutter.plugins;

import android.util.Log;

import com.gaa.sdk.base.Logger;

import org.jetbrains.annotations.NotNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BaseCallHandlerImpl implements MethodChannel.MethodCallHandler {
    private static final String TAG = "BaseCallHandlerImpl";
    @Override
    public void onMethodCall(@NotNull MethodCall call, @NotNull MethodChannel.Result result) {
        if ("setLogLevel".equals(call.method)) {
            Logger.setLogLevel(toLogLevel(call));
        } else {
            result.notImplemented();
        }
    }

    private int toLogLevel(MethodCall call) {
        String level = call.arguments.toString();
        if (level.contains("verbose")) {
            return Log.VERBOSE;
        } else if (level.contains("debug")) {
            return Log.DEBUG;
        } else if (level.contains("info")) {
            return Log.INFO;
        } else if (level.contains("warning")) {
            return Log.WARN;
        } else if (level.contains("error")) {
            return Log.ERROR;
        } else {
            return Log.INFO;
        }
    }
}
