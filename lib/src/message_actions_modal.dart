import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat/stream_chat.dart';
import 'package:stream_chat_flutter/src/reaction_picker.dart';
import 'package:stream_chat_flutter/src/stream_channel.dart';
import 'package:stream_chat_flutter/src/stream_svg_icon.dart';
import 'package:stream_chat_flutter/src/utils.dart';

import 'message_input.dart';
import 'message_widget.dart';
import 'stream_chat.dart';
import 'stream_chat_theme.dart';

enum ActionsModalState {
  modal,
  confirmDialog,
  dismissMessage,
}

class MessageActionsModal extends StatefulWidget {
  final Widget Function(BuildContext, Message) editMessageInputBuilder;
  final void Function(Message) onThreadReplyTap;
  final void Function(Message) onReplyTap;
  final Message message;
  final MessageTheme messageTheme;
  final bool showReactions;
  final bool showDeleteMessage;
  final bool showCopyMessage;
  final bool showEditMessage;
  final bool showResendMessage;
  final bool showReply;
  final bool showThreadReply;
  final bool showFlagButton;
  final bool reverse;
  final ShapeBorder messageShape;
  final DisplayWidget showUserAvatar;

  const MessageActionsModal({
    Key key,
    @required this.message,
    @required this.messageTheme,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.onReplyTap,
    this.onThreadReplyTap,
    this.showCopyMessage = true,
    this.showReply = true,
    this.showResendMessage = true,
    this.showThreadReply = true,
    this.showFlagButton = true,
    this.showUserAvatar = DisplayWidget.show,
    this.editMessageInputBuilder,
    this.messageShape,
    this.reverse = false,
  }) : super(key: key);

  @override
  _MessageActionsModalState createState() => _MessageActionsModalState();
}

class _MessageActionsModalState extends State<MessageActionsModal> {
  @override
  Widget build(BuildContext context) {
    return _showMessageOptionsModal();
  }

