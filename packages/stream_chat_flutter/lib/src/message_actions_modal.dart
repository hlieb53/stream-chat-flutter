import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/src/message_action.dart';
import 'package:stream_chat_flutter/src/reaction_picker.dart';
import 'package:stream_chat_flutter/src/stream_svg_icon.dart';
import 'package:stream_chat_flutter/src/theme/themes.dart';
import 'package:stream_chat_flutter/src/utils.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Constructs a modal with actions for a message
class MessageActionsModal extends StatefulWidget {
  /// Constructor for creating a [MessageActionsModal] widget
  const MessageActionsModal({
    Key? key,
    required this.message,
    required this.messageWidget,
    required this.messageTheme,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.onReplyTap,
    this.onThreadReplyTap,
    this.showCopyMessage = true,
    this.showReplyMessage = true,
    this.showResendMessage = true,
    this.showThreadReplyMessage = true,
    this.showFlagButton = true,
    this.showPinButton = true,
    this.editMessageInputBuilder,
    this.reverse = false,
    this.customActions = const [],
    this.onCopyTap,
  }) : super(key: key);

  /// Widget that shows the message
  final Widget messageWidget;

  /// Builder for edit message
  final Widget Function(BuildContext, Message)? editMessageInputBuilder;

  /// Callback for when thread reply is tapped
  final OnMessageTap? onThreadReplyTap;

  /// Callback for when reply is tapped
  final OnMessageTap? onReplyTap;

  /// Message in focus for actions
  final Message message;

  /// [MessageTheme] for message
  final MessageTheme messageTheme;

  /// Flag for showing reactions
  final bool showReactions;

  /// Callback when copy is tapped
  final OnMessageTap? onCopyTap;

  /// Callback when delete is tapped
  final bool showDeleteMessage;

  /// Flag for showing copy action
  final bool showCopyMessage;

  /// Flag for showing edit action
  final bool showEditMessage;

  /// Flag for showing resend action
  final bool showResendMessage;

  /// Flag for showing reply action
  final bool showReplyMessage;

  /// Flag for showing thread reply action
  final bool showThreadReplyMessage;

  /// Flag for showing flag action
  final bool showFlagButton;

  /// Flag for showing pin action
  final bool showPinButton;

  /// Flag for reversing message
  final bool reverse;

  /// List of custom actions
  final List<MessageAction> customActions;

  @override
  _MessageActionsModalState createState() => _MessageActionsModalState();
}

class _MessageActionsModalState extends State<MessageActionsModal> {
  bool _showActions = true;

  @override
  Widget build(BuildContext context) => _showMessageOptionsModal();

