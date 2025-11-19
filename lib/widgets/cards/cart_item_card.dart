import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    this.onRemove,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag_outlined),
        title: Text(cartItem.productName),
        subtitle: Text('₹${cartItem.price} × ${cartItem.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (onQuantityChanged != null && cartItem.quantity > 1) {
                  onQuantityChanged!(cartItem.quantity - 1);
                }
              },
            ),
            Text('${cartItem.quantity}'),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                if (onQuantityChanged != null) {
                  onQuantityChanged!(cartItem.quantity + 1);
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
