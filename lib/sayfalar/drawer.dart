import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/profil.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilDrawer extends StatefulWidget {
  final String profilSahibiId;

  const ProfilDrawer({Key key, this.profilSahibiId}) : super(key: key);

  @override
  _ProfilDrawerState createState() => _ProfilDrawerState();
}

class _ProfilDrawerState extends State<ProfilDrawer> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    String aktifKullanici =
        Provider
            .of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;

    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 150,
            color: Colors.white,
            child: FutureBuilder(
              future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: [
                    _profilDetaylari(snapshot.data),
                  ],
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.brightness_2),
            title: Text("Gece Modu"),
            trailing: Switch(
              value: darkMode,
              onChanged: (change) {
                darkMode = change;
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profil"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      fullscreenDialog: false,
                      builder: (context) =>
                          Profil(
                            profilSahibiId: aktifKullanici,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text("Bildirimler"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Ayarlar"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Çıkış"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Provider.of<YetkilendirmeServisi>(context, listen: false)
                  .cikisYap();
            },
          ),
          Divider(),
          AboutListTile(
            applicationName: "MITHRA",
            applicationIcon: Icon(Icons.account_box),
            applicationVersion: "2.0",
            child: Text("HAKKINDA"),
            applicationLegalese: "Coded by İsa Çetin",
            icon: Icon(Icons.account_box),
          ),
        ],
      ),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Column(
      children: [
        SizedBox(height: 15),
        CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 50,
          backgroundImage: profilData.fotoUrl.isNotEmpty
              ? NetworkImage((profilData.fotoUrl))
              : AssetImage("assets/images/profil.png"),
        ),
        SizedBox(height: 10),
        Text(
          profilData.kullaniciAdi.toString(),
          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