  Widget _showMessageOptionsModal() {
    final mediaQueryData = MediaQuery.of(context);
    final size = mediaQueryData.size;
    final user = StreamChat.of(context).currentUser;

    final roughMaxSize = 2 * size.width / 3;
    var messageTextLength = widget.message.text!.length;
    if (widget.message.quotedMessage != null) {
      var quotedMessageLength =
          (widget.message.quotedMessage!.text?.length ?? 0) + 40;
      if (widget.message.quotedMessage!.attachments.isNotEmpty) {
        quotedMessageLength += 40;
      }
      if (quotedMessageLength > messageTextLength) {
        messageTextLength = quotedMessageLength;
      }
    }
    final roughSentenceSize = messageTextLength *
        (widget.messageTheme.messageText?.fontSize ?? 1) *
        1.2;
    final divFactor = widget.message.attachments.isNotEmpty == true
        ? 1
        : (roughSentenceSize == 0 ? 1 : (roughSentenceSize / roughMaxSize));

    final streamChatThemeData = StreamChatTheme.of(context);

    final numberOfReactions = streamChatThemeData.reactionIcons.length;
    final shiftFactor =
        numberOfReactions < 5 ? (5 - numberOfReactions) * 0.1 : 0.0;

    final child = Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: widget.reverse
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.showReactions &&
                  (widget.message.status == MessageSendingStatus.sent))
                Align(
                  alignment: Alignment(
                      user?.id == widget.message.user?.id
                          ? (divFactor >= 1.0
                              ? -0.2 - shiftFactor
                              : (1.2 - divFactor))
                          : (divFactor >= 1.0
                              ? 0.2 + shiftFactor
                              : -(1.2 - divFactor)),
                      0),
                  child: ReactionPicker(
                    message: widget.message,
                  ),
                ),
              const SizedBox(height: 8),
              IgnorePointer(
                child: widget.messageWidget,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(
                  left: widget.reverse ? 0 : 40,
                ),
                child: SizedBox(
                  width: mediaQueryData.size.width * 0.75,
                  child: Material(
                    color: streamChatThemeData.colorTheme.appBg,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.showReplyMessage &&
                            widget.message.status == MessageSendingStatus.sent)
                          _buildReplyButton(context),
                        if (widget.showThreadReplyMessage &&
                            (widget.message.status ==
                                MessageSendingStatus.sent) &&
                            widget.message.parentId == null)
                          _buildThreadReplyButton(context),
                        if (widget.showResendMessage)
                          _buildResendMessage(context),
                        if (widget.showEditMessage) _buildEditMessage(context),
                        if (widget.showCopyMessage) _buildCopyButton(context),
                        if (widget.showFlagButton) _buildFlagButton(context),
                        if (widget.showPinButton) _buildPinButton(context),
                        if (widget.showDeleteMessage)
                          _buildDeleteButton(context),
                        ...widget.customActions
                            .map((action) => _buildCustomAction(
                                  context,
                                  action,
                                ))
                      ].insertBetween(
                        Container(
                          height: 1,
                          color: streamChatThemeData.colorTheme.borders,
                        ),
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
                color: streamChatThemeData.colorTheme.overlay,
              ),
            ),
          ),
          if (_showActions)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              builder: (context, val, child) => Transform.scale(
                scale: val,
                child: child,
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  InkWell _buildCustomAction(
    BuildContext context,
    MessageAction messageAction,
  ) =>
      InkWell(
        onTap: () {
          messageAction.onTap?.call(widget.message);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          child: Row(
            children: [
              messageAction.leading ?? const Offstage(),
              const SizedBox(width: 16),
              messageAction.title ?? const Offstage(),
            ],
          ),
        ),
      );

  void _showFlagDialog() async {
    final client = StreamChat.of(context).client;

    final streamChatThemeData = StreamChatTheme.of(context);
    final answer = await showConfirmationDialog(
      context,
      title: 'Flag Message',
      icon: StreamSvgIcon.flag(
        color: streamChatThemeData.colorTheme.accentError,
        size: 24,
      ),
      question:
          // ignore: lines_longer_than_80_chars
          'Do you want to send a copy of this message to a\nmoderator for further investigation?',
      okText: 'FLAG',
      cancelText: 'CANCEL',
    );

    final theme = streamChatThemeData;
    if (answer == true) {
      try {
        await client.flagMessage(widget.message.id);
        await showInfoDialog(
          context,
          icon: StreamSvgIcon.flag(
            color: theme.colorTheme.accentError,
            size: 24,
          ),
          details: 'The message has been reported to a moderator.',
          title: 'Message flagged',
          okText: 'OK',
        );
      } catch (err) {
        if (err is StreamChatNetworkError &&
            err.errorCode == ChatErrorCode.inputError) {
          await showInfoDialog(
            context,
            icon: StreamSvgIcon.flag(
              color: theme.colorTheme.accentError,
              size: 24,
            ),
            details: 'The message has been reported to a moderator.',
            title: 'Message flagged',
            okText: 'OK',
          );
        } else {
          _showErrorAlert();
        }
      }
    }
  }

  void _togglePin() async {
    final channel = StreamChannel.of(context).channel;

    Navigator.pop(context);
    try {
      if (!widget.message.pinned) {
        await channel.pinMessage(widget.message);
      } else {
        await channel.unpinMessage(widget.message);
      }
    } catch (e) {
      _showErrorAlert();
    }
  }

  void _showDeleteDialog() async {
    setState(() {
      _showActions = false;
    });
    final answer = await showConfirmationDialog(
      context,
      title: 'Delete message',
      icon: StreamSvgIcon.flag(
        color: StreamChatTheme.of(context).colorTheme.accentError,
        size: 24,
      ),
      question: 'Are you sure you want to permanently delete this\nmessage?',
      okText: 'DELETE',
      cancelText: 'CANCEL',
    );

    if (answer == true) {
      try {
        Navigator.pop(context);
        await StreamChannel.of(context).channel.deleteMessage(widget.message);
      } catch (err) {
        _showErrorAlert();
      }
    } else {
      setState(() {
        _showActions = true;
      });
    }
  }

  void _showErrorAlert() {
    showInfoDialog(
      context,
      icon: StreamSvgIcon.error(
        color: StreamChatTheme.of(context).colorTheme.accentError,
        size: 24,
      ),
      details: 'The operation couldn\'t be completed.',
      title: 'Something went wrong',
      okText: 'OK',
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (widget.onReplyTap != null) {
          widget.onReplyTap!(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.reply(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              'Reply',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: _showFlagDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.iconFlag(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              'Flag Message',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: _togglePin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.pin(
              color: streamChatThemeData.primaryIconTheme.color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              '${widget.message.pinned ? 'Unpin from' : 'Pin to'} Conversation',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isDeleteFailed =
        widget.message.status == MessageSendingStatus.failed_delete;
    return InkWell(
      onTap: _showDeleteDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.delete(
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            Text(
              isDeleteFailed ? 'Retry Deleting Message' : 'Delete Message',
              style: StreamChatTheme.of(context)
                  .textTheme
                  .body
                  .copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () async {
        widget.onCopyTap?.call(widget.message);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.copy(
              size: 24,
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              'Copy Message',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMessage(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        _showEditBottomSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.edit(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              'Edit Message',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendMessage(BuildContext context) {
    final isUpdateFailed =
        widget.message.status == MessageSendingStatus.failed_update;
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        final channel = StreamChannel.of(context).channel;
        if (isUpdateFailed) {
          channel.updateMessage(widget.message);
        } else {
          channel.sendMessage(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.circleUp(
              color: streamChatThemeData.colorTheme.accentPrimary,
            ),
            const SizedBox(width: 16),
            Text(
              isUpdateFailed ? 'Resend Edited Message' : 'Resend',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    final streamChatThemeData = StreamChatTheme.of(context);
    showModalBottomSheet(
      context: context,
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      backgroundColor: streamChatThemeData.messageInputTheme.inputBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StreamChannel(
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
                      padding: const EdgeInsets.all(8),
                      child: StreamSvgIcon.edit(
                        color: streamChatThemeData.colorTheme.disabled,
                      ),
                    ),
                    const Text(
                      'Edit Message',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: StreamSvgIcon.closeSmall(),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
              ),
              if (widget.editMessageInputBuilder != null)
                widget.editMessageInputBuilder!(context, widget.message)
              else
                MessageInput(
                  editMessage: widget.message,
                  preMessageSending: (m) {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    return m;
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreadReplyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (widget.onThreadReplyTap != null) {
          widget.onThreadReplyTap!(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.thread(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              'Thread Reply',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}
