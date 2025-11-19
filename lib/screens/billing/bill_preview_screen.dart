import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../models/payment_model.dart'; // ✅ ADD
import '../../screens/dashboard/main_layout.dart';
import '../../services/pdf_service.dart';
import '../billing/add_customer_screen.dart';

class BillPreviewScreen extends StatelessWidget {
  final Customer customer;
  final List<BillItem> billItems;
  final double total;
  final double paidAmount;
  final String paymentMethod;
  final double changeAmount;
  final double dueAmount;
  final Payment payment; // ✅ use your model

  const BillPreviewScreen({
    Key? key,
    required this.customer,
    required this.billItems,
    required this.total,
    required this.paidAmount,
    required this.paymentMethod,
    required this.changeAmount,
    this.dueAmount = 0.0,
    required this.payment,
  }) : super(key: key);

  String get _invoiceNumber => 'INV-${DateTime.now().millisecondsSinceEpoch}';
  double get _subtotal => billItems.fold(0.0, (sum, item) => sum + item.total);
  double get _tax => _subtotal * 0.18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill Preview',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _shareBill(context),
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Bill',
          ),
          IconButton(
            onPressed: () => _downloadPDF(context),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Successful!',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Invoice #$_invoiceNumber',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Bill Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShopHeader(),
                    const Divider(height: 40),
                    _buildCustomerDetails(),
                    const SizedBox(height: 24),
                    _buildItemsList(),
                    const Divider(height: 40),
                    _buildBillSummary(),
                    const Divider(height: 40),
                    _buildPaymentDetails(),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Download PDF',
                          onPressed: () => _downloadPDF(context),
                          icon: Icons.download_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _printPDF(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.success),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.print_rounded,
                            color: AppColors.success,
                          ),
                          label: Text(
                            'Print',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _newSale(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New Sale',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _goToDashboard(context),
                    child: Text(
                      'Back to Dashboard',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Vishwakarma Hardware',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          Text(
            'Shop Management System',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill To:',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          customer.displayName,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        Text(
          customer.phone,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
        if (customer.email.isNotEmpty)
          Text(
            customer.email,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
        if (customer.fullAddress.isNotEmpty)
          Text(
            customer.fullAddress,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...billItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${item.brand} • ${item.size}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${item.total.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillSummary() {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', _subtotal),
        _buildSummaryRow('Tax (18%)', _tax),
        const SizedBox(height: 8),
        _buildSummaryRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        _buildSummaryRow('Payment Method', 0, text: paymentMethod),
        _buildSummaryRow('Paid Amount', paidAmount),
        if (changeAmount > 0)
          _buildSummaryRow('Change', changeAmount, isChange: true),
        if (dueAmount > 0)
          _buildSummaryRow('Due Amount', dueAmount, isDue: true),
        if (dueAmount > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Payment Status: ${payment.status.toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    String? text,
    bool isTotal = false,
    bool isChange = false,
    bool isDue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
          Text(
            text ?? '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color:
                  isTotal
                      ? AppColors.success
                      : isChange
                      ? AppColors.warning
                      : isDue
                      ? AppColors.error
                      : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Actions ----------
  void _downloadPDF(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Generating PDF...');
      final pdfBytes = await PDFService.generateInvoicePDF(
        customer: customer,
        billItems: billItems,
        total: total,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        changeAmount: changeAmount,
        invoiceNumber: _invoiceNumber,
      );
      Navigator.pop(context);
      _showPDFOptionsDialog(context, pdfBytes);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Error generating PDF: $e');
    }
  }

  void _printPDF(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Preparing to print...');
      final pdfBytes = await PDFService.generateInvoicePDF(
        customer: customer,
        billItems: billItems,
        total: total,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        changeAmount: changeAmount,
        invoiceNumber: _invoiceNumber,
      );
      Navigator.pop(context);
      await PDFService.printPDF(pdfBytes);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Error printing PDF: $e');
    }
  }

  void _shareBill(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Preparing to share...');
      final pdfBytes = await PDFService.generateInvoicePDF(
        customer: customer,
        billItems: billItems,
        total: total,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        changeAmount: changeAmount,
        invoiceNumber: _invoiceNumber,
      );
      Navigator.pop(context);
      await PDFService.sharePDF(pdfBytes, 'Invoice_$_invoiceNumber');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Error sharing bill: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message, style: GoogleFonts.inter(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPDFOptionsDialog(BuildContext context, dynamic pdfBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'PDF Options',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded, color: Colors.blue),
                title: const Text('Download PDF'),
                subtitle: const Text('Save to device'),
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadPDFFile(context, pdfBytes);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print_rounded, color: Colors.green),
                title: const Text('Print PDF'),
                subtitle: const Text('Send to printer'),
                onTap: () async {
                  Navigator.pop(context);
                  await PDFService.printPDF(pdfBytes);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: Colors.orange),
                title: const Text('Share PDF'),
                subtitle: const Text('Share with others'),
                onTap: () async {
                  Navigator.pop(context);
                  await PDFService.sharePDF(
                    pdfBytes,
                    'Invoice_$_invoiceNumber',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadPDFFile(BuildContext context, dynamic pdfBytes) async {
    try {
      final fileName = 'Invoice_$_invoiceNumber';
      // Use web-safe download
      await PDFService.downloadPDF(pdfBytes, fileName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF ready! Check your downloads.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Error downloading PDF: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _newSale(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
      (route) => route.settings.name == '/dashboard',
    );
  }

  void _goToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
      (route) => false,
    );
  }
}
