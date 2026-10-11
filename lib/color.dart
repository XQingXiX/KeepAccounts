import 'package:flutter/material.dart';

const colorList = <Color>[
  Color(0xFFA9A9A9),
  Color(0xFFE9C8C8),
  Color(0xFFD9AAAA),
  Color(0xFFC98F8F),
  Color(0xFFB87C7C),
  Color(0xFFC6B8D8),
  Color(0xFFA99BC2),
  Color(0xFF8E82A8),
  Color(0xFFCBD9E6),
  Color(0xFF99CCFF),
  Color(0xFF8AA8C2),
  Color(0xFFD2DCC9),
  Color(0xFFB6C5A8),
  Color(0xFF9BAE8C),
  Color(0xFF9E9E9E),
  Color(0xFF5F5F5F),
  Color(0xFFD6C7B8),
  Color(0xFFC2B0A0),
  Color(0xFFA8B8B0),
  Color(0xFF7E8A8F),
  Color(0xFFC97A7A),
  Color(0xFFC98A9A),
  Color(0xFF9B86B3),
  Color(0xFF8078A8),
  Color(0xFF7A86B8),
  Color(0xFF6F9BC4),
  Color(0xFF86B6D4),
  Color(0xFF7FB6B6),
  Color(0xFF6FA89B),
  Color(0xFF7FA87F),
  Color(0xFF9BB88A),
  Color(0xFFB5B87F),
  Color(0xFFC9B86F),
  Color(0xFFC9A66F),
  Color(0xFFC98F6F),
  Color(0xFFB87A6F),
  Color(0xFF9B827A),
  Color(0xFF9E9E9E),
  Color(0xFF7F8F9B),
  Color(0xFF4F4F4F),
];

class AddColor extends StatefulWidget {
  const AddColor({this.color, super.key});
  final Color? color;

  @override
  State<AddColor> createState() => _AddColor();
}

class _AddColor extends State<AddColor> {
  late Color _preview;
  @override
  void initState() {
    super.initState();
    _preview = widget.color ?? const Color(0xFF795548);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _preview,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade50),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int row = 0; row < 8; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int col = 0; col < 5; col++)
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _preview = colorList[row * 5 + col];
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorList[row * 5 + col],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _preview),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _preview,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
