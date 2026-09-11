import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

/// Google sign-in button styled to match Google's brand guidelines
/// (white background, subtle border, colored "G" logo placeholder icon).
class SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialSignInButton({super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // Swap for a real Google "G" SVG asset in assets/icons/google_logo.svg
                  Icon(Icons.g_mobiledata, size: 26, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
