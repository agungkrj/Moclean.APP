import 'package:flutter/material.dart';
import 'detail_transaksi_page.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({Key? key}) : super(key: key);

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String selectedMethod = 'QRIS';
  bool isProcessingQRIS = false;

  // Simulasi pembayaran QRIS
  void _processQRISPayment() {
    if (isProcessingQRIS) return;
    
    setState(() {
      isProcessingQRIS = true;
    });

    // Simulasi delay pembayaran QRIS (5 detik)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailTransaksiPage(
              paymentMethod: 'QRIS',
              orderId: 'ORD-2024-002',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Ilustrasi pembayaran
                  Center(
                    child: Image.asset(
                      'assets/payment.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.payment, size: 60, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Metode COD
                  _buildPaymentMethod(
                    icon: Icons.money,
                    label: 'COD',
                    value: 'COD',
                  ),
                  
                  // Info COD jika dipilih
                  if (selectedMethod == 'COD') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Bayar langsung ke petugas sesuai layanan terkait!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8EAF6)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Pembayaran aman & diverifikasi oleh MoClean',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Metode QRIS
                  _buildPaymentMethod(
                    icon: Icons.qr_code_scanner,
                    label: 'QRIS',
                    value: 'QRIS',
                  ),
                  const SizedBox(height: 20),
                  
                  // QR Code Section
                  if (selectedMethod == 'QRIS')
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // QR Code
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomPaint(
                                    painter: QRCodePainter(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'MoClean',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Info message
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Jika pembayaran belum terproses otomatis, harap manual ulang halaman, atau hubungi ',
                                        ),
                                        TextSpan(
                                          text: 'Admin',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol Saya Sudah Bayar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isProcessingQRIS ? null : _processQRISPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: isProcessingQRIS
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Saya Sudah Bayar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Tombol Bayar - hanya muncul saat COD dipilih
          if (selectedMethod == 'COD')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Handle pembayaran COD
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailTransaksiPage(
                        paymentMethod: 'COD',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Bayar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
          // Reset status processing saat ganti metode
          if (value != 'QRIS') {
            isProcessingQRIS = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter untuk QR Code
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final blockSize = size.width / 8;

    // Gambar pattern QR code (3 kotak besar di sudut)
    // Sudut kiri atas
    _drawQRCorner(canvas, paint, 0, 0, blockSize);
    // Sudut kanan atas
    _drawQRCorner(canvas, paint, size.width - blockSize * 2, 0, blockSize);
    // Sudut kiri bawah
    _drawQRCorner(canvas, paint, 0, size.height - blockSize * 2, blockSize);

    // Gambar pattern tengah (simulasi data)
    for (int i = 3; i < 6; i++) {
      for (int j = 3; j < 6; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * blockSize,
              i * blockSize,
              blockSize * 0.8,
              blockSize * 0.8,
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawQRCorner(Canvas canvas, Paint paint, double x, double y, double blockSize) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x, y, blockSize * 2, blockSize * 2),
      paint,
    );
    // Inner white square
    canvas.drawRect(
      Rect.fromLTWH(x + blockSize * 0.3, y + blockSize * 0.3, blockSize * 1.4, blockSize * 1.4),
      Paint()..color = Colors.white,
    );
    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(x + blockSize * 0.6, y + blockSize * 0.6, blockSize * 0.8, blockSize * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}