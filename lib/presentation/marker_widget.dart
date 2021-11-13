import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MarkerWidget extends StatelessWidget {
  const MarkerWidget({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kIsWeb ? 3 : 6),
        border: Border.all(),
        color: const Color.fromRGBO(255, 255, 255, 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bug_report,
            size: kIsWeb ? 6 : 28,
            color: Colors.green,
          ),
          Text(
            name,
            style: kIsWeb
                ? Theme.of(context).textTheme.overline?.copyWith(fontSize: 6)
                : Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
    );
  }
}