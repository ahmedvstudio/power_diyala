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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).cardColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const Column(
                          children: [
                            Icon(Icons.production_quantity_limits_rounded,
                                color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Quantity',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Enter Quantity',
                          labelStyle: TextStyle(
                            color:
                                ThemeControl.errorColor.withValues(alpha: 0.8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
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
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 18.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final double? newQuantity =
                                double.tryParse(controller.text);
                            if (newQuantity != null && newQuantity > 0) {
                              Navigator.of(context).pop(newQuantity);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: const Text('OK',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
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
              constraints: const BoxConstraints(),
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
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(
                Icons.add,
                size: 16,
              ),
              onPressed: _increaseQuantity,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
