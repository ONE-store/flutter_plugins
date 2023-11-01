package com.onestorecorp.sdk.flutter.plugins;

import com.gaa.sdk.iap.AcknowledgeParams;
import com.gaa.sdk.iap.ConsumeParams;
import com.gaa.sdk.iap.IapResult;
import com.gaa.sdk.iap.ProductDetail;
import com.gaa.sdk.iap.ProductDetailsParams;
import com.gaa.sdk.iap.PurchaseClient;
import com.gaa.sdk.iap.PurchaseData;
import com.gaa.sdk.iap.PurchaseFlowParams;
import com.gaa.sdk.iap.PurchaseFlowParams.SubscriptionUpdateParams;
import com.gaa.sdk.iap.SubscriptionParams;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodCall;

public class FlutterInAppHelper {

    static PurchaseData toPurchaseData(MethodCall call) {
        String originalJson = call.argument("originalJson");
        String signature = call.argument("signature");
        if (originalJson == null)
            return null;

        return new PurchaseData(originalJson, signature, null);
    }

    static PurchaseFlowParams toPurchaseFlowParams(MethodCall call) {
        final Object quantityObj = call.argument("quantity");
        final Object promotionObj = call.argument("promotionApplicable");

        return PurchaseFlowParams.newBuilder()
                .setProductId(call.argument("productId"))
                .setProductName(call.argument("productName"))
                .setProductType(call.argument("productType"))
                .setDeveloperPayload(call.argument("developerPayload"))
                .setQuantity((quantityObj == null) ? 1 : (int) quantityObj)
                .setGameUserId(call.argument("gameUserId"))
                .setPromotionApplicable(promotionObj != null && (boolean) promotionObj)
                .setSubscriptionUpdateParams(toSubscriptionUpdateParams(call))
                .build();

    }

    static SubscriptionUpdateParams toSubscriptionUpdateParams(MethodCall call) {
        final String oldPurchaseToken = call.argument("oldPurchaseToken");
        final Object prorationMode = call.hasArgument("prorationMode") ?
                call.argument("prorationMode") :
                PurchaseFlowParams.ProrationMode.UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY;

        if (oldPurchaseToken == null || prorationMode == null){
            return null;
        }

        return SubscriptionUpdateParams.newBuilder()
                .setOldPurchaseToken(oldPurchaseToken)
                .setProrationMode((int) prorationMode)
                .build();
    }

    static ConsumeParams toConsumeParams(MethodCall call) {
        return ConsumeParams.newBuilder()
                .setPurchaseData(toPurchaseData(call))
                .setDeveloperPayload(call.argument("developerPayload"))
                .build();
    }

    static AcknowledgeParams toAcknowledgeParams(MethodCall call) {
        return AcknowledgeParams.newBuilder()
                .setPurchaseData(toPurchaseData(call))
                .setDeveloperPayload(call.argument("developerPayload"))
                .build();
    }

    static ProductDetailsParams toProductDetailParams(MethodCall call) {
        List<String> productIds = call.argument("productIds");
        String type = call.argument("productType");

        if (type == null) {
            type = PurchaseClient.ProductType.ALL;
        }

        return ProductDetailsParams.newBuilder()
                .setProductIdList(productIds)
                .setProductType(type)
                .build();
    }

    static SubscriptionParams toSubscriptionParams(MethodCall call) {
        return SubscriptionParams.newBuilder()
                .setPurchaseData(toPurchaseData(call))
                .build();
    }

    static List<HashMap<String, Object>> fromProductDetailsList(List<ProductDetail> data) {
        if (data == null) {
            return Collections.emptyList();
        }

        List<HashMap<String, Object>> result = new ArrayList<>();
        for (ProductDetail productDetail: data) {
            result.add(fromProductDetail(productDetail));
        }
        return result;
    }

    static HashMap<String, Object> fromProductDetail(ProductDetail data) {
        HashMap<String, Object> result = new HashMap<>();
        result.put("productId", data.getProductId());
        result.put("productType", data.getType());
        result.put("title", data.getTitle());
        result.put("price", data.getPrice());
        result.put("priceCurrencyCode", data.getPriceCurrencyCode());
        result.put("priceAmountMicros", data.getPriceAmountMicros());
        result.put("subscriptionPeriod", data.getSubscriptionPeriod());
        result.put("subscriptionPeriodUnitCode", data.getSubscriptionPeriodUnitCode());
        result.put("freeTrialPeriod", data.getFreeTrialPeriod());
        result.put("promotionPrice", data.getPromotionPrice());
        result.put("promotionPriceMicros", data.getPromotionPriceMicros());
        result.put("promotionUsePeriod", data.getPromotionUsePeriod());
        result.put("paymentGracePeriod", data.getPaymentGracePeriod());
        return result;
    }



    static List<HashMap<String, Object>> fromPurchasesList(List<PurchaseData> data) {
        if (data == null) {
            return Collections.emptyList();
        }

        List<HashMap<String, Object>> result = new ArrayList<>();
        for (PurchaseData purchaseData: data) {
            result.add(fromPurchaseData(purchaseData));
        }
        return result;
    }

    static HashMap<String, Object> fromPurchaseData(PurchaseData data) {
        HashMap<String, Object> result = new HashMap<>();
        result.put("orderId", data.getOrderId());
        result.put("productId", data.getProductId());
        result.put("packageName", data.getPackageName());
        result.put("purchaseTime", data.getPurchaseTime());
        result.put("purchaseToken", data.getPurchaseToken());
        result.put("purchaseState", data.getPurchaseState());
        result.put("recurringState", data.getRecurringState());
        result.put("isAcknowledged", data.isAcknowledged());
        result.put("developerPayload", data.getDeveloperPayload());
        result.put("quantity", data.getQuantity());
        result.put("originalJson", data.getOriginalJson());
        result.put("signature", data.getSignature());
        return result;
    }

    static HashMap<String, Object> fromIapResult(IapResult data) {
        HashMap<String, Object> result = new HashMap<>();
        result.put("responseCode", data.getResponseCode());
        result.put("message", data.getMessage());
        return result;
    }
}
