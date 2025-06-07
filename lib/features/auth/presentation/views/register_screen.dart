import 'package:comaslimpio/features/auth/presentation/views/widgets/register_form.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF41A5DE), Color(0xFF226D9A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            ..._buildDecorativeCircles(),
            const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 60, bottom: 24),
                child: RegisterForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(top: -90, left: -14, child: _circle(200)),
      Positioned(top: -90, left: -190, child: _circle(290)),
      Positioned(bottom: -90, right: -14, child: _circle(200)),
      Positioned(bottom: -90, right: -190, child: _circle(290)),
    ];
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}
