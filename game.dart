import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'result.dart';

class GamePage extends StatefulWidget {
  final List<String> numbers;
  final String playerName; // 添加一个参数来接收玩家名称

  GamePage({required this.numbers, required this.playerName}); // 修改构造函数

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String selectedNumber = ''; // 修改成空字串

  List<int> receivedNumbersIndices = List.filled(25, 0); // 修改為 25

  late Socket _socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() async {
    try {
      _socket = await Socket.connect('10.201.5.81', 12345);
      print('Connected to server');

      _socket.listen(
        (List<int> data) {
          final message = utf8.decode(data).trim();
          _handleMessage(message);
        },
        onError: (error) {
          print('Error: $error');
          _socket.destroy();
        },
        onDone: () {
          print('Connection closed by server');
          _socket.destroy();
        },
      );
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }

  void _handleMessage(String message) {
    setState(() {
      if (message == 'WIN') {
        // 触发 WIN 逻辑后立即发送 WIN 消息给服务器
        _sendMessage('WIN');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WinPage()), // 導航到 WinPage
        );
      } else if (message == 'LOSE') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LosePage()), // 導航到 LosePage
        );
      } else {
        selectedNumber = message; // 將接收到的字串賦值給 selectedNumber
        int number = int.tryParse(message) ?? -1; // 將字串轉換為整數，如果轉換失敗則設置為 -1
        for (int i = 0; i < 25; i++) {
          // 修改為 25
          if (widget.numbers[i] == message) {
            number = i;
            break;
          }
        }
        print(number);
        if (number >= 0 && number < 25) {
          // 修改為 25
          receivedNumbersIndices[number] = 1; // 將相應的列表索引設置為 1
        }
      }
    });
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      _socket.write(message);
    }
  }

  void _updateNumber(String clickedNumber) {
    if (widget.numbers.contains(clickedNumber)) {
      if (clickedNumber != '待填') {
        _sendMessage(widget.playerName); // 先發送 playerName
        Future.delayed(Duration(milliseconds: 100), () {
          _sendMessage(clickedNumber); // 在延遲之後發送 clickedNumber
        });
        Future.delayed(Duration(milliseconds: 200), () {
          _sendMessage('GET_MAP'); // 在更長的延遲之後發送 'GET_MAP'
        });
      }
    }
  }

  void tobingo() {
    bool win = false;
    bool win1 = false;
    for (int i = 0; i <= 20; i = i + 5) {
      for (int j = 0; j < 4; j++) {
        if (receivedNumbersIndices[i + j] ==
                receivedNumbersIndices[i + j + 1] &&
            receivedNumbersIndices[i + j] == 1)
          win1 = true;
        else {
          win1 = false;
          break;
        }
      }
      if (win1 == true) {
        win = true;
        break;
      }
    }
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j <= 15; j = j + 5) {
        if (receivedNumbersIndices[i + j] ==
                receivedNumbersIndices[i + j + 5] &&
            receivedNumbersIndices[i + j] == 1)
          win1 = true;
        else {
          win1 = false;
          break;
        }
      }
      if (win1 == true) {
        win = true;
        break;
      }
    }
    for (int i = 0; i <= 18; i = i + 6) {
      if (receivedNumbersIndices[i] == receivedNumbersIndices[i + 6] &&
          receivedNumbersIndices[i] == 1)
        win1 = true;
      else {
        win1 = false;
        break;
      }
      if (win1 == true) {
        win = true;
        break;
      }
    }
    for (int i = 4; i <= 16; i = i + 4) {
      if (receivedNumbersIndices[i] == receivedNumbersIndices[i + 4] &&
          receivedNumbersIndices[i] == 1)
        win1 = true;
      else {
        win1 = false;
        break;
      }
      if (win1 == true) {
        win = true;
        break;
      }
    }
    if (win == true) {
      print('WIN');
      _sendMessage('WIN'); // 向伺服器發送一個訊息，表示玩家已經獲勝
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('遊戲頁面'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemCount: widget.numbers.length,
        itemBuilder: (context, index) {
          bool isSelectedNumber = receivedNumbersIndices[index] == 1;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedNumber = widget.numbers[index];
              });
              _updateNumber(widget.numbers[index]);
              tobingo(); // 每次選擇後檢查連線是否成功
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
                color: isSelectedNumber ? Colors.green : Colors.lightBlue,
              ),
              child: Center(
                child: Text(
                  widget.numbers[index],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
