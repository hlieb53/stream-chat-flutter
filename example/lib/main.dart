import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> _handleBackgroundNotification(
  Map<String, dynamic> notification,
) async {
  final notificationData = await NotificationService.storeMessage(notification);

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'Message notifications',
    'Message notifications',
    'Channel dedicated to message notifications',
    importance: Importance.Max,
    priority: Priority.High,
  );

  final androidNotificationOptions = AndroidNotificationOptions(
    androidNotificationDetails: androidPlatformChannelSpecifics,
    id: notificationData.message.id.hashCode,
    title:
        'CUSTOM ${notificationData.message.user.name} @ ${notificationData.channel.cid}',
    body: notificationData.message.text,
  );

  await NotificationService.sendNotification(androidNotificationOptions);
}

void main() async {
  final client = Client(
    's2dxdhpxd94g',
    logLevel: Level.INFO,
    notificationHandler: _handleBackgroundNotification,
  );

  await client.setUser(
    User(id: 'super-band-007'),
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoic3VwZXItYmFuZC0wMDcifQ.DlbyHN6nK7jBTJDp6RJOuBJWwnYoy8Zq8208RPL4uLY',
  );

  runApp(MyApp(client));
}

class MyApp extends StatelessWidget {
  final Client client;

  MyApp(this.client);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
        ),
      ),
      home: StreamChat(
        client: client,
        child: ChannelListPage(),
      ),
    );
  }
}

class ChannelListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChannelListView(
        filter: {
          'members': {
            '\$in': [StreamChat.of(context).user.id],
          }
        },
        sort: [SortOption('last_message_at')],
        pagination: PaginationParams(
          limit: 20,
        ),
        channelWidget: ChannelPage(),
      ),
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                MessageListView(
                  threadBuilder: (_, parentMessage) {
                    return ThreadPage(
                      parent: parentMessage,
                    );
                  },
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
                    ),
                    child: TypingIndicator(
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  final Message parent;

  ThreadPage({
    Key key,
    this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThreadHeader(
        parent: parent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
          ),
          if (parent.type != 'deleted')
            MessageInput(
              parentMessage: parent,
            ),
        ],
      ),
    );
  }
}
