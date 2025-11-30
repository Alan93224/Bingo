import 'dart:convert';
import 'dart:io';

void main() async {
  final Map<Socket, String> clientNames = {};
  final List<Socket> clients = []; // 用于存储连接的客户端Socket列表
  String selectedNumber = ''; // 用於存儲最新的選擇的數字
  Socket? winnerClient; // 用於存儲贏家的Socket

  try {
    final server = await ServerSocket.bind('0.0.0.0', 12345);
    print('TCP server started at ${server.address}:${server.port}.');

    server.listen(
      (Socket client) {
        print('Client connected: ${client.remoteAddress}:${client.remotePort}');
        clients.add(client);

        client.listen(
          (List<int> data) {
            final message = utf8.decode(data).trim();
            if (message == 'GET_MAP') {
              // Send the latest selected number to all clients
              clients.forEach(
                (client) {
                  client.write(selectedNumber);
                },
              );
              print('Sent selected number to all clients: $selectedNumber');
            } else if (message == 'WIN') {
              // If received message is 'WIN', set winnerClient and print
              print('Received WIN message from ${clientNames[client]}');
              winnerClient = client;
              clients.forEach(
                (client) {
                  if (client == winnerClient) {
                    client.write('WIN');
                  } else {
                    client.write('LOSE');
                  }
                },
              );
            } else if (clientNames[client] == null) {
              clientNames[client] = message;
              print('Client name set as: $message');
            } else {
              selectedNumber = message;
              print('Received number from ${clientNames[client]}: $message');
            }
          },
          onError: (error) {
            print('Error: $error');
            client.close();
          },
          onDone: () {
            print('Client disconnected: ${clientNames[client]}');
            clientNames.remove(client);
            clients.remove(client);
            client.close();
          },
        );
      },
    );
  } catch (e) {
    print('Error starting server: $e');
  }
}
