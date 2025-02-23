import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/player_one_page.dart';
import 'package:raccoon_learning/presentation/home/learning/twoPlayer/player_two_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/two_players_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/pause_dialog.dart';

class DrawPageTwoPlayers extends StatefulWidget {
  final String grade;
  final String operation;
  const DrawPageTwoPlayers({super.key, required this.grade, required this.operation});

  @override
  State<DrawPageTwoPlayers> createState() => _DrawPageTwoPlayersState();
}


class _DrawPageTwoPlayersState extends State<DrawPageTwoPlayers> {
@override
void initState() {
  super.initState();
  Provider.of<TwoPlayersNotifier>(context, listen: false).generateQuestions(widget.grade, widget.operation);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.lightBackground,
    body: Consumer<TwoPlayersNotifier>(
      builder: (context, notifier, child) {
        return Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: PlayerTwoPage(
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: Divider(thickness: 8, color: AppColors.primary)),
                IconButton(
                  onPressed: () async {
                    final result = await showPauseDialog(context);
                    if (result == 'restart') {
                      notifier.generateQuestions(widget.grade, widget.operation);
                    } else if (result == 'exit') {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.pause, color: Colors.green, size: 50),
                ),
                Expanded(child: Divider(thickness: 8, color: AppColors.primary)),
              ],
            ),
            Expanded(
              child: PlayerOnePage(
              ),
            ),
          ],
        );
      },
    ),
  );
}
}