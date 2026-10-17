import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/restaurant_detail_provider.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final provider = context.read<RestaurantDetailProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final error = await provider.submitReview(
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
    );

    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Ulasan berhasil dikirim.')),
    );
    if (error == null && mounted) {
      _nameController.clear();
      _reviewController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<RestaurantDetailProvider, bool>(
      (provider) => provider.isSubmitting,
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !isSubmitting,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Nama tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reviewController,
            enabled: !isSubmitting,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Ulasan',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Ulasan tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isSubmitting ? null : _submit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: const Text('Kirim'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
