import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String purpose;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onSuccess;

  const PaymentScreen({
    super.key, 
    required this.amount, 
    required this.purpose,
    this.metadata,
    this.onSuccess,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);
    try {
      // 1. Initiate Payment
      final orderData = await ref.read(paymentServiceProvider).initiatePayment(
        amount: widget.amount,
        purpose: widget.purpose,
        metadata: widget.metadata,
      );

      final orderId = orderData['order_id'];
      
      // 2. Mock Payment Gateway Interaction
      // In a real app, you would open Razorpay/Stripe SDK here
      await _mockPaymentGateway(orderId);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _mockPaymentGateway(String orderId) async {
    // Simulate user interaction
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Gateway (Mock)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paying ₹${widget.amount}'),
            const SizedBox(height: 10),
            const Text('Select Payment Method:'),
            const SizedBox(height: 10),
             const ListTile(leading: Icon(Icons.credit_card), title: Text('Card **** 4242')),
             const ListTile(leading: Icon(Icons.account_balance), title: Text('UPI / Netbanking')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.pop(context); // Cancel
               throw Exception('User cancelled payment');
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Success
            child: const Text('Pay Now'),
          ),
        ],
      ),
    ).then((success) async {
       if (success == true) {
         // 3. Verify Payment
         try {
           await ref.read(paymentServiceProvider).verifyPayment(
             paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
             orderId: orderId,
             signature: 'mock_signature',
           );
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
             widget.onSuccess?.call();
             Navigator.pop(context); // Close payment screen
           }
         } catch (e) {
           throw Exception('Verification failed: $e');
         }
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.payment, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              Text(
                'Amount to Pay',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '₹${widget.amount}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'For: ${widget.purpose}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _startPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('PROCEED TO PAY', style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
