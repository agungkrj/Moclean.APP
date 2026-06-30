import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moclienapp/models/order_model.dart';
import 'package:moclienapp/services/firebase_order_service.dart';
import 'package:intl/intl.dart';
import 'detail_transaksi_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class PembayaranPage extends StatefulWidget {
  final OrderModel order;
  final int totalAmount;
  final int biayaLayanan;
  final int biayaUkuran;
  final int biayaAdmin;

  // ✅ PERBAIKAN: Hapus 'const' dari constructor
  PembayaranPage({
    Key? key,
    required this.order,
    required this.totalAmount,
    required this.biayaLayanan,
    required this.biayaUkuran,
    required this.biayaAdmin,
  }) : super(key: key);

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final FirebaseOrderService _orderService = FirebaseOrderService();
  String selectedMethod = 'QRIS';
  bool isProcessingQRIS = false;
  bool isProcessingCOD = false;
  bool showCopySuccess = false;
  final List<String> _paymentSteps = [
    'Scan QR Code di atas',
    'Bayar sesuai nominal',
    'Tunggu konfirmasi otomatis (1-2 menit)',
    'Jika belum terkonfirmasi, tekan "Konfirmasi Manual"',
  ];
  int _currentStep = 0;
  Timer? _paymentTimer;

  // Generate Virtual Account atau QRIS Static
  String get paymentCode {
    // Format: ORDERID + TANGGAL + NOMINAL
    final now = DateTime.now();
    final formattedDate = DateFormat('ddMMyy').format(now);
    final lastFourDigits = widget.order.orderId.substring(
      widget.order.orderId.length - 4,
    );
    return 'MC${formattedDate}${lastFourDigits}';
  }

  String get qrisData {
    // QRIS Data yang bisa discan aplikasi bank/e-wallet
    // Format minimal untuk testing
    return "00020101021226690014ID.CO.QRIS.WWW011893600${paymentCode}5204581253033605406${widget.totalAmount}5802ID5913MOCLEAN${widget.order.orderId.substring(0, 8)}6007JAKARTA6105121606304";
  }

  // Virtual Account Numbers untuk berbagai bank
  final Map<String, String> _vaNumbers = {
    'BCA': '828200${Random().nextInt(999999).toString().padLeft(6, '0')}',
    'BNI': '8808${Random().nextInt(99999999).toString().padLeft(8, '0')}',
    'BRI': '888800${Random().nextInt(999999).toString().padLeft(6, '0')}',
    'MANDIRI': '89508${Random().nextInt(9999999).toString().padLeft(7, '0')}',
  };

  String selectedBank = 'BCA';

  // Mulai timer untuk simulasi pembayaran
  void _startPaymentTimer() {
    _paymentTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentStep < _paymentSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Generate VA numbers berdasarkan order ID
    _generateVANumbers();
  }

  void _generateVANumbers() {
    final orderIdLast6 = widget.order.orderId.substring(
      max(0, widget.order.orderId.length - 6),
    ).padLeft(6, '0');
    
    final orderIdLast8 = widget.order.orderId.substring(
      max(0, widget.order.orderId.length - 8),
    ).padLeft(8, '0');
    
    final orderIdLast7 = widget.order.orderId.substring(
      max(0, widget.order.orderId.length - 7),
    ).padLeft(7, '0');
    
    setState(() {
      _vaNumbers['BCA'] = '828200$orderIdLast6';
      _vaNumbers['BNI'] = '8808$orderIdLast8';
      _vaNumbers['BRI'] = '888800$orderIdLast6';
      _vaNumbers['MANDIRI'] = '89508$orderIdLast7';
    });
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    super.dispose();
  }

  // Proses pembayaran QRIS
  void _processQRISPayment() async {
    if (isProcessingQRIS) return;
    
    setState(() {
      isProcessingQRIS = true;
      _currentStep = 0;
    });

    // Mulai timer pembayaran
    _startPaymentTimer();
    
    // Simulasi pembayaran sukses setelah 30 detik
    Timer(const Duration(seconds: 30), () async {
      if (!mounted || !isProcessingQRIS) return;
      
      bool success = await _orderService.saveOrderAfterPayment(
        order: widget.order,
        paymentMethod: 'QRIS',
        totalAmount: widget.totalAmount,
        biayaLayanan: widget.biayaLayanan,
        biayaUkuran: widget.biayaUkuran,
        biayaAdmin: widget.biayaAdmin,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Pembayaran berhasil diverifikasi!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransaksiPage(
              paymentMethod: 'QRIS',
              orderId: widget.order.orderId,
            ),
          ),
        );
      }
    });
  }

  // Proses pembayaran COD
  void _processCODPayment() async {
    if (isProcessingCOD) return;
    
    setState(() {
      isProcessingCOD = true;
    });
    
    // Simpan pesanan ke Firebase
    bool success = await _orderService.saveOrderAfterPayment(
      order: widget.order,
      paymentMethod: 'COD',
      totalAmount: widget.totalAmount,
      biayaLayanan: widget.biayaLayanan,
      biayaUkuran: widget.biayaUkuran,
      biayaAdmin: widget.biayaAdmin,
    );
    
    if (!mounted) return;
    
    setState(() {
      isProcessingCOD = false;
    });
    
    if (success) {
      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pesanan berhasil dibuat! Menunggu konfirmasi mitra'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Navigate ke detail transaksi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTransaksiPage(
            paymentMethod: 'COD',
            orderId: widget.order.orderId,
          ),
        ),
      );
    } else {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal membuat pesanan, silakan coba lagi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Konfirmasi manual (jika pembayaran tidak terdeteksi otomatis)
  void _confirmManualPayment() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Manual'),
        content: const Text(
          'Pastikan Anda sudah melakukan pembayaran via QRIS.\n\nUpload bukti pembayaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadPaymentProof();
            },
            child: const Text('Upload Bukti'),
          ),
        ],
      ),
    );
  }

  void _uploadPaymentProof() async {
    // Simulasi upload bukti pembayaran
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bukti pembayaran berhasil diupload! Admin akan memverifikasi.'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Simpan status pending payment
    await _orderService.saveOrderAfterPayment(
      order: widget.order,
      paymentMethod: 'QRIS_PENDING',
      totalAmount: widget.totalAmount,
      biayaLayanan: widget.biayaLayanan,
      biayaUkuran: widget.biayaUkuran,
      biayaAdmin: widget.biayaAdmin,
    );
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiPage(
          paymentMethod: 'QRIS_PENDING',
          orderId: widget.order.orderId,
        ),
      ),
    );
  }

  // Salin teks ke clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Berhasil disalin ke clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
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
                  // Card Order Summary
                  _buildOrderSummary(),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Method Selection
                  _buildPaymentMethodSelection(),
                  
                  // QRIS Section
                  if (selectedMethod == 'QRIS') ...[
                    _buildQRISSection(),
                    const SizedBox(height: 20),
                    _buildVirtualAccountSection(),
                  ],
                  
                  // COD Section
                  if (selectedMethod == 'COD') _buildCODSection(),
                ],
              ),
            ),
          ),
          
          // Bottom Payment Button
          if (selectedMethod == 'COD') _buildCODPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ID Pesanan:', style: TextStyle(color: Colors.black54)),
              Text(
                widget.order.orderId.substring(widget.order.orderId.length - 8),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Layanan:', style: TextStyle(color: Colors.black54)),
              Text(widget.order.serviceName, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.order.brand} ${widget.order.type}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Metode Pembayaran:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                icon: Icons.qr_code_2,
                title: 'QRIS',
                subtitle: 'Bayar via e-wallet/bank',
                isSelected: selectedMethod == 'QRIS',
                onTap: () => setState(() => selectedMethod = 'QRIS'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                icon: Icons.money,
                title: 'COD',
                subtitle: 'Bayar di tempat',
                isSelected: selectedMethod == 'COD',
                onTap: () => setState(() => selectedMethod = 'COD'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.white : const Color(0xFF1E3A8A)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRISSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        
        // QR Code Display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: QrImageView(
                  data: qrisData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Payment Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Merchant', 'MoClean'),
                    const Divider(height: 12),
                    _buildInfoRow(
                      'Nominal', 
                      'Rp ${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}',
                      isBold: true,
                      valueColor: const Color(0xFF1E3A8A),
                    ),
                    const Divider(height: 12),
                    _buildInfoRow('Kode Pembayaran', paymentCode),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Payment Steps
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Langkah Pembayaran:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._paymentSteps.asMap().entries.map((entry) {
                int idx = entry.key;
                String step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: idx <= _currentStep 
                              ? const Color(0xFF1E3A8A) 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              color: idx <= _currentStep ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            color: idx <= _currentStep ? Colors.black : Colors.grey[600],
                            fontWeight: idx <= _currentStep ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Action Buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessingQRIS ? null : _processQRISPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isProcessingQRIS
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Menunggu Pembayaran...'),
                        ],
                      )
                    : const Text(
                        'Mulai Proses Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _confirmManualPayment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                ),
                child: const Text(
                  'Konfirmasi Manual',
                  style: TextStyle(color: Color(0xFF1E3A8A)),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Info Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'QRIS ini bisa discan oleh semua aplikasi e-wallet dan mobile banking yang support QRIS',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualAccountSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Atau Bayar via Transfer:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _vaNumbers.keys.map((bank) {
            return ChoiceChip(
              label: Text(bank),
              selected: selectedBank == bank,
              onSelected: (selected) {
                setState(() => selectedBank = bank);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Virtual Account $selectedBank',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _copyToClipboard(_vaNumbers[selectedBank]!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E3A8A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _vaNumbers[selectedBank]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.content_copy, color: Color(0xFF1E3A8A)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Salin nomor VA dan bayar via ATM/Mobile Banking',
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCODSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.delivery_dining, size: 50, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 16),
              const Text(
                'Cash on Delivery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bayar langsung ke petugas saat layanan diberikan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tidak perlu transfer atau pembayaran online',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCODPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isProcessingCOD ? null : _processCODPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isProcessingCOD
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Konfirmasi Pesanan COD',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}