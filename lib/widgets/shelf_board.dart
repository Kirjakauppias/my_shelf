import 'package:flutter/material.dart';

class ShelfBoard extends StatelessWidget {
  final bool highlighted;

  const ShelfBoard({super.key, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: double.infinity,
      height: highlighted ? 13 : 10,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlighted
              ? const [Color(0xFFC77C4C), Color(0xFF8E4F2E)]
              : const [Color(0xFF926346), Color(0xFF5C3522)],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFEFB789)
              : const Color(0xFF4A2818),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            color: Color(0xFF3E2114),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
