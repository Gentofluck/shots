import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_hotKey != null) {
                  widget.onHotKeyRecorded(_hotKey!);
                  widget.changePage("screenshotPage");
                }
              },
              child: const Text("Сохранить настройки"),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus(); 
                    },
                    child: AbsorbPointer(
                      child: HotKeyRecorder(
                        onHotKeyRecorded: (hotKey) {
                          setState(() {
                            _hotKey = hotKey;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
