import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_chat/stream_chat.dart';

import '../stream_chat_flutter.dart';
import 'channel_name.dart';

class ChannelPreview extends StatelessWidget {
  final void Function(Channel) onTap;
  final Channel channel;

  ChannelPreview({
    @required this.channel,
    Key key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap(channel);
      },
      leading: ChannelImage(
        channel: channel,
      ),
      title: ChannelName(
        channel: channel,
      ),
      subtitle: _buildSubtitle(),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildDate(context, channel.lastMessageAt),
        ],
      ),
    );
  }

  Text _buildDate(BuildContext context, DateTime lastMessageAt) {
    String stringDate;
    final now = DateTime.now();

    if (now.year != lastMessageAt.year ||
        now.month != lastMessageAt.month ||
        now.day != lastMessageAt.day) {
      stringDate =
          '${lastMessageAt.day}/${lastMessageAt.month}/${lastMessageAt.year}';
      stringDate = formatDate(lastMessageAt, [dd, '/', mm, '/', yyyy]);
    } else {
      stringDate = '${lastMessageAt.hour}:${lastMessageAt.minute}';
      stringDate = formatDate(lastMessageAt, [HH, ':', nn]);
    }

    return Text(
      stringDate,
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildSubtitle() {
    return StreamBuilder<List<User>>(
        stream: channel.state.typingEventsStream,
        initialData: [],
        builder: (context, snapshot) {
          final typings = snapshot.data;
          final opacity = channel.state.unreadCount > .0 ? 1.0 : 0.5;
          return typings.isNotEmpty
              ? _buildTypings(typings, context, opacity)
              : _buildLastMessage(context, opacity);
        });
  }

  Widget _buildLastMessage(BuildContext context, double opacity) {
    final lastMessage =
        channel.state.messages.isNotEmpty ? channel.state.messages.last : null;
    if (lastMessage == null) {
      return SizedBox();
    }

    final prefix = lastMessage.attachments
        .map((e) {
          if (e.type == 'image') {
            return '📷';
          } else if (e.type == 'video') {
            return '🎬';
          }
          return null;
        })
        .where((e) => e != null)
        .join(' ');

    return Text(
      '$prefix ${lastMessage.text ?? ''}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.caption.copyWith(
            color: Colors.black.withOpacity(opacity),
          ),
    );
  }

  Text _buildTypings(List<User> typings, BuildContext context, double opacity) {
    return Text(
      '${typings.map((u) => u.extraData.containsKey('name') ? u.extraData['name'] : u.id).join(',')} ${typings.length == 1 ? 'is' : 'are'} typing...',
      maxLines: 1,
      style: Theme.of(context).textTheme.caption.copyWith(
            color: Colors.black.withOpacity(opacity),
          ),
    );
  }
}
