import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/link.dart';

import '../utilities/constants.dart';

class InfoBody extends StatelessWidget {
  const InfoBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List menuList = [
      _MenuItem(
        'https://www.adi-torino.it/',
        Icons.language,
        'Chiesa ADI Torino',
        'La nostra Comunità',
      ),
      _MenuItem(
        'https://www.adi-torino.it/template_radio/index.php',
        Icons.cell_tower,
        'Radio online',
        'Scopri di più sulla Radio',
      ),
      _MenuItem(
        'mailto:radio@adi-torino.it',
        Icons.mail,
        'Inviaci una mail',
        'radio@adi-torino.it',
      ),
      _MenuItem(
        'https://www.youtube.com/c/RadioEvangeloTorino?sub_confirmation=1',
        FontAwesomeIcons.youtube,
        'YouTube',
        'Storie Bibliche e tanto altro',
      ),
      _MenuItem(
        'https://www.facebook.com/radioevangelotorino/',
        Icons.facebook,
        'Facebook',
        'Non perderti i nostri post!',
      ),
      _MenuItem(
        'https://maps.app.goo.gl/vY5oy4hu5LBzJcjC6',
        Icons.location_on,
        'Vienici a trovare',
        'Via Spalato, 9/B, 10141 Torino',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      itemCount: menuList.length,
      itemBuilder: (BuildContext context, int index) {
        return Link(
          uri: Uri.parse(menuList[index].link),
          target: LinkTarget.blank,
          builder: (context, followLink) {
            return ListTile(
              leading: CircleAvatar(
                child: menuList[index].icon == FontAwesomeIcons.youtube
                    ? FaIcon(menuList[index].icon)
                    : Icon(menuList[index].icon),
              ),
              title: Text(
                menuList[index].title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                menuList[index].subtitle,
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: followLink,
            );
          },
        );
      },
    );
  }
}

class _MenuItem {
  final String link;
  final dynamic icon;
  final String title;
  final String subtitle;

  _MenuItem(this.link, this.icon, this.title, this.subtitle);
}
