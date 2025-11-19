import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductSelectionCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductSelectionCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text('₹${product.price.toStringAsFixed(2)}'),
              const Spacer(),
              Text('Stock: ${product.quantity}'),
            ],
          ),
        ),
      ),
    );
  }
}
