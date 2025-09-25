import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                _buildHeader(),
                SizedBox(height: 40),
                _buildSignUpForm(),
                SizedBox(height: 30),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.darkPurple],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Create Account',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.darkPurple,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Join the MEDICULTURE family',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildFullNameField(),
            SizedBox(height: 20),
            _buildEmailField(),
            SizedBox(height: 20),
            _buildPasswordField(),
            SizedBox(height: 20),
            _buildConfirmPasswordField(),
            SizedBox(height: 30),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      validator: Validators.validateName,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person_outline, color: AppColors.darkPurple, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.darkPurple),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.email_outlined, color: AppColors.darkPurple, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.darkPurple),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: Validators.validatePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lock_outline, color: AppColors.darkPurple, size: 20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.darkPurple,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.darkPurple),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      validator: (value) => Validators.validateConfirmPassword(
        _passwordController.text, 
        value,
      ),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lock_outline, color: AppColors.darkPurple, size: 20),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.darkPurple,
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.lightPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.darkPurple),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ),
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
