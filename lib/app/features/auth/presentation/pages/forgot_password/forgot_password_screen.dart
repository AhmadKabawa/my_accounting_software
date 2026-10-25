 
import 'package:flutter/material.dart';
 
class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  

 
}
/*
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().sendResetCodeEvent(
        email: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AuthKeys.forgetPassword.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: FieldKeys.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  return AppValidator.validate(value, [
                    ValidationRule.required,
                    ValidationRule.email,
                  ]);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleReset,
                  child: Text(AuthKeys.sendMessage.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/