import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  var _formKey = GlobalKey<FormState>();
  var _scafoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  String kullaniciAd, mail, sifre;
  bool yukleniyor = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(title: Text("Hesap Oluştur")),
      body: Column(
        children: [
          yukleniyor ? LinearProgressIndicator() : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Kullanıcı Adınız",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16)))),
                    validator: (girilenDeger) {
                      if (girilenDeger.length < 4) {
                        return "Kullanıcı Adınız 4 Karakterden Az Olamaz";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (deger) {
                      kullaniciAd = deger;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "Mail Adresiniz",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16)))),
                    validator: (girilenDeger) {
                      if (!girilenDeger.contains("@")) {
                        return "Mail Adresiniz Uygun Formatta Olmalıdır.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (deger) {
                      mail = deger;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Şifreniz",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16)))),
                    validator: (girilenDeger) {
                      if (girilenDeger.length < 6) {
                        return "Şifreniz 6 Karakterden Az Olamaz";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (deger) {
                      sifre = deger;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            _hesapOlustur();
                          },
                          child: Text(
                            "Hesap Oluştur",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _hesapOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanici kullanici = await _yetkilendirmeServisi.mailIleKayit(mail, sifre);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(id: kullanici.id, email: mail, kullaniciAdi: kullaniciAd);
        }
        Navigator.pop(context);

        setState(() {
          yukleniyor = false;
        });
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });

        _scafoldKey.currentState.showSnackBar(SnackBar(
          content: Text("$hata"),
          backgroundColor: Colors.red,
        ));
        debugPrint("Hatanız : $hata");
      }
    }
  }
}
