import 'package:flutter/material.dart';

class IconContent extends StatelessWidget {
  IconContent({this.icon, this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 15,
        ),
        Icon(
          icon,
          color: Colors.grey[300],
          size: 70,
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[300],
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
