package com.onestorecorp.sdk.flutter.plugins;

import android.content.Context;
import android.util.Log;

import com.gaa.sdk.base.Logger;
import com.gaa.sdk.base.StoreEnvironment;

import org.jetbrains.annotations.NotNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BaseCallHandlerImpl implements MethodChannel.MethodCallHandler {
    private static final String TAG = "BaseCallHandlerImpl";

    private final Context context;


    public BaseCallHandlerImpl(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NotNull MethodCall call, @NotNull MethodChannel.Result result) {
        switch (call.method) {
            case "setLogLevel":
                Logger.setLogLevel(toLogLevel(call));
                break;
            case "getStoreType":
                int storeType = StoreEnvironment.getStoreType(context);
                result.success(storeType);
                break;
            default:
                result.notImplemented();
                break;
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
