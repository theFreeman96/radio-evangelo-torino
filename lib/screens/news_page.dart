import 'package:flutter/material.dart';
import 'package:radio_evangelo_torino/screens/news_body.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

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
            body: const NewsBody(),
          )
        : Row(
            children: <Widget>[
              SizedBox(
                width: mediaQuery.size.width * 0.35,
                height: mediaQuery.size.height,
                child: buildHeader(),
              ),
              const Expanded(
                child: NewsBody(),
              ),
            ],
          );
  }

  buildHeader() {
    return Image.asset(
      'lib/assets/news.png',
      fit: BoxFit.cover,
    );
  }
}
