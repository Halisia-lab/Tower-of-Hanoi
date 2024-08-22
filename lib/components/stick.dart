import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/disk.dart';

//permettre de gagner aussi sur la tour du milieu
//ne pas bouger le même 2 fois de suite 

class Stick extends StatefulWidget {
  final String name;
  final List<int> diskNumbers;
  final Function startGame;
  final Function onDragEnd;
  final bool gamePaused;
  const Stick({
    super.key,
    required this.name,
    required this.diskNumbers,
    required this.startGame,
    required this.onDragEnd,
    required this.gamePaused
  });

  @override
  State<Stick> createState() => _StickState();
}

late Stick currentSource;

class _StickState extends State<Stick> {
  updateCurrentSource(Stick newSource) {
    setState(() {
      currentSource = newSource;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        DragTarget<int>(
          onWillAcceptWithDetails: (disk) {
            if (widget.diskNumbers.isEmpty) return true;
            return widget.diskNumbers.first > disk.data;
          },
          onAcceptWithDetails: (data) {
            widget.onDragEnd(data.data, currentSource, widget);
          },
          builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return SizedBox(
             
              width: 125,
            
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    SizedBox(
                   height:  500,
                      child: Image.asset("assets/images/poteau.png", fit:BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom:25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (var element in widget.diskNumbers)
                            Draggable<int>(
                              onDragStarted: () {
                                widget.startGame();
                                updateCurrentSource(widget);
                              },
                              childWhenDragging: const SizedBox.shrink(),
                              data: element,
                              maxSimultaneousDrags:
                                  element == widget.diskNumbers.first && !widget.gamePaused ? 1 : 0,
                              feedback: Material(borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: Disk(
                                  number: element,
                            isFeedback: true,
                                ),
                              ),
                              child: Disk(
                                number: element,
                                isFeedback: false,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
            );
          },
        ),
      ],
    );
  }
}
