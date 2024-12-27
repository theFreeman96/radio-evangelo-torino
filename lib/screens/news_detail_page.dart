import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_evangelo_torino/utilities/constants.dart';

import '../utilities/theme_provider.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> singleNews;
  final Image image;
  final String date;

  const NewsDetailPage({
    super.key,
    required this.singleNews,
    required this.image,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding / 2),
                child: Switch(
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  value: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: kDefaultPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? kPrimaryLightColor
                              : kPrimaryColor,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding / 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sell,
                              color: themeProvider.isDarkMode
                                  ? kPrimaryLightColor
                                  : kPrimaryColor,
                            ),
                            const SizedBox(width: kDefaultPadding / 4),
                            Text(
                              '${singleNews['Categoria'] != null && singleNews['Categoria'] != '' ? singleNews['Categoria'] : 'Senza categoria'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.isDarkMode
                                    ? kPrimaryLightColor
                                    : kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: kDefaultPadding),
                    child: Text(
                      singleNews['Titolo'] != null && singleNews['Titolo'] != ''
                          ? singleNews['Titolo']
                          : 'Senza titolo',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.event),
                      const SizedBox(width: kDefaultPadding / 4),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: kDefaultPadding),
                    child: Text(
                      singleNews['Descrizione'] != null &&
                              singleNews['Descrizione'] != ''
                          ? singleNews['Descrizione']
                          : 'Senza descrizione',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
