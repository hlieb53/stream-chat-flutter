import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

/// It shows the current [Channel] name using a [Text] widget.
///
/// The widget uses a [StreamBuilder] to render the channel information
/// image as soon as it updates.
class ChannelName extends StatelessWidget {
  /// Instantiate a new ChannelName
  const ChannelName({
    Key? key,
    this.textStyle,
    this.textOverflow = TextOverflow.ellipsis,
  }) : super(key: key);

  /// The style of the text displayed
  final TextStyle? textStyle;

  /// How visual overflow should be handled.
  final TextOverflow textOverflow;

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context);
    final channel = StreamChannel.of(context).channel;

    return BetterStreamBuilder<Map<String, Object?>>(
      stream: channel.extraDataStream,
      initialData: channel.extraData,
      builder: (context, snapshot) => _buildName(
        snapshot,
        channel.state?.members,
        client,
      ),
    );
  }

  Widget _buildName(
    Map<String, dynamic> extraData,
    List<Member>? members,
    StreamChatState client,
  ) =>
      LayoutBuilder(
        builder: (context, constraints) {
          var title = 'No title';
          if (extraData['name'] == null) {
            final otherMembers =
                members?.where((member) => member.userId != client.user!.id);
            if (otherMembers?.length == 1) {
              if (otherMembers!.first.user != null) {
                title = otherMembers.first.user!.name;
              }
            } else if (otherMembers?.isNotEmpty == true) {
              final maxWidth = constraints.maxWidth;
              final maxChars = maxWidth / (textStyle?.fontSize ?? 1);
              var currentChars = 0;
              final currentMembers = <Member>[];
              otherMembers!.forEach((element) {
                final newLength =
                    currentChars + (element.user?.name.length ?? 0);
                if (newLength < maxChars) {
                  currentChars = newLength;
                  currentMembers.add(element);
                }
              });

              final exceedingMembers =
                  otherMembers.length - currentMembers.length;
              title = '${currentMembers.map((e) => e.user?.name).join(', ')} '
                  '${exceedingMembers > 0 ? '+ $exceedingMembers' : ''}';
            }
          } else {
            title = extraData['name'];
          }

          return Text(
            title,
            style: textStyle,
            overflow: textOverflow,
          );
        },
      );
}
