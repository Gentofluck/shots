import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../api/client.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<HotKey> onHotKeyRecorded;
  final Function(String) changePage;
  final ShotsClient shotsClient;

  HomePage({
    required this.changePage,
    required this.onHotKeyRecorded,
    required this.shotsClient,
    super.key,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFF3EFEF)),
      child: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icon.svg',
                height: 80,
                width: 80,
              ),
              SizedBox(height: 20),
              GestureDetector(
                child: Container(
                  height: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      Text(
                        "Выберите сочетание клавиш",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                      HotKeyRecorder(
                        onHotKeyRecorded: (hotKey) {
                          setState(() {
                            _hotKey = hotKey;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4AA37C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    ),
                    onPressed: () {
                      if (_hotKey != null) {
                        widget.onHotKeyRecorded(_hotKey!);
                        widget.changePage("screenshotPage");
                      }
                    },
                    child: Text(
                      "Сохранить настройки",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
