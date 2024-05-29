import 'package:flutter/material.dart';

class CustomScrollbar extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> pages;

  CustomScrollbar({required this.tabs, required this.pages});

  @override
  _CustomScrollbarState createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<CustomScrollbar> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _scrollTo(index);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: widget.tabs[index],
            ),
          );
        },
      ),
    );
  }

  void _scrollTo(int index) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double screenWidth = renderBox.size.width;
    final double tabWidth = screenWidth / widget.tabs.length;
    final double scrollOffset = index * tabWidth;
    _controller.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
