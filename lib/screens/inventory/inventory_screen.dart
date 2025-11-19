import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/custom_button.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/add_product');
            },
          ),
        ],
      ),
      body:
          inventoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : inventoryProvider.products.isEmpty
              ? const Center(child: Text('No products found.'))
              : ListView.builder(
                itemCount: inventoryProvider.products.length,
                itemBuilder: (context, index) {
                  final product = inventoryProvider.products[index];
                  return ProductCard(product: product);
                },
              ),
      floatingActionButton: CustomButton(
        text: "Add Product",
        icon: Icons.add,
        onPressed: () => Navigator.pushNamed(context, '/add_product'),
        width: 160,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
