import 'package:flutter/material.dart';

import '../../res/colors.dart';
import '../../res/theme.dart';

Widget buildButton({required String title, required Function action}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        minimumSize: const Size.fromHeight(50), // NEW
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
    child: Text(
      title,
      style: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    onPressed: () => action(),
  );
}

WidgetBuilder buildConsumableDialog(
    {required String title, required Function(int) action}) {
  int quantity = 1;
  return (BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            overflow: TextOverflow.clip,
          ),
          StatefulBuilder(builder: (context, state) {
            return Center(
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        state(() {
                          quantity = clampInt(quantity, -1);
                        });
                      },
                      icon: const Icon(Icons.remove),
                      highlightColor: Colors.amberAccent,
                    ),
                    Container(
                      width: 20,
                    ),
                    Text(quantity.toString()),
                    Container(
                      width: 20,
                    ),
                    IconButton(
                      onPressed: () {
                        state(() {
                          quantity = clampInt(quantity, 1);
                        });
                      },
                      icon: const Icon(Icons.add),
                      highlightColor: Colors.amberAccent,
                    )
                  ]),
            );
          })
        ],
      ),
      actions: [
        MaterialButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        MaterialButton(
            child: const Text('Buy'),
            onPressed: () {
              Navigator.of(context).pop();
              action(quantity);
            }),
      ],
    );
  };
}

int clampInt(int original, int add) => (original + add).clamp(1, 10);

WidgetBuilder buildSubscriptionDialog(
    {required String title, required Function action}) {
  return (BuildContext context) {
    return AlertDialog(
      content: Text(
        title,
        style: AppThemes.bodyPrimaryTextTheme,
      ),
      actions: [
        MaterialButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        MaterialButton(
            child: const Text('Subscribe'),
            onPressed: () {
              Navigator.of(context).pop();
              action();
            })
      ],
    );
  };
}
