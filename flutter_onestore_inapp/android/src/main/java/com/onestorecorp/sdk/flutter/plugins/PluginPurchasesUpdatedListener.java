package com.onestorecorp.sdk.flutter.plugins;

import com.gaa.sdk.iap.IapResult;
import com.gaa.sdk.iap.PurchaseData;
import com.gaa.sdk.iap.PurchasesUpdatedListener;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class PluginPurchasesUpdatedListener implements PurchasesUpdatedListener {
    private final MethodChannel channel;

    PluginPurchasesUpdatedListener(MethodChannel channel) {
        this.channel = channel;
    }

    @Override
    public void onPurchasesUpdated(IapResult iapResult, List<PurchaseData> list) {
        final Map<String, Object> callbackArgs = new HashMap<>();
        callbackArgs.put("iapResult", FlutterInAppHelper.fromIapResult(iapResult));
        callbackArgs.put("purchasesList", FlutterInAppHelper.fromPurchasesList(list));
        channel.invokeMethod("onPurchasesUpdated", callbackArgs);
    }
}
