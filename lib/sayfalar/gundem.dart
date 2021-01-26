import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/profil.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Gundem extends StatefulWidget {
  @override
  _GundemState createState() => _GundemState();
}

class _GundemState extends State<Gundem> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 30),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _aramaController.clear();
              setState(() {
                _aramaSonucu = null;
              });
            },
          ),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: "Kullanıcı Ara",
          contentPadding: EdgeInsets.only(top: 16),
        ),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: _aramaSonucu,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(child: Text("Bu Arama İçin Sonuç Bulunamadı"));
          }
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Kullanici kullanici = snapshot.data[index];
                return kullaniciSatiri(kullanici);
              });
        });
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Profil(profilSahibiId: kullanici.id,)));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
