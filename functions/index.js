const functions = require("firebase-functions");
const admin = require("firebase-admin");
const midtransClient = require("midtrans-client");

admin.initializeApp();

// ============================================
// CONFIGURATION - GANTI DENGAN KEY ANDA
// ============================================
const MIDTRANS_SERVER_KEY = "Mid-server-e0p5SCWusWKUjTYUEtIsECNf";
const MIDTRANS_CLIENT_KEY = "Mid-client-Q8r2u-5VR9lFJBYl";
const IS_PRODUCTION = false;

// Initialize Midtrans Core API
const coreApi = new midtransClient.CoreApi({
  isProduction: IS_PRODUCTION,
  serverKey: MIDTRANS_SERVER_KEY,
  clientKey: MIDTRANS_CLIENT_KEY,
});

// ============================================
// FUNCTION: CREATE QRIS
// ============================================
exports.createQRIS = functions.https.onCall(async (data, context) => {
  try {
    console.log("🔵 Create QRIS called with data:", data);

    // Validasi input
    if (!data.orderId || !data.amount) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "orderId dan amount harus diisi",
      );
    }

    // Parameter untuk Midtrans
    const parameter = {
      payment_type: "qris",
      transaction_details: {
        order_id: data.orderId,
        gross_amount: data.amount,
      },
      customer_details: {
        first_name: data.customerName || "Customer",
        email: data.email || "customer@example.com",
        phone: data.phone || "08123456789",
      },
    };

    // Tambahkan item_details jika ada
    if (data.items && data.items.length > 0) {
      parameter.item_details = data.items;
    }

    console.log("📤 Request to Midtrans:", parameter);

    // Call Midtrans API
    const chargeResponse = await coreApi.charge(parameter);

    console.log("✅ Midtrans Response:", chargeResponse);

    // Extract QRIS URL
    let qrisUrl = null;

    // Cari dari actions
    if (chargeResponse.actions && chargeResponse.actions.length > 0) {
      const qrAction = chargeResponse.actions.find(
          (action) => action.name === "generate-qr-code",
      );
      qrisUrl = qrAction ? qrAction.url : null;
    }

    // Atau dari qr_string
    if (!qrisUrl && chargeResponse.qr_string) {
      qrisUrl = chargeResponse.qr_string;
    }

    if (!qrisUrl) {
      throw new functions.https.HttpsError(
          "internal",
          "QRIS URL tidak ditemukan dalam response",
      );
    }

    return {
      success: true,
      qrisUrl: qrisUrl,
      transactionId: chargeResponse.transaction_id,
      orderId: chargeResponse.order_id,
      status: chargeResponse.transaction_status,
    };
  } catch (error) {
    console.error("❌ Error creating QRIS:", error);

    throw new functions.https.HttpsError(
        "internal",
        error.message || "Gagal membuat QRIS",
    );
  }
});

// ============================================
// FUNCTION: CHECK PAYMENT STATUS
// ============================================
exports.checkPaymentStatus = functions.https.onCall(async (data, context) => {
  try {
    console.log("🔍 Check status for transaction:", data.transactionId);

    if (!data.transactionId) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "transactionId harus diisi",
      );
    }

    // Get transaction status from Midtrans
    const statusResponse = await coreApi.transaction.status(
        data.transactionId,
    );

    console.log("📊 Status Response:", statusResponse);

    return {
      success: true,
      status: statusResponse.transaction_status,
      orderId: statusResponse.order_id,
      transactionId: statusResponse.transaction_id,
      grossAmount: statusResponse.gross_amount,
      paymentType: statusResponse.payment_type,
      transactionTime: statusResponse.transaction_time,
    };
  } catch (error) {
    console.error("❌ Error checking status:", error);

    throw new functions.https.HttpsError(
        "internal",
        error.message || "Gagal mengecek status pembayaran",
    );
  }
});

// ============================================
// FUNCTION: WEBHOOK (Optional)
// ============================================
exports.midtransWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const notification = req.body;

    console.log("🔔 Webhook received:", notification);

    const orderId = notification.order_id;
    const transactionStatus = notification.transaction_status;
    const fraudStatus = notification.fraud_status;

    console.log(`Order ${orderId} status: ${transactionStatus}`);

    // Update order status di Firestore
    if (transactionStatus === "settlement" || transactionStatus === "capture") {
      if (fraudStatus === "accept") {
        // Payment success - Update Firestore
        await admin.firestore()
            .collection("orders")
            .where("orderId", "==", orderId)
            .limit(1)
            .get()
            .then((snapshot) => {
              if (!snapshot.empty) {
                const doc = snapshot.docs[0];
                return doc.ref.update({
                  paymentStatus: "paid",
                  status: "processing",
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
              }
              return null;
            });

        console.log("✅ Payment success for order:", orderId);
      }
    } else if (
      transactionStatus === "expire" ||
      transactionStatus === "cancel"
    ) {
      console.log("❌ Payment failed/expired for order:", orderId);
    }

    res.status(200).json({status: "success"});
  } catch (error) {
    console.error("❌ Webhook error:", error);
    res.status(500).json({status: "error", message: error.message});
  }
});
