// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelState _$ChannelStateFromJson(Map json) {
  return ChannelState(
    channel: json['channel'] == null
        ? null
        : ChannelModel.fromJson((json['channel'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          )),
    messages: (json['messages'] as List<dynamic>)
        .map((e) => Message.fromJson((e as Map?)?.map(
              (k, e) => MapEntry(k as String, e),
            )))
        .toList(),
    members: (json['members'] as List<dynamic>)
        .map((e) => e == null
            ? null
            : Member.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    pinnedMessages: (json['pinned_messages'] as List<dynamic>)
        .map((e) => Message.fromJson((e as Map?)?.map(
              (k, e) => MapEntry(k as String, e),
            )))
        .toList(),
    watcherCount: json['watcher_count'] as int?,
    watchers: (json['watchers'] as List<dynamic>)
        .map((e) => User.fromJson((e as Map?)?.map(
              (k, e) => MapEntry(k as String, e),
            )))
        .toList(),
    read: (json['read'] as List<dynamic>)
        .map((e) => Read.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

Map<String, dynamic> _$ChannelStateToJson(ChannelState instance) =>
    <String, dynamic>{
      'channel': instance.channel?.toJson(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'members': instance.members.map((e) => e?.toJson()).toList(),
      'pinned_messages':
          instance.pinnedMessages.map((e) => e.toJson()).toList(),
      'watcher_count': instance.watcherCount,
      'watchers': instance.watchers.map((e) => e.toJson()).toList(),
      'read': instance.read.map((e) => e.toJson()).toList(),
    };