  Widget _showMessageOptionsModal() {
    final size = MediaQuery.of(context).size;
    final user = StreamChat.of(context).user;

    final roughMaxSize = 2 * size.width / 3;
    var messageTextLength = widget.message.text.length;
    if (widget.message.quotedMessage != null) {
      var quotedMessageLength = widget.message.quotedMessage.text.length + 40;
      if (widget.message.quotedMessage.attachments?.isNotEmpty == true) {
        quotedMessageLength += 40;
      }
      if (quotedMessageLength > messageTextLength) {
        messageTextLength = quotedMessageLength;
      }
    }
    final roughSentenceSize =
        messageTextLength * widget.messageTheme.messageText.fontSize * 1.2;
    final divFactor = widget.message.attachments?.isNotEmpty == true
        ? 1
        : (roughSentenceSize == 0 ? 1 : (roughSentenceSize / roughMaxSize));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.maybePop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: Container(
                color: StreamChatTheme.of(context).colorTheme.overlay,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: widget.reverse
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.showReactions &&
                        (widget.message.status == MessageSendingStatus.SENT ||
                            widget.message.status == null))
                      Align(
                        alignment: Alignment(
                            user.id == widget.message.user.id
                                ? (divFactor > 1.0 ? 0.0 : (1.0 - divFactor))
                                : (divFactor > 1.0 ? 0.0 : -(1.0 - divFactor)),
                            0.0),
                        child: ReactionPicker(
                          message: widget.message,
                          messageTheme: widget.messageTheme,
                        ),
                      ),
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300),
                        builder: (context, val, snapshot) {
                          return Transform.scale(
                            scale: val,
                            child: IgnorePointer(
                              child: MessageWidget(
                                key: Key('MessageWidget'),
                                reverse: widget.reverse,
                                message: widget.message.copyWith(
                                  text: widget.message.text.length > 200
                                      ? '${widget.message.text.substring(0, 200)}...'
                                      : widget.message.text,
                                ),
                                messageTheme: widget.messageTheme,
                                showReactions: false,
                                showUsername: false,
                                showThreadReplyIndicator: false,
                                showReplyIndicator: false,
                                showUserAvatar: widget.showUserAvatar,
                                showTimestamp: false,
                                translateUserAvatar: false,
                                showReactionPickerIndicator:
                                    widget.showReactions &&
                                        (widget.message.status ==
                                                MessageSendingStatus.SENT ||
                                            widget.message.status == null),
                                showInChannelIndicator: false,
                                showSendingIndicator: DisplayWidget.gone,
                                shape: widget.messageShape,
                              ),
                            ),
                          );
                        }),
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        builder: (context, val, wid) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..scale(val)
                              ..rotateZ(-1.0 + val),
                            alignment: widget.reverse
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: widget.reverse ? 16 : 0,
                                left: widget.reverse ? 0 : 48,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: Material(
                                  color: StreamChatTheme.of(context)
                                      .colorTheme
                                      .whiteSnow,
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: ListTile.divideTiles(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .greyWhisper,
                                      context: context,
                                      tiles: [
                                        if (widget.showReply &&
                                            (widget.message.status ==
                                                    MessageSendingStatus.SENT ||
                                                widget.message.status ==
                                                    null) &&
                                            widget.message.parentId == null)
                                          _buildReplyButton(context),
                                        if (widget.showThreadReply &&
                                            (widget.message.status ==
                                                    MessageSendingStatus.SENT ||
                                                widget.message.status ==
                                                    null) &&
                                            widget.message.parentId == null)
                                          _buildThreadReplyButton(context),
                                        if (widget.showResendMessage)
                                          _buildResendMessage(context),
                                        if (widget.showEditMessage)
                                          _buildEditMessage(context),
                                        if (widget.showCopyMessage)
                                          _buildCopyButton(context),
                                        if (widget.showFlagButton)
                                          _buildFlagButton(context),
                                        if (widget.showDeleteMessage)
                                          _buildDeleteButton(context),
                                      ],
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFlagDialog() async {
    final client = StreamChat.of(context).client;

    var answer = await showConfirmationDialog(context,
        title: 'Flag Message',
        icon: StreamSvgIcon.flag(
          color: StreamChatTheme.of(context).colorTheme.accentRed,
          size: 24.0,
        ),
        question:
            'Do you want to send a copy of this message to a\nmoderator for further investigation?',
        okText: 'FLAG',
        cancelText: 'CANCEL');

    if (answer) {
      try {
        await client.flagMessage(widget.message.id);
        _showDismissAlert();
      } catch (err) {
        _showErrorAlert();
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _showDismissAlert() {
    showModalBottomSheet(
      backgroundColor: StreamChatTheme.of(context).colorTheme.white,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      )),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 26.0,
            ),
            StreamSvgIcon.flag(
              color: StreamChatTheme.of(context).colorTheme.accentRed,
              size: 24.0,
            ),
            SizedBox(
              height: 26.0,
            ),
            Text(
              'Message flagged',
              style: StreamChatTheme.of(context).textTheme.headlineBold,
            ),
            SizedBox(
              height: 7.0,
            ),
            Text('The message has been reported to a moderator.'),
            SizedBox(
              height: 36.0,
            ),
            Container(
              color:
                  StreamChatTheme.of(context).colorTheme.black.withOpacity(.08),
              height: 1.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color:
                            StreamChatTheme.of(context).colorTheme.accentBlue,
                        fontWeight: FontWeight.w400),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showErrorAlert() {
    showModalBottomSheet(
      backgroundColor: StreamChatTheme.of(context).colorTheme.white,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      )),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 26.0,
            ),
            StreamSvgIcon.error(
              color: StreamChatTheme.of(context).colorTheme.accentRed,
              size: 24.0,
            ),
            SizedBox(
              height: 26.0,
            ),
            Text(
              'Something went wrong',
              style: StreamChatTheme.of(context).textTheme.headlineBold,
            ),
            SizedBox(
              height: 7.0,
            ),
            Text('The operation couldn\'t be completed.'),
            SizedBox(
              height: 36.0,
            ),
            Container(
              color:
                  StreamChatTheme.of(context).colorTheme.black.withOpacity(.08),
              height: 1.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color:
                            StreamChatTheme.of(context).colorTheme.accentBlue,
                        fontWeight: FontWeight.w400),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.reply(
            color: StreamChatTheme.of(context).primaryIconTheme.color,
          ),
          const SizedBox(width: 16),
          Text(
            'Reply',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        if (widget.onReplyTap != null) {
          widget.onReplyTap(widget.message);
        }
      },
    );
  }

  Widget _buildFlagButton(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.icon_flag(
            color: StreamChatTheme.of(context).primaryIconTheme.color,
          ),
          const SizedBox(width: 16),
          Text(
            'Flag',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () {
        _showFlagDialog();
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isDeleteFailed =
        widget.message.status == MessageSendingStatus.FAILED_DELETE;
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.delete(
            color: Colors.red,
          ),
          const SizedBox(width: 16),
          Text(
            isDeleteFailed ? 'Retry Deleting Message' : 'Delete Message',
            style: StreamChatTheme.of(context)
                .textTheme
                .headline
                .copyWith(color: Colors.red),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        StreamChat.of(context).client.deleteMessage(
              widget.message,
              StreamChannel.of(context).channel.cid,
            );
      },
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.copy(
            size: 24,
            color: StreamChatTheme.of(context).primaryIconTheme.color,
          ),
          const SizedBox(width: 16),
          Text(
            'Copy Message',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.message.text));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEditMessage(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.edit(
            color: StreamChatTheme.of(context).primaryIconTheme.color,
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Message',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () async {
        Navigator.pop(context);
        _showEditBottomSheet(context);
      },
    );
  }

  Widget _buildResendMessage(BuildContext context) {
    final isUpdateFailed =
        widget.message.status == MessageSendingStatus.FAILED_UPDATE;
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.circle_up(
            color: StreamChatTheme.of(context).colorTheme.accentBlue,
          ),
          const SizedBox(width: 16),
          Text(
            isUpdateFailed ? 'Resend Edited Message' : 'Resend',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        final client = StreamChat.of(context).client;
        final channel = StreamChannel.of(context).channel;
        if (isUpdateFailed) {
          client.updateMessage(widget.message, channel.cid);
        } else {
          channel.sendMessage(widget.message);
        }
      },
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    showModalBottomSheet(
      context: context,
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      backgroundColor: StreamChatTheme.of(context).colorTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return StreamChannel(
          channel: channel,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamSvgIcon.edit(
                        color: StreamChatTheme.of(context)
                            .colorTheme
                            .greyGainsboro,
                      ),
                    ),
                    Text(
                      'Edit Message',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: StreamSvgIcon.close_small(),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: widget.editMessageInputBuilder != null
                    ? widget.editMessageInputBuilder(context, widget.message)
                    : MessageInput(
                        editMessage: widget.message,
                        preMessageSending: (m) {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                          return m;
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThreadReplyButton(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          StreamSvgIcon.thread(
            color: StreamChatTheme.of(context).primaryIconTheme.color,
          ),
          const SizedBox(width: 16),
          Text(
            'Thread Reply',
            style: StreamChatTheme.of(context).textTheme.headline,
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        if (widget.onThreadReplyTap != null) {
          widget.onThreadReplyTap(widget.message);
        }
      },
    );
  }
}
