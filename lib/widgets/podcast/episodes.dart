import 'package:flutter/material.dart';

import 'package:hear2learn/models/episode.dart';
import 'package:hear2learn/redux/actions.dart';
import 'package:hear2learn/widgets/common/episode_list.dart';

class PodcastEpisodesList extends StatelessWidget {
  final List<Episode> episodes;

  const PodcastEpisodesList({
    Key key,
    this.episodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EpisodesList(
      episodes: episodes,
      availableActions: const <ActionType> [ActionType.DOWNLOAD_EPISODE, ActionType.DELETE_EPISODE, ActionType.FINISH_EPISODE, ActionType.UNFINISH_EPISODE],
    );
  }
}
