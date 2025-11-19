import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.storefront),
        title: Text(product.name),
        subtitle: Text(
          'Stock: ${product.quantity}\n₹${product.price.toStringAsFixed(2)}',
        ),
        trailing:
            product.isLowStock
                ? const Icon(Icons.warning_amber, color: Colors.orange)
                : null,
      ),
    );
  }
}
