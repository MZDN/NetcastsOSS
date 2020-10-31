import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

enum EpisodeStatus {
  DOWNLOADED,
  DOWNLOADING,
  NONE,
  PAUSED,
  PLAYING,
  PLAYED,
  DELETED,
}

enum EpisodeQueue {
  PODCAST,
  DOWNLOADS,
}

EpisodeQueue episodeQueueFromString(String enumName) {
  return EpisodeQueue.values.firstWhere((EpisodeQueue episodeQueue) => episodeQueue.toString() == enumName, orElse: () => null);
}

class Episode {
  static const int END_OF_EPISODE_THRESHOLD = 60;

  String description;
  String downloadPath;
  bool isFavorited;
  bool isFinished;
  Duration length;
  String media;
  String podcastTitle;
  String podcastUrl;
  Duration position;
  double progress;
  String pubDate;
  int size;
  EpisodeStatus status;
  String title;
  String url;

  Episode({
    this.description,
    this.downloadPath,
    this.isFavorited = false,
    this.isFinished = false,
    this.length,
    this.media,
    this.podcastTitle,
    this.podcastUrl,
    this.position,
    this.progress,
    this.pubDate,
    this.size,
    this.status = EpisodeStatus.NONE,
    this.title,
    this.url,
  });

  Episode copyWith({
    String description,
    String downloadPath,
    bool isFavorited,
    bool isFinished,
    Duration length,
    String media,
    String podcastTitle,
    String podcastUrl,
    Duration position,
    double progress,
    String pubDate,
    int size,
    EpisodeStatus status,
    String title,
    String url,
  }) {
    return Episode(
      description: description ?? this.description,
      downloadPath: downloadPath ?? this.downloadPath,
      isFavorited: isFavorited ?? this.isFavorited,
      isFinished: isFinished ?? this.isFinished,
      length: length ?? this.length,
      media: media ?? this.media,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      podcastUrl: podcastUrl ?? this.podcastUrl,
      position: position ?? this.position,
      progress: progress ?? this.progress,
      pubDate: pubDate ?? this.pubDate,
      size: size ?? this.size,
      status: status ?? this.status,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  String getFriendlyDate() {
    const String shortFormat = 'EEE, dd MMM yyyy';
    final DateFormat podcastDateFormat = DateFormat(shortFormat);
    return timeago.format(podcastDateFormat.parseLoose(pubDate.substring(0, shortFormat.length)));
  }

  String getMetaLine() {
    String sizeDisplay = '';
    if(size != null) {
      final num sizeInMegabytes = size / 1e6;
      sizeDisplay = 'Size: ' + sizeInMegabytes.toStringAsFixed(2) + ' MB.  ';
    }
    final String dateDisplay = 'Added: ' + getFriendlyDate() + '.';
    return sizeDisplay + dateDisplay;
  }

  String getPlayerDetails() {
    return jsonEncode(<int>[position?.inSeconds ?? 0, length?.inSeconds ?? 0]);
  }

  void setPlayerDetails(String details) {
    final List<dynamic> playerDetails = jsonDecode(details);
    length = Duration(seconds: playerDetails[1]);
    position = Duration(seconds: playerDetails[0]);
  }

  bool isPlaying() {
    return status == EpisodeStatus.PLAYING;
  }

  bool isPlayedToEnd() {
    if(length == null || position == null) {
      return false;
    }
    final Duration remainder = length - position;
    return remainder.inSeconds < END_OF_EPISODE_THRESHOLD;
  }

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'description': description,
      'media': media,
      'podcastTitle': podcastTitle,
      'podcastUrl': podcastUrl,
      'pubDate': pubDate,
      'size': size,
      'title': title,
      'url': url,
    });
  }

  @override
  String toString() {
    return 'Episode[title=$title, pubDate=$pubDate, status=${status.toString()}, size=$size, url=$url, downloadPath=${downloadPath}]';
  }

  @override
  int get hashCode {
    // why is this necessary?
    // implementation based on https://www.dartlang.org/guides/libraries/library-tour#implementing-map-keys
    return 37 * (17 + url.hashCode);
  }

  @override
  bool operator ==(dynamic other) {
    if(other is! Episode) {
      return false;
    }
    return url == other.url;
  }
}
