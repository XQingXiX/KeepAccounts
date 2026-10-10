import 'package:flutter/material.dart';

//<AI> 此部分用于添加条目
class Add extends StatefulWidget {
  const Add({
    super.key,
    this.initialAmount,
    this.initialNote,
    this.initialCategory,
    this.col,
  });
  final double? initialAmount;
  final String? initialNote;
  final String? initialCategory;
  final Color? col;
  @override
  State<Add> createState() => _Add();
}

class _Add extends State<Add> {
  final money = TextEditingController();
  final note = TextEditingController();

  String moneyHint = '输入金额';
  String noteHint = '默认：无描述';
  String category = '其他';
  List<String> categories = ['三餐', '零食', '收入', '其他'];
  Color clr = Colors.white;
  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      money.text = widget.initialAmount!.toString();
    }
    if (widget.initialNote != null) {
      note.text = widget.initialNote!;
    }
    if (widget.initialCategory != null) {
      category = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    money.dispose();
    note.dispose();
    super.dispose();
  }

  void _submit() {
    final moneyText = money.text.trim();
    if (moneyText.isEmpty) {
      setState(() {
        money.clear();
        moneyHint = '请 输 入 金 额 (👁)❗';
        clr = Colors.red;
      });
      return;
    }
    final amount = double.tryParse(moneyText);
    if (amount == null) {
      setState(() {
        money.clear();
        moneyHint = '请输入有效金额';
        clr = Colors.red;
      });
      return;
    }
    if (amount >= 2147483647) {
      setState(() {
        money.clear();
        moneyHint = '666这么富V我50';
        clr = Colors.red;
      });
      return;
    }
    final noteText = note.text.trim();
    final finalNote = noteText.isEmpty ? '无描述' : noteText;
    Navigator.pop(context, {
      'amount': amount,
      'note': finalNote,
      'category': category,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: widget.col,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade50),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          //这段SingleChildScrollView是AI提出的修改，为了防止页面过小时背景被撑撑爆
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: moneyHint,
                  hintText: '请输入金额(-开头为消费)',
                  labelStyle: TextStyle(color: clr),
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: note,
                maxLength: 20,

                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: '用途',
                  hintText: '默认：无描述',
                  counterStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              //<AI>
              DropdownButtonFormField<String>(
                initialValue: category,
                isExpanded: true,
                menuMaxHeight: 200,

                borderRadius: BorderRadius.circular(12),

                dropdownColor: widget.col,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                decoration: const InputDecoration(
                  labelText: '分类',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
                items: categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => category = val);
                  }
                },
              ),
              //</AI>
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text('取消'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.col,
                    ),
                    child: Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//</AI>
