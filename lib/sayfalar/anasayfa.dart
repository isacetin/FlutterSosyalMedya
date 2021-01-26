import 'package:bitirme_projemm/sayfalar/akis.dart';
import 'package:bitirme_projemm/sayfalar/drawer.dart';
import 'package:bitirme_projemm/sayfalar/gundem.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';
import 'package:bitirme_projemm/sayfalar/yukle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnaSayfa extends StatefulWidget {

  User user;
  AnaSayfa({Key key, this.user}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  PageController sayfaController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sayfaController = PageController();
  }

  @override
  void dispose() {
    sayfaController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullanici = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      drawer: ProfilDrawer(profilSahibiId: aktifKullanici,),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaController,
        children: [
          Akis(),
          Yukle(),
          Gundem(),
          //Profil(profilSahibiId: aktifKullanici),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Akış",
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload),
              label: "Yükle",
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Keşfet",
              backgroundColor: Colors.white),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            sayfaController.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
