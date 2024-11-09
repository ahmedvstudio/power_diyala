import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;
  final Function() onDelete;

  const QuantitySelector({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  QuantitySelectorState createState() => QuantitySelectorState();
}

class QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    setState(() {
      quantity++;
      widget.onQuantityChanged(quantity);
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        widget.onQuantityChanged(quantity);
      });
    } else {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(
              quantity > 1 ? Icons.remove : Icons.delete,
              size: 16,
            ),
            onPressed: _decreaseQuantity,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            color: quantity > 1
                ? Theme.of(context).colorScheme.primary
                : Colors.red,
          ),
        ),
        Expanded(
          child: Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        Expanded(
          child: IconButton(
            icon: Icon(
              Icons.add,
              size: 16,
            ),
            onPressed: _increaseQuantity,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
