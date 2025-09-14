import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/api/client.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<HotKey> onScreenshotHotKeyRecorded;
  final ValueChanged<HotKey> onSendHotKeyRecorded;
  final Function(String) changePage;
  final ShotsClient shotsClient;
  final List<HotKey> registeredHotKeyList;

  const HomePage({
    required this.changePage,
    required this.onScreenshotHotKeyRecorded,
    required this.onSendHotKeyRecorded,
    required this.shotsClient,
    required this.registeredHotKeyList,
    super.key,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HotKey? _screenshotHotKey;
  HotKey? _sendHotKey;
  bool _isRecordingScreenshot = false;
  bool _isRecordingSend = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _screenshotHotKey =
          (widget.registeredHotKeyList.isNotEmpty
              ? widget.registeredHotKeyList.first
              : null);
      _sendHotKey =
          (widget.registeredHotKeyList.isNotEmpty
              ? widget.registeredHotKeyList[1]
              : null);
    });
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _screenshotHotKey =
          (widget.registeredHotKeyList.isNotEmpty
              ? widget.registeredHotKeyList.first
              : null);
      _sendHotKey =
          (widget.registeredHotKeyList.length > 1
              ? widget.registeredHotKeyList[1]
              : null);
    });
  }

  void _startRecordingScreenshot() {
    setState(() {
      _isRecordingScreenshot = true;
      _isRecordingSend = false;
    });
  }

  void _startRecordingSend() {
    setState(() {
      _isRecordingScreenshot = false;
      _isRecordingSend = true;
    });
  }

  Widget _buildHotKeySection({
    required String title,
    required HotKey? currentKey,
    required VoidCallback onStartRecording,
    required bool isRecording,
    required ValueChanged<HotKey> onKeyRecorded,
  }) {
    return GestureDetector(
      onTap: onStartRecording,
      child: Container(
        height: 75,
        width: 228,
        decoration: BoxDecoration(
          color: isRecording ? Colors.grey[200] : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                decoration: TextDecoration.none,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            if (isRecording)
              DefaultTextStyle(
                style: TextStyle(decoration: TextDecoration.none),
                child: HotKeyRecorder(
                  onHotKeyRecorded: (hotKey) {
                    onKeyRecorded(hotKey);
                  },
                ),
              )
            else if (currentKey != null)
              DefaultTextStyle(
                style: TextStyle(decoration: TextDecoration.none),
                child: HotKeyVirtualView(hotKey: currentKey),
              )
            else
              DefaultTextStyle(
                style: TextStyle(decoration: TextDecoration.none),
                child: Text(
                  "Нажмите чтобы записать",
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFF3EFEF)),
      child: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
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
              _buildHotKeySection(
                title: "Создание скриншота",
                currentKey: _screenshotHotKey,
                onStartRecording: _startRecordingScreenshot,
                isRecording: _isRecordingScreenshot,
                onKeyRecorded: (hotKey) {
                  setState(() => _screenshotHotKey = hotKey);
                },
              ),
              SizedBox(height: 10),
              _buildHotKeySection(
                title: "Отправка скриншота",
                currentKey: _sendHotKey,
                onStartRecording: _startRecordingSend,
                isRecording: _isRecordingSend,
                onKeyRecorded: (hotKey) {
                  setState(() => _sendHotKey = hotKey);
                },
              ),

              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF425AD0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: () {
                      if (_screenshotHotKey != null && _sendHotKey != null) {
                        widget.onScreenshotHotKeyRecorded(_screenshotHotKey!);
                        widget.onSendHotKeyRecorded(_sendHotKey!);
                        widget.changePage("screenshotPage");
                      }
                    },
                    child: Text(
                      "Сохранить настройки",
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
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
