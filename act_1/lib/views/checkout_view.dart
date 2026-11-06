import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

class CheckoutView extends StatefulWidget {
  final CartModel cartModel;

  const CheckoutView({super.key, required this.cartModel});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  void _processOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    widget.cartModel.clearCart();
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: const Text('Thank you for your purchase!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _processOrder,
                child: _isProcessing ? const CircularProgressIndicator() : const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}