import 'package:flutter/material.dart';
import 'package:super_menu/super_menu.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text('Hello World!'),
              SuperMenu(
                addTitleHeader: true,
                backText: 'Back',
                onSelected: (p0) {},
                onSubSelected: (parent, child) {},
                focusNode: focusNode,
                // backgroundColor: Colors.red,
                menuWidth: 200,
                inputButtonBuilder: (onChanged) => SizedBox(
                  width: 150,
                  height: 40,
                  child: TextField(
                    focusNode: focusNode,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      hintText: 'Search',
                    ),
                  ),
                ),
                menuItems: [
                  MenuActionItem(
                    title: 'Item 1',
                    subMenuItems: [
                      MenuActionItem(title: 'Amazing'),
                      MenuActionItem(title: 'Item 1.2'),
                      MenuActionItem(title: 'Item 1.3'),
                    ],
                  ),
                  MenuActionItem(
                    title: 'Item 2',
                    subMenuItems: [
                      MenuActionItem(title: 'Fantasi'),
                      MenuActionItem(title: 'Item 2.2'),
                      MenuActionItem(title: 'Item 2.3'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
