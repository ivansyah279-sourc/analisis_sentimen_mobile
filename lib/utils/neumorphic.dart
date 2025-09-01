import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class NeumorphicCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;
  final String buttonText;
  final Color textColor;

  const NeumorphicCustom({
    Key? key,
    required this.onPressed,
    this.color = Colors.green, // Warna default
    this.width = double.infinity, // Lebar default sesuai parent
    this.height = 50, // Tinggi default
    this.buttonText = 'Registration',
    this.textColor = Colors.black, // Teks default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
          depth: 1,
          intensity: 0.8,
          color: color, // Gunakan warna yang diberikan
          shape: NeumorphicShape.flat,
        ),
        child: NeumorphicButton(
          onPressed: onPressed,
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
            depth: -10,
            intensity: 0.8,
            color: color, // Gunakan warna yang diberikan
            shape: NeumorphicShape.flat,
          ),
          child: Center(
            child: Text(
              buttonText, // Gunakan teks yang diberikan
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
