import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Product Name',
                prefixIcon: Icons.store,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _priceController,
                hintText: 'Sale Price',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _quantityController,
                hintText: 'Quantity',
                prefixIcon: Icons.confirmation_number,
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Save",
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    final product = Product(
                      id: '',
                      name: _nameController.text.trim(),
                      category: 'General',
                      price: double.tryParse(_priceController.text) ?? 0.0,
                      costPrice: 0.0,
                      quantity: int.tryParse(_quantityController.text) ?? 1,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    inventoryProvider.addProduct(product).then((success) {
                      if (success) Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
