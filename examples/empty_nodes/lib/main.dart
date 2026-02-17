import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SimpleNodesApp());

class SimpleNodesApp extends StatelessWidget {
  const SimpleNodesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: SafeArea(child: SimpleNodesWidget())),
    );
  }
}

class SimpleNodesWidget extends StatefulWidget {
  const SimpleNodesWidget({super.key});

  @override
  State<SimpleNodesWidget> createState() => _SimpleNodesWidgetState();
}

class _SimpleNodesWidgetState extends State<SimpleNodesWidget> {
  late final FlNodesController _controller;

  @override
  void initState() {
    super.initState();

    _controller = FlNodesController(appVersion: '0.0');

    _controller.registerNodePrototype(
      FlNodePrototype(
        idName: 'simple.value',
        displayName: (ctx) => 'Value',
        description: (ctx) => 'A simple value node',
        fieldPrototypes: [
          FlFieldPrototype(
            idName: 'value',
            displayName: (ctx) => 'Value',
            dataType: String,
            defaultData: '',
            visualizerBuilder: (data) => Text(
              data?.toString() ?? '',
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            editorBuilder: (context, removeOverlay, data, setData) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: data?.toString() ?? '',
                    onFieldSubmitted: (value) {
                      setData(value, eventType: FlFieldEventType.submit);
                      removeOverlay();
                    },
                    onChanged: (value) =>
                        setData(value, eventType: FlFieldEventType.change),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addNode('simple.value', offset: const Offset(-100, -50));
      _controller.addNode('simple.value', offset: const Offset(100, 50));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlNodesShortcutsWidget(
      controller: _controller,
      child: FlNodesWidget(
        controller: _controller,
        nodeBuilder: (node, controller) => FlDefaultNodeWidget(
          controller: controller,
          node: node,
          showPortContextMenu: (ctx, pos, c, locator) {},
          showNodeCreationMenu: (ctx, pos, c, locator, onTmp) {},
          showNodeContextMenu: (ctx, pos, c, node) {},
        ),
        showPortContextMenu: (ctx, pos, c, locator) {},
        showCanvasContextMenu: (ctx, pos, c, locator) {},
        showNodeCreationMenu: (ctx, pos, c, locator, onTmp) {},
        showLinkContextMenu: (ctx, linkId, pos, c) {},
      ),
    );
  }
}
