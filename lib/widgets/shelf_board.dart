import 'package:flutter/material.dart';

class ShelfBoard extends StatelessWidget {
  const ShelfBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF8D6042),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
