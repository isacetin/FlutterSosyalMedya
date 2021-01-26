import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/anasayfa.dart';
import 'package:bitirme_projemm/sayfalar/giris_sayfasi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
        stream: YetkilendirmeServisi().durumTakipcisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            Kullanici aktifKullanici = snapshot.data;
            _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.id;
            return AnaSayfa();
          } else {
            return GirisSayfasi();
          }
        });
  }
}
