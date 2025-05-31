import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsoh/l10n/app_localizations.dart';
import 'package:tsoh/tsoh_game.dart';

class LoadL10n extends StatelessWidget {
  final TsohGame game;

  const LoadL10n({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('kr', ''), // Korean
        Locale('en', ''), // English
      ],
      onGenerateTitle: (context) {
        final cont = AppLocalizations.of(context);
        game.trTitle = cont!.title;
        game.trNewGame = cont.newGame;
        game.trContinue = cont.gameContinue;
        game.trName = cont.name;
        game.trBack = cont.back;
        game.trChrName = cont.chrName;
        game.trGameStart = cont.start;
        game.l10nLoaded();
        return "";
      },
      home: Material(color: Colors.transparent),
    );
  }
}
