import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class QuantitySelector extends StatefulWidget {
  final double initialQuantity;
  final Function(double) onQuantityChanged;
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
  late double quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    setState(() {
      quantity += 1.0;
      widget.onQuantityChanged(quantity);
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1.0) {
      setState(() {
        quantity -= 1.0;
        widget.onQuantityChanged(quantity);
      });
    } else {
      widget.onDelete();
    }
  }

  void _showQuantityInputDialog() async {
    final TextEditingController controller =
        TextEditingController(text: quantity.toString());

    final result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quantity'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Enter Quantity',
              labelStyle:
                  TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 2.0,
                ),
              ),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                final double? newQuantity = double.tryParse(controller.text);
                if (newQuantity != null && newQuantity > 0) {
                  Navigator.of(context).pop(newQuantity);
                }
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        quantity = result;
        widget.onQuantityChanged(quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: IconButton(
              icon: Icon(
                quantity > 1.0 ? Icons.remove : Icons.delete,
                size: 16,
              ),
              onPressed: _decreaseQuantity,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: quantity > 1.0
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red,
            ),
          ),
          GestureDetector(
            onTap: _showQuantityInputDialog,
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
      ),
    );
  }
}
