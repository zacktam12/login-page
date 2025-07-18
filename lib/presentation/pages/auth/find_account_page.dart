import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/error_utils.dart';
import 'join_facebook_page.dart';

class FindAccountPage extends StatefulWidget {
  const FindAccountPage({super.key});

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isByEmail = false;
  bool _isLoading = false;

  void _toggleSearchType() {
    setState(() {
      _isByEmail = !_isByEmail;
      _controller.clear();
    });
  }

  void _showAccountNotFoundDialog(String input, {required bool isPhone}) {
    final typeText = isPhone ? 'mobile number' : 'email';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "We couldn't find your account. Create a new account?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            "It looks like $input isn’t connected to an account. You can create a new account with this $typeText or try again.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "TRY AGAIN",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const JoinFacebookPage()),
                );
              },
              child: const Text(
                "CREATE NEW ACCOUNT",
                style: TextStyle(
                    color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simulate a search delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      // Simulate not found
      _showAccountNotFoundDialog(
        _controller.text.trim(),
        isPhone: !_isByEmail,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Find your account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isByEmail
                  ? 'Enter your email address.'
                  : 'Enter your mobile number.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: _isByEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _isByEmail ? 'Email' : 'Mobile number',
                  labelStyle: const TextStyle(
                    color: AppColors.hintText,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.inputBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.inputBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.inputFocusBorder, width: 1),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _isByEmail
                        ? 'Please enter your email.'
                        : 'Please enter your mobile number.';
                  }
                  if (_isByEmail && !value.contains('@')) {
                    return 'Enter a valid email address.';
                  }
                  if (!_isByEmail && value.length < 7) {
                    return 'Enter a valid mobile number.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isByEmail
                  ? 'You may receive WhatsApp and SMS notifications from us for security and login purposes.'
                  : 'You may receive WhatsApp and SMS notifications from us for security and login purposes.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.facebookBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  // Keep color even when disabled
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.facebookBlue,
                ),
                onPressed: _isLoading ? () {} : _handleContinue,
                child: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _toggleSearchType,
                child: Text(
                  _isByEmail
                      ? 'Search by mobile number instead'
                      : 'Search by email instead',
                  style: const TextStyle(
                      color: AppColors.facebookBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
