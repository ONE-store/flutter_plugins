package com.onestorecorp.sdk.flutter.plugins;

import android.app.Activity;
import android.content.Context;

import com.gaa.sdk.base.Logger;
import com.gaa.sdk.iap.AcknowledgeParams;
import com.gaa.sdk.iap.ConsumeParams;
import com.gaa.sdk.iap.IapResult;
import com.gaa.sdk.iap.ProductDetail;
import com.gaa.sdk.iap.ProductDetailsParams;
import com.gaa.sdk.iap.PurchaseClient;
import com.gaa.sdk.iap.PurchaseClientStateListener;
import com.gaa.sdk.iap.PurchaseFlowParams;
import com.gaa.sdk.iap.SubscriptionParams;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PurchaseCallHandlerImpl implements MethodChannel.MethodCallHandler {

    private static final String TAG = "PurchaseCallHandlerImpl";
    private final Context applicationContext;
    private final MethodChannel methodChannel;
    private PurchaseClient purchaseClient;

    private Activity activity;

    private final HashMap<String, ProductDetail> cachedProducts = new HashMap<>();

    public PurchaseCallHandlerImpl(Context context, MethodChannel methodChannel) {
        this.applicationContext = context.getApplicationContext();
        this.methodChannel = methodChannel;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void onDetachedFromActivity() {
        endPurchaseClientConnection();
    }

    @Override
    public void onMethodCall(@NotNull MethodCall call, @NotNull MethodChannel.Result result) {
        switch (call.method) {
            case "isReady": isReady(result); break;
            case "startConnection": startConnection(call, result); break;
            case "endConnection": endConnection(result); break;
            case "launchPurchaseFlow": launchPurchaseFlow(call, result); break;
            case "consumeAsync": consumePurchase(call, result); break;
            case "acknowledgeAsync": acknowledgePurchase(call, result); break;
            case "queryPurchasesAsync": queryPurchases(call, result); break;
            case "queryProductDetailsAsync": queryProductDetails(call ,result); break;
            case "getStoreInfoAsync": getStoreInfo(result); break;
            case "launchManageSubscription": launchManageSubscription(call, result); break;
            case "launchUpdateOrInstallFlow": launchUpdateOrInstallFlow(result); break;
            default:result.notImplemented(); break;
        }
    }

    private void isReady(MethodChannel.Result result) {
        if (purchaseClientError(result)) return;
        result.success(purchaseClient.isReady());
    }

    private void startConnection(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClient == null) {
            purchaseClient = PurchaseClient.newBuilder(applicationContext)
                    .setBase64PublicKey(call.argument("publicKey"))
                    .setListener(new PluginPurchasesUpdatedListener(methodChannel))
                    .build();
        }

        purchaseClient.startConnection(new PurchaseClientStateListener() {
            private boolean setupFinished = false;

            @Override
            public void onSetupFinished(IapResult iapResult) {
                if (setupFinished) {
                    Logger.d(TAG, "Tried to call onSetupFinished multiple times.");
                    return;
                }

                setupFinished = true;
                result.success(FlutterInAppHelper.fromIapResult(iapResult));
            }

            @Override
            public void onServiceDisconnected() {
                Logger.d(TAG, " Purchasing service disconnected");
                int handle = call.argument("handle");
                final Map<String, Object> args = new HashMap<>();
                args.put("handle", handle);
                methodChannel.invokeMethod("onServiceDisconnected", args);
            }
        });
    }

    private void consumePurchase(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final ConsumeParams params = FlutterInAppHelper.toConsumeParams(call);
        purchaseClient.consumeAsync(params, (iapResult, purchaseData) -> {
            Logger.d(TAG, "consumeAsync response => " + iapResult.toJsonString());
            result.success(FlutterInAppHelper.fromIapResult(iapResult));
        });
    }

    private void acknowledgePurchase(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final AcknowledgeParams params = FlutterInAppHelper.toAcknowledgeParams(call);
        purchaseClient.acknowledgeAsync(params, (iapResult, purchaseData) -> {
            Logger.d(TAG, "acknowledgeAsync response => " + iapResult.toJsonString());
            result.success(FlutterInAppHelper.fromIapResult(iapResult));
        });
    }

    private void queryProductDetails(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final ProductDetailsParams params = FlutterInAppHelper.toProductDetailParams(call);
        purchaseClient.queryProductDetailsAsync(params, (iapResult, list) -> {
            Logger.d(TAG, "queryProductDetails => " + iapResult.toJsonString());
            final Map<String, Object> resultData = new HashMap<>();
            resultData.put("iapResult", FlutterInAppHelper.fromIapResult(iapResult));
            resultData.put("productDetailsList", FlutterInAppHelper.fromProductDetailsList(list));
            result.success(resultData);
        });
    }

    private void queryPurchases(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final String productType = call.argument("productType");
        Logger.d(TAG, "queryPurchases request productType: productType");
        purchaseClient.queryPurchasesAsync(productType, (iapResult, list) -> {
            Logger.d(TAG, "queryPurchases => " + iapResult.toJsonString());
            final Map<String, Object> resultData = new HashMap<>();
            resultData.put("iapResult", FlutterInAppHelper.fromIapResult(iapResult));
            resultData.put("purchasesList", FlutterInAppHelper.fromPurchasesList(list));
            result.success(resultData);
        });

    }

    private void getStoreInfo(final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        purchaseClient.getStoreInfoAsync((iapResult, s) -> {
            final Map<String, Object> resultData = new HashMap<>();
            resultData.put("iapResult", FlutterInAppHelper.fromIapResult(iapResult));
            resultData.put("storeCode", s);
            result.success(resultData);
        });
    }

    private void launchPurchaseFlow(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final PurchaseFlowParams params = FlutterInAppHelper.toPurchaseFlowParams(call);
        final IapResult iapResult = purchaseClient.launchPurchaseFlow(activity, params);
        result.success(FlutterInAppHelper.fromIapResult(iapResult));
    }

    private void launchManageSubscription(final MethodCall call, final MethodChannel.Result result) {
        if (purchaseClientError(result)) return;

        final SubscriptionParams subscriptionParams = FlutterInAppHelper.toSubscriptionParams(call);
        purchaseClient.launchManageSubscription(activity, subscriptionParams);
        result.success(null);
    }

    private void launchUpdateOrInstallFlow(final MethodChannel.Result result) {
        if (purchaseClientError(result)) {
            purchaseClient.launchUpdateOrInstallFlow(activity, iapResult -> {
                Logger.d(TAG, "launchUpdateOrInstallFlow response => " + iapResult.toJsonString());
                result.success(FlutterInAppHelper.fromIapResult(iapResult));
            });// update or install 연결.
        }
    }

    private void endConnection(MethodChannel.Result result) {
        endPurchaseClientConnection();
        result.success(null);
    }

    private void endPurchaseClientConnection() {
        if (purchaseClient != null) {
            purchaseClient.endConnection();
            purchaseClient = null;
        }
    }

    private boolean purchaseClientError(MethodChannel.Result result) {
        if (purchaseClient != null) {
            return false;
        }
        result.error(
                String.valueOf(PurchaseClient.ResponseCode.RESULT_SERVICE_UNAVAILABLE),
                "PurchaseClient is unset. Try reconnecting.", null);
        return true;
    }
}
