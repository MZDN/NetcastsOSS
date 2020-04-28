import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:hear2learn/app.dart';
import 'package:hear2learn/models/episode.dart';
import 'package:hear2learn/redux/actions.dart';
import 'package:hear2learn/redux/selectors.dart';
import 'package:hear2learn/redux/state.dart';
import 'package:hear2learn/widgets/common/episode_tile.dart';
import 'package:hear2learn/widgets/common/circular_progress_with_optional_action.dart';
import 'package:hear2learn/widgets/episode/index.dart';

class EpisodeTileConnector extends StatelessWidget {
  final Episode episode;
  final EpisodeQueue episodeQueue;
  final bool isSelected;
  final bool selectOnTap;
  final Function subtitleProvider;
  final Function toggleEpisodeSelection;

  const EpisodeTileConnector({
    Key key,
    this.episode,
    this.episodeQueue,
    this.isSelected,
    this.selectOnTap,
    this.subtitleProvider,
    this.toggleEpisodeSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Episode>(
      converter: getEpisodeSelector(episode),
      builder: episodeTileBuilder,
    );
  }

  Widget episodeTileBuilder(BuildContext context, Episode episode) {
    final Function subtitleProvider = this.subtitleProvider ?? (Episode episodeToSubtitle) => episodeToSubtitle.getMetaLine();
    return EpisodeTile(
      emphasis: !episode.isFinished,
      isSelected: isSelected,
      onTap: selectOnTap ? () => toggleEpisodeSelection(episode) : () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => EpisodePage(episode: episode),
            settings: const RouteSettings(name: EpisodePage.routeName),
          ),
        );
      },
      onLongPress: () => toggleEpisodeSelection(episode),
      options: buildEpisodeOptions(context, episode),
      subtitle: subtitleProvider(episode),
      title: episode.title,
    );
  }

  Widget buildEpisodeOptions(BuildContext context, Episode episode) {
    return CircularProgressWithOptionalAction(
      icon: getEpisodeIcon(episode),
      onPressed: getEpisodeAction(context, episode),
      progress: getEpisodeProgress(episode),
    );
  }

  Icon getEpisodeIcon(Episode episode) {
    const Map<EpisodeStatus, Icon> icons = <EpisodeStatus, Icon>{
      EpisodeStatus.DELETED: Icon(Icons.get_app),
      EpisodeStatus.DOWNLOADED: Icon(Icons.play_arrow),
      EpisodeStatus.DOWNLOADING: Icon(Icons.more_horiz),
      EpisodeStatus.NONE: Icon(Icons.get_app),
      EpisodeStatus.PAUSED: Icon(Icons.play_arrow),
      EpisodeStatus.PLAYING: Icon(Icons.pause),
      EpisodeStatus.PLAYED: Icon(Icons.delete),
    };
    return icons[episode.status];
  }

  Function getEpisodeAction(BuildContext context, Episode episode) {
    final Map<EpisodeStatus, Function> actions = <EpisodeStatus, Function>{
      EpisodeStatus.DELETED: () { onEpisodeDownload(episode, context: context); },
      EpisodeStatus.DOWNLOADED: () { onEpisodePlay(episode); },
      EpisodeStatus.DOWNLOADING: null,
      EpisodeStatus.NONE: () { onEpisodeDownload(episode, context: context); },
      EpisodeStatus.PAUSED: () { onEpisodePlay(episode); },
      EpisodeStatus.PLAYING: () { onEpisodePause(episode); },
      EpisodeStatus.PLAYED: () { onEpisodeDelete(episode, context: context); },
    };
    return actions[episode.status];
  }

  double getEpisodeProgress(Episode episode) {
    const List<EpisodeStatus> WITHOUT_PROGRESS_STATUSES = <EpisodeStatus>[
      EpisodeStatus.NONE,
      EpisodeStatus.DELETED,
      EpisodeStatus.PLAYED,
    ];

    if(WITHOUT_PROGRESS_STATUSES.contains(episode.status)) {
      return null;
    }
    if(episode.status == EpisodeStatus.DOWNLOADING) {
      return episode.progress;
    }
    if((episode.position?.inSeconds ?? 0) > 0) {
      return (episode.position?.inSeconds?.toDouble() ?? 0)
        / (episode.length?.inSeconds?.toDouble() ?? 1);
    }
    return null;
  }

  void onEpisodeDelete(Episode episode, { BuildContext context }) {
    final App app = App();
    app.store.dispatch(deleteEpisode(episode, context: context));
  }

  void onEpisodeDownload(Episode episode, { BuildContext context }) {
    final App app = App();
    app.store.dispatch(downloadEpisode(episode, context: context));
  }

  void onEpisodePause(Episode episode) {
    final App app = App();
    app.store.dispatch(pauseEpisode(episode));
  }

  void onEpisodePlay(Episode episode) {
    final App app = App();
    app.store.dispatch(playEpisode(episode, episodeQueue: episodeQueue));
  }
}
