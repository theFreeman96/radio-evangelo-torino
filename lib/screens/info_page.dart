import 'package:flutter/material.dart';

import 'info_body.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    Orientation orientation = mediaQuery.orientation;
    return orientation == Orientation.portrait
        ? NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: mediaQuery.size.height * 0.25,
                  floating: false,
                  pinned: false,
                  toolbarHeight: 0.0,
                  collapsedHeight: 0.0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildHeader(),
                  ),
                ),
              ];
            },
            body: const InfoBody(),
          )
        : Row(
            children: <Widget>[
              SizedBox(
                width: mediaQuery.size.width * 0.35,
                height: mediaQuery.size.height,
                child: buildHeader(),
              ),
              const Expanded(
                child: InfoBody(),
              ),
            ],
          );
  }

  buildHeader() {
    return Image.asset(
      'lib/assets/info.jpg',
      fit: BoxFit.cover,
    );
  }
}
