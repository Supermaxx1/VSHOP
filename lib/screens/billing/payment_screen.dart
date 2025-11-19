import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../models/payment_model.dart';
import 'bill_preview_screen.dart';
import '../../services/database_service.dart';

class PaymentScreen extends StatefulWidget {
  final Customer customer;
  final List<BillItem> billItems;
  final double total;

  const PaymentScreen({
    Key? key,
    required this.customer,
    required this.billItems,
    required this.total,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Cash';
  final _paidAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _allowPartialPayment = true;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(name: 'Cash', icon: Icons.money, color: AppColors.success),
    PaymentMethod(
      name: 'Card',
      icon: Icons.credit_card,
      color: AppColors.primaryColor,
    ),
    PaymentMethod(
      name: 'UPI',
      icon: Icons.qr_code_scanner,
      color: AppColors.warning,
    ),
    PaymentMethod(
      name: 'Net Banking',
      icon: Icons.account_balance,
      color: AppColors.info,
    ),
  ];

  double get _paidAmount => double.tryParse(_paidAmountController.text) ?? 0.0;
  double get _changeAmount =>
      _paidAmount > widget.total ? _paidAmount - widget.total : 0.0;
  double get _dueAmount =>
      widget.total > _paidAmount ? widget.total - _paidAmount : 0.0;
  bool get _isValidPayment => _paidAmount > 0;
  bool get _isFullPayment => _paidAmount >= widget.total;
  String get _paymentStatus {
    if (_isFullPayment) return 'Full Payment';
    if (_paidAmount > 0) return 'Partial Payment';
    return 'No Payment';
  }

  @override
  void initState() {
    super.initState();
    _paidAmountController.text = widget.total.toStringAsFixed(2);
    _paidAmountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBillSummaryHeader(),
              const SizedBox(height: 24),
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              _buildPartialPaymentToggle(),
              const SizedBox(height: 24),
              _buildPaymentAmountSection(),
              const SizedBox(height: 24),
              _buildPaymentSummary(),
              const SizedBox(height: 40),
              _buildProcessPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 32, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill Summary',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.billItems.length} items • ${widget.customer.name}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${widget.total.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialPaymentToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow Partial Payment',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Customer can pay less than total amount',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _allowPartialPayment,
            onChanged: (value) {
              setState(() {
                _allowPartialPayment = value;
                if (!value) {
                  _paidAmountController.text = widget.total.toStringAsFixed(2);
                }
              });
            },
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _paymentMethods.length,
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            final isSelected = _selectedPaymentMethod == method.name;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method.name;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? method.color.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? method.color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      method.icon,
                      color: isSelected ? method.color : AppColors.textMuted,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        method.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? method.color : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payment Amount',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _paidAmountController.text = widget.total.toStringAsFixed(2);
              },
              child: Text(
                'Pay Full',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _paidAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: _allowPartialPayment,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isValidPayment ? AppColors.success : AppColors.error,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixIcon: Icon(
              Icons.currency_rupee_rounded,
              color: _isValidPayment ? AppColors.success : AppColors.error,
              size: 32,
            ),
            filled: true,
            fillColor:
                _isValidPayment
                    ? AppColors.success.withOpacity(0.05)
                    : AppColors.error.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _isValidPayment ? AppColors.success : AppColors.error,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _isValidPayment ? AppColors.success : AppColors.error,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _isValidPayment ? AppColors.success : AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter payment amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter valid amount';
            }
            if (double.parse(value) <= 0) {
              return 'Amount must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isFullPayment
                    ? Icons.check_circle_rounded
                    : _paidAmount > 0
                    ? Icons.schedule_rounded
                    : Icons.error_rounded,
                color:
                    _isFullPayment
                        ? AppColors.success
                        : _paidAmount > 0
                        ? AppColors.warning
                        : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                _paymentStatus,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _isFullPayment
                          ? AppColors.success
                          : _paidAmount > 0
                          ? AppColors.warning
                          : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Total Amount', widget.total),
          _buildSummaryRow('Paying Now', _paidAmount, color: AppColors.success),
          if (_changeAmount > 0)
            _buildSummaryRow('Change', _changeAmount, color: AppColors.warning),
          if (_dueAmount > 0)
            _buildSummaryRow(
              'Due Amount',
              _dueAmount,
              color: AppColors.error,
              isHighlight: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    Color? color,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textMuted,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessPaymentButton() {
    return CustomButton(
      text: _isProcessing ? 'Processing...' : 'Process Payment',
      onPressed:
          _isValidPayment && !_isProcessing ? _handleProcessPayment : null,
      isLoading: _isProcessing,
      width: double.infinity,
      icon: Icons.payment_rounded,
    );
  }

  Future<void> _handleProcessPayment() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() => _isProcessing = true);

      try {
        // Create payment record
        final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
        final payment = Payment(
          id: '', // Will be set by Firestore
          customerId: widget.customer.id,
          invoiceNumber: invoiceNumber,
          totalAmount: widget.total,
          paidAmount: _paidAmount,
          dueAmount: _dueAmount,
          paymentMethod: _selectedPaymentMethod,
          paymentDate: DateTime.now(),
          status: _isFullPayment ? 'paid' : 'partial',
        );

        // Save complete sale to database
        final saleId = await DatabaseService.saveSale(
          customer: widget.customer,
          billItems: widget.billItems,
          payment: payment,
          invoiceNumber: invoiceNumber,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sale saved successfully! ID: $saleId',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // ✅ FIXED: Proper BillPreviewScreen constructor call
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BillPreviewScreen(
                    customer: widget.customer,
                    billItems: widget.billItems,
                    total: widget.total,
                    paidAmount: _paidAmount,
                    paymentMethod: _selectedPaymentMethod,
                    changeAmount: _changeAmount,
                    dueAmount: _dueAmount,
                    payment: payment.copyWith(id: saleId),
                  ), // ✅ Fixed: Added missing closing parenthesis here
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save sale: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod({required this.name, required this.icon, required this.color});
}
