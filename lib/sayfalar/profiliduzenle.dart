import 'dart:io';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/storageservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfiliDuzenle({Key key, this.profil}) : super(key: key);
  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _fromKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _secilmilFoto;
  bool _yukleniyor = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: _kaydet,
          ),
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0),
          _profilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async {
    if (_fromKey.currentState.validate()) {
      setState(() {
        _yukleniyor = true;
      });
      _fromKey.currentState.save();

      String profilFotoUrl;
      if(_secilmilFoto == null){
        profilFotoUrl = widget.profil.fotoUrl;
      }else{
        profilFotoUrl = await StorageServisi().profilResmiYukle(_secilmilFoto);
      }
      String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context,listen:false).aktifKullaniciId;
      FireStoreServisi().kullaniciGuncelle(
        kullaniciId: aktifKullaniciId,
        kullaniciAdi: _kullaniciAdi,
        hakkinda: _hakkinda,
        fotoUrl: profilFotoUrl
      );
      setState(() {
        _yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Center(
        child: InkWell(
          onTap: _galeridenYukle,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _secilmilFoto == null ? NetworkImage(widget.profil.fotoUrl) : FileImage(_secilmilFoto),
            radius: 55,
          ),
        ),
      ),
    );
  }

  _galeridenYukle() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _secilmilFoto = File(image.path);
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: _fromKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              decoration: InputDecoration(labelText: "Kullanici Adı"),
              validator: (girilenDeger) {
                return girilenDeger.trim().length <= 3
                    ? "Kullanici Adı en az 4 karakter olmalı"
                    : null;
              },
              onSaved: (girilenDeger){
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger.trim().length > 100
                    ? "100 Karakterden fazla olmamalı"
                    : null;
              },
              onSaved: (girilenDeger){
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
