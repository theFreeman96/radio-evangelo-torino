import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/constants.dart';
import 'news_detail_page.dart';

class NewsBody extends StatefulWidget {
  const NewsBody({super.key});

  @override
  NewsBodyState createState() => NewsBodyState();
}

class NewsBodyState extends State<NewsBody> {
  late Stream<List<Map<String, dynamic>>> newsStream;

  @override
  void initState() {
    super.initState();
    _signInAndFetchNews();
    newsStream = _fetchNews();
  }

  Future<void> _signInAndFetchNews() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      print('Utente autenticato: ${userCredential.user?.uid}');
      setState(() {
        newsStream = _fetchNews();
      });
    } catch (e) {
      print('Errore durante l\'autenticazione: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchNews() {
    return FirebaseFirestore.instance
        .collection('avvisi')
        .orderBy('Data creazione', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['ID'] = doc.id;
        return data;
      }).toList();
    });
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      print('Errore durante il parsing della data: $e');
      return 'Data non valida';
    }
  }

  String getEventDateRange(String? startDate, String? endDate) {
    if ((startDate == null || startDate.isEmpty) &&
        (endDate == null || endDate.isEmpty)) {
      return '';
    }

    if (startDate != null && startDate.isNotEmpty) {
      DateTime start = DateTime.parse(startDate);

      if (endDate == null || endDate.isEmpty) {
        return formatDate(startDate);
      }

      DateTime end = DateTime.parse(endDate);

      if (start.isAtSameMomentAs(end)) {
        return formatDate(startDate);
      }

      if (end.isBefore(start)) {
        return formatDate(startDate);
      }

      return 'Dal ${formatDate(startDate)} al ${formatDate(endDate)}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: newsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child:
                Text('Errore nel caricamento degli avvisi: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nessun avviso disponibile'),
          );
        }

        final news = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding / 2),
                itemCount: news.length,
                itemBuilder: (context, index) {
                  final singleNews = news[index];
                  const storageLink =
                      'https://firebasestorage.googleapis.com/v0/b/radio-evangelo-torino.appspot.com/o/';
                  final imageName = singleNews['Immagine'];
                  const media = '?alt=media';
                  final imageLink = storageLink + imageName + media;
                  return ListTile(
                    minTileHeight: 100,
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(kDefaultPadding),
                      ),
                      child: imageName != null && imageName != ""
                          ? Image.network(
                              imageLink,
                              width: 60,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'lib/assets/logo.png',
                              width: 60,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(
                      singleNews['Titolo'] ?? 'Senza titolo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    subtitle: Text(
                      getEventDateRange(
                        singleNews['Data inizio'],
                        singleNews['Data fine'],
                      ),
                    ),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(
                            singleNews: singleNews,
                            image: imageName != null && imageName != ""
                                ? Image.network(
                                    imageLink,
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Image.asset(
                                    'lib/assets/logo.png',
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.fitWidth,
                                  ),
                            date: getEventDateRange(
                              singleNews['Data inizio'],
                              singleNews['Data fine'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
