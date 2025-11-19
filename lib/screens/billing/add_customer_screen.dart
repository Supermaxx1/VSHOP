import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../models/customer_model.dart';
import 'billing_panel_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCustomerType = 'regular';
  bool _isLoading = false;

  final List<Map<String, String>> _customerTypes = [
    {'value': 'regular', 'label': 'Regular Customer'},
    {'value': 'vip', 'label': 'VIP Customer'},
    {'value': 'wholesale', 'label': 'Wholesale Customer'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Customer',
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Customer',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Add customer details to start billing',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Required Fields Section
              Text(
                'Required Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Customer Name
              CustomTextField(
                controller: _nameController,
                hintText: 'Customer Name *',
                prefixIcon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              CustomTextField(
                controller: _phoneController,
                hintText: 'Phone Number *',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Customer Type Selection
              Text(
                'Customer Type',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCustomerType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCustomerType = newValue!;
                      });
                    },
                    items:
                        _customerTypes.map<DropdownMenuItem<String>>((
                          Map<String, String> type,
                        ) {
                          return DropdownMenuItem<String>(
                            value: type['value'],
                            child: Row(
                              children: [
                                Icon(
                                  type['value'] == 'vip'
                                      ? Icons.star_rounded
                                      : type['value'] == 'wholesale'
                                      ? Icons.business_rounded
                                      : Icons.person_rounded,
                                  color:
                                      type['value'] == 'vip'
                                          ? Colors.orange
                                          : type['value'] == 'wholesale'
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(type['label']!),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Optional Fields Section
              Text(
                'Contact Information (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              CustomTextField(
                controller: _addressController,
                hintText: 'Street Address',
                prefixIcon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // City and State Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      hintText: 'City',
                      prefixIcon: Icons.location_city_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      hintText: 'State',
                      prefixIcon: Icons.map_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pincode
              CustomTextField(
                controller: _pincodeController,
                hintText: 'Pincode',
                prefixIcon: Icons.pin_drop_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              CustomTextField(
                controller: _notesController,
                hintText: 'Additional Notes',
                prefixIcon: Icons.note_add_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.textMuted),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Continue to Billing',
                      isLoading: _isLoading,
                      onPressed: _handleAddCustomer,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddCustomer() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() => _isLoading = true);

      try {
        // Create comprehensive customer object using your model
        final customer = Customer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(), // ✅ Empty string if not provided
          address:
              _addressController.text.trim(), // ✅ Empty string if not provided
          city: _cityController.text.trim(), // ✅ NEW FIELD
          state: _stateController.text.trim(), // ✅ NEW FIELD
          pincode: _pincodeController.text.trim(), // ✅ NEW FIELD
          customerType: _selectedCustomerType, // ✅ NEW FIELD
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(), // ✅ NEW FIELD
          createdAt: DateTime.now(),
        );

        // Simulate saving customer (in real app, save to Firebase)
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          // Navigate to billing panel
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BillingPanelScreen(customer: customer),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding customer: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
