import 'dart:io';
import 'package:flutter/material.dart';
import 'game.dart'; // 导入游戏页

class SecondPage extends StatefulWidget {
  final String playerName; // 添加一个名字参数

  SecondPage(this.playerName); // 构造函数接收名字参数
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late Socket socket;
  late List<String> numbers; // 存储圆圈中的数字
  final int gridSize = 5; // 修改为 5

  @override
  void initState() {
    super.initState();
    numbers = List.generate(
        gridSize * gridSize, (index) => '待填'); // 修改为 gridSize * gridSize
  }

  void _updateNumber(int index) {
    // 如果圆圈中的文字为 "待填"，则填充下一个数字
    if (numbers[index] == '待填') {
      // 找到下一个待填的位置
      int nextNumber = 1;
      for (int i = 0; i < numbers.length; i++) {
        if (numbers[i] != '待填') {
          nextNumber++;
        }
      }
      // 填充下一个数字
      setState(() {
        numbers[index] = nextNumber.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '請填入數字',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // 當按鈕被點擊時執行的操作
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(
                                numbers: numbers,
                                playerName:
                                    widget.playerName), // 将当前玩家的名称传递给游戏页
                          ),
                        );
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.5, // 将按钮宽度设置为父级宽度的一半
                        child: Center(
                          child: Text('開始！'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // 垂直间距
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 0), // 调整此处的上边距以向下移动圆圈
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                        ),
                        itemCount: numbers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _updateNumber(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                                color: Colors.lightBlue, // 將顏色設置為亮藍色
                              ),
                              child: Center(
                                child: Text(
                                  numbers[index],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.destroy();
    super.dispose();
  }
}
