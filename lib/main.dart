//这个程序是我为了记录大学消费和支出写的，并不是为了完整的学习dart,所以说一部分参考了AI代码，
//一部分则直接使用了AI代码，对于setState和StatefulWidget还不是特别熟悉
//完全以AI编写的部分我会以<AI>开头</AI>结束,使用了单句AI生成内容我会使用//AI
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'color.dart';
import 'jsonctrl.dart';
import 'botton.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class _MainApp extends State<MainApp> {
  final rwJson = RwJson();
  List<String> recordLines = [];
  List<String> threemealsLines = [];
  List<String> snackLines = [];
  List<String> otherLines = [];
  List<String> incomeLines = [];
  Color bgcol = Color(0xFF795548);
  String totalLine = '';
  double threemeals = 0;
  double snack = 0;
  double other = 0;
  double income = 0;
  Color? textcol;
  @override
  void initState() {
    super.initState();
    _load();
  }

  //<AI>
  Future<void> _handleLongPress(String line) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 250),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: bgcol,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white70),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('编辑', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              const Divider(color: Colors.white54, height: 1),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == 'delete') {
      await _deleteRecord(line);
    } else if (action == 'edit') {
      await _editRecord(line);
    }
  }

  Future<void> _deleteRecord(String line) async {
    final list = await rwJson.rJson();
    final newList = <dynamic>[];
    bool removed = false;

    for (var item in list) {
      if (!removed && item is Map<String, dynamic>) {
        final r = Record.fromJson(item);
        final rLine = '${r.time}  ${r.text}  ${r.ctrl.toStringAsFixed(2)} 元';
        if (rLine == line) {
          removed = true;
          continue;
        }
      }
      newList.add(item);
    }

    if (removed) {
      await rwJson.wJsonAll(newList);
      _load();
    }
  }

  Future<void> _editRecord(String line) async {
    final list = await rwJson.rJson();
    Record? target;
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        final r = Record.fromJson(item);
        final rLine = '${r.time}  ${r.text}  ${r.ctrl.toStringAsFixed(2)} 元';
        if (rLine == line) {
          target = r;
          break;
        }
      }
    }
    if (target == null) return;
    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => Add(
        initialAmount: target!.ctrl,
        initialNote: target.text,
        initialCategory: target.category,
      ),
    );
    if (result == null) return;

    final newRecord = {
      'time': target.time,
      'ctrl': result['amount'],
      'text': result['note'],
      'exc': result['category'],
    };
    final newList = <dynamic>[];
    bool replaced = false;
    for (var item in list) {
      if (!replaced && item is Map<String, dynamic>) {
        final r = Record.fromJson(item);
        final rLine = '${r.time}  ${r.text}  ${r.ctrl.toStringAsFixed(2)} 元';
        if (rLine == line) {
          newList.add(newRecord);
          replaced = true;
          continue;
        }
      }
      newList.add(item);
    }

    await rwJson.wJsonAll(newList);
    _load();
  }
  //</AI>

  Future<void> _load() async {
    try {
      final bkstr = await RwJson().rConfig();
      final raw = bkstr['colors'];
      final hexStr = (raw is String) ? raw : 'FFFFFFFF';
      final bkhex = int.tryParse(hexStr, radix: 16) ?? 0xFFFFFFFF;
      print('读取到 ${bkhex.toRadixString(16).padLeft(8, '0').toUpperCase()}');
      Color textcolcache = Color(bkhex).computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;
      if (!mounted) return;
      setState(() {
        textcol = textcolcache;
        bgcol = Color(bkhex);
      });
    } catch (e) {
      print('失败：$e');
    }
    try {
      double threemealsSum = 0;
      double snackSum = 0;
      double otherSum = 0;
      double incomeSum = 0;
      final List<String> threemealsTemp = [];
      final List<String> snackTemp = [];
      final List<String> otherTemp = [];
      final List<String> incomeTemp = [];
      final list = await rwJson.rJson();
      final records = list
          .whereType<Map<String, dynamic>>()
          .map(Record.fromJson)
          .toList();
      for (var r in records) {
        final line = '${r.time}  ${r.text}  ${r.ctrl.toStringAsFixed(2)} 元';
        if (r.category == '三餐') {
          threemealsTemp.add(line);
          threemealsSum += r.ctrl;
        } else if (r.category == '零食') {
          snackTemp.add(line);
          snackSum += r.ctrl;
        } else if (r.category == '收入') {
          incomeTemp.add(line);
          incomeSum += r.ctrl;
        } else {
          otherTemp.add(line);
          otherSum += r.ctrl;
        }
      }
      final total = records.fold<double>(0, (sum, r) => sum + r.ctrl);
      final lines = records.map((r) {
        return '${r.time}  ${r.text}  ${r.ctrl} 元';
      }).toList();
      setState(() {
        threemealsLines = threemealsTemp;
        snackLines = snackTemp;
        otherLines = otherTemp;
        incomeLines = incomeTemp;
        income = incomeSum;
        threemeals = threemealsSum;
        snack = snackSum;
        other = otherSum;
        recordLines = lines;
        totalLine = '总额：${total.toStringAsFixed(2)} 元';
      });
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcol,
      appBar: AppBar(
        backgroundColor: bgcol,
        title: Text(
          '记账本',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: textcol,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: Tili(
                        footer: '三餐：${threemeals.toStringAsFixed(2)}',
                        items: threemealsLines,
                        hig: 290,
                        onItemLongPress: _handleLongPress, //AI
                        col: bgcol,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Tili(
                        footer: '零食: ${snack.toStringAsFixed(2)}',
                        items: snackLines,
                        hig: 290,
                        onItemLongPress: _handleLongPress, //AI
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 500),
                      child: Tili(
                        footer: '其他：${other.toStringAsFixed(2)}',
                        items: otherLines,
                        hig: 290,
                        onItemLongPress: _handleLongPress, //AI
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 700),
                      child: Tili(
                        text: '统计',
                        items: incomeLines,
                        getmon: [
                          '三餐: ${threemeals.toStringAsFixed(2)} 元\n零食: ${snack.toStringAsFixed(2)} 元\n其他: ${other.toStringAsFixed(2)} 元',
                        ],
                        footer: totalLine,
                        hig: 290,
                        onItemLongPress: _handleLongPress, //AI
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (ctx) => Add(col: bgcol, textcol: textcol),
                );
                if (result == null) {
                  return;
                }
                final amount = result['amount'] as double;
                final note = result['note'] as String;
                final category = result['category'] as String;
                final record = {
                  'time': DateTime.now().toString().substring(0, 16),
                  'ctrl': amount,
                  'text': note,
                  'exc': category,
                };
                await RwJson().wJson(record);
                _load();
              },
              tooltip: '添加新的内容',
              backgroundColor: textcol ?? Colors.white,
              foregroundColor: bgcol,
              child: const Icon(Icons.add),
            ),
            SizedBox(width: 12),

            FloatingActionButton(
              onPressed: () async {
                final bkcol = await showDialog(
                  context: context,
                  builder: (ctx) => AddColor(color: bgcol),
                );
                if (bkcol == null) return;
                Color textColorFor(Color background) {
                  return background.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white;
                }

                Color textColSS = textColorFor(bkcol);
                setState(() {
                  textcol = textColSS;
                  bgcol = bkcol;
                });
                await RwJson().wConfig(bgcol);
              },
              tooltip: '修改颜色',
              backgroundColor: textcol ?? Colors.white,
              foregroundColor: bgcol,
              child: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainApp();
}

class Tili extends StatelessWidget {
  const Tili({
    super.key,
    this.wid,
    this.hig,
    this.text,
    this.col,
    this.footer,
    this.items,
    this.getmon,
    this.onItemLongPress,
  });
  final void Function(String item)? onItemLongPress;
  final double? wid;
  final double? hig;
  final Color? col;
  final String? text;
  final List<String>? getmon;
  final List<String>? items;
  final String? footer;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: wid ?? double.infinity,
      height: hig,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0x669E9E9E),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: ListView(
                //列表滚动
                padding: EdgeInsets.zero, //奇妙EDGE浏览器(bushi
                children: [
                  for (var a in items ?? <String>[]) ...[
                    Tilitext(
                      text: a,
                      onLongPress: onItemLongPress == null
                          ? null
                          : () => onItemLongPress!(a),
                    ),
                    const SizedBox(height: 5),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          for (var a in getmon ?? <String>[]) ...[
            Tilitext(text: a),
            const SizedBox(height: 5),
          ],
          if (footer != null) Tilitext(text: footer!),
        ],
      ),
    );
  }
}

class Tilitext extends StatelessWidget {
  const Tilitext({this.text, this.onLongPress, super.key});

  final String? text;
  final VoidCallback? onLongPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
        ),
        child: Text(
          '$text',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}

//<AI>
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _show ? Offset.zero : const Offset(0, 1),
      duration: widget.duration,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: _show ? 1.0 : 0.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

//</AI>
class Record {
  const Record({
    required this.time,
    required this.ctrl,
    required this.text,
    required this.category,
  });
  final String time;
  final double ctrl;
  final String text;
  final String category;
  factory Record.fromJson(Map<String, dynamic> json) => Record(
    time: json['time'] as String? ?? '',
    ctrl: (json['ctrl'] as num?)?.toDouble() ?? 0,
    text: json['text'] as String? ?? '',
    category: json['exc'] as String? ?? '其他',
  );
  Map<String, dynamic> toJson() => {
    'time': time,
    'ctrl': ctrl,
    'text': text,
    'exc': category,
  };
}

//<AI>
