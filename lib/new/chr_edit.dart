import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/tsoh_game.dart';

class ChrEdit extends StatelessWidget {
  final TsohGame game;

  const ChrEdit({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const textColor = Color.fromRGBO(0, 0, 0, 1.0);
    const bgColor = Color.fromRGBO(224, 223, 223, 1);

    return MaterialApp(
      home: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(game.canvasSize.x * 0.48, 30, 80, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: game.nameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 22),
                  decoration: InputDecoration(labelText: game.trName),
                  maxLength: 10,
                  showCursor: true,
                  autofocus: true,
                ),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      game.nextChr?.call();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: bgColor),
                    child: const Text(
                      '\u27A5',
                      style: TextStyle(fontSize: 22.0, color: textColor),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          game.chr = UserCommon(name: "", outfit: 0);
                          game.overlays.remove('chr-edit');
                          game.router.popUntilNamed('start');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor,
                        ),
                        child: Text(
                          game.trBack!,
                          style: TextStyle(fontSize: 14.0, color: textColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          if (game.nameController.text.isNotEmpty) {
                            final common = game.chr.copyWith(
                              name: game.nameController.text,
                            );
                            if (game.net.isConnected()) {
                              game.net.newUserData(common);
                              game.net.userData = UserData(
                                name: common.name,
                                outfit: common.outfit,
                                isFlip: true,
                                weapon: WeaponType.none.index,
                                gridX: 0,
                                gridY: 0,
                              );
                            }
                            game.chr = common;
                            game.overlays.remove('chr-edit');
                            game.router.pushNamed('level');
                          } else {
                            Fluttertoast.showToast(
                              msg: game.trChrName!,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                124,
                                114,
                              ),
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor,
                        ),
                        child: Text(
                          game.trGameStart!,
                          style: TextStyle(fontSize: 14.0, color: textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
