import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EmptyNodesApp());
}

class EmptyNodesApp extends StatelessWidget {
  const EmptyNodesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: SafeArea(child: EmptyNodesExample())),
    );
  }
}

class EmptyNodesExample extends StatefulWidget {
  const EmptyNodesExample({super.key});

  @override
  State<EmptyNodesExample> createState() => _EmptyNodesExampleState();
}

class _EmptyNodesExampleState extends State<EmptyNodesExample> {
  late final FlNodesController _controller;

  @override
  void initState() {
    super.initState();

    _controller = FlNodesController(appVersion: '0.0');

    // register a minimal node prototype with a single editable field
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
          ),
        ],
      ),
    );

    // add two sample nodes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addNode('simple.value', offset: const Offset(-100, -50));
      _controller.addNode('simple.value', offset: const Offset(100, 50));
      // Ensure listeners rebuild (debug overlay) — controller doesn't notify on addNode
      _controller.notifyListeners();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // show a simple popup menu as node context menu
  void _showNodeContextMenu(
    BuildContext context,
    Offset position,
    FlNodesController controller,
    FlNodeDataModel node,
  ) async {
    final choice = await showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
        const PopupMenuItem(value: 'copy', child: Text('Copy')),
        const PopupMenuItem(value: 'cut', child: Text('Cut')),
      ],
    );

    if (choice == 'delete') {
      if (node.state.isSelected) {
        for (final id in controller.selectedNodeIds)
          controller.removeNodeById(id);
      } else {
        controller.removeNodeById(node.id);
      }
      controller.clearSelection();
    } else if (choice == 'copy') {
      controller.clipboard.copySelection(context: context);
    } else if (choice == 'cut') {
      controller.clipboard.cutSelection(context: context);
    }
  }

  // simple canvas menu (add node)
  void _showCanvasContextMenu(
    BuildContext context,
    Offset position,
    FlNodesController controller,
    PortLocator? locator,
  ) async {
    final world = RenderBoxUtils.screenToWorld(
          controller.editorKey,
          position,
          controller.viewportOffset,
          controller.viewportZoom,
        ) ??
        Offset.zero;
    final choice = await showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [const PopupMenuItem(value: 'add', child: Text('Add node'))],
    );
    if (choice == 'add') {
      controller.addNode('simple.value', offset: world);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlNodesShortcutsWidget(
          controller: _controller,
          child: FlNodesWidget(
            controller: _controller,
            nodeBuilder: (node, controller) => FlDefaultNodeWidget(
              controller: controller,
              node: node,
              showPortContextMenu: (ctx, pos, c, locator) {},
              showNodeCreationMenu: (ctx, pos, c, locator, onTmp) {},
              showNodeContextMenu: (ctx, pos, c, node) =>
                  _showNodeContextMenu(ctx, pos, c, node),
            ),
            showPortContextMenu: (ctx, pos, c, locator) {},
            showCanvasContextMenu: (ctx, pos, c, locator) =>
                _showCanvasContextMenu(ctx, pos, c, locator),
            showNodeCreationMenu: (ctx, pos, c, locator, onTmp) {},
            showLinkContextMenu: (ctx, linkId, pos, c) {},
          ),
        ),

        // Debug overlay: shows node count and IDs
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final count = _controller.nodeCount;
                  final ids =
                      _controller.nodesAsList.map((n) => n.id).join(', ');
                  return DefaultTextStyle(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('nodes: $count'),
                        if (count > 0)
                          SizedBox(
                            width: 300,
                            child: Text(
                              ids,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
