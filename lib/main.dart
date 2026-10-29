import 'package:flutter/material.dart';

import 'counter.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Counter Lab',
    theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
    home: const CounterPage(),
  );
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final Counter _counter = Counter();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Counter Lab')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Current count'),
          Text(
            '${_counter.value}',
            key: const ValueKey('counter-value'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                key: const ValueKey('decrement'),
                onPressed: () => setState(_counter.decrement),
                child: const Text('-'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                key: const ValueKey('increment'),
                onPressed: () => setState(_counter.increment),
                child: const Text('+'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                key: const ValueKey('reset'),
                onPressed: () => setState(_counter.reset),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
