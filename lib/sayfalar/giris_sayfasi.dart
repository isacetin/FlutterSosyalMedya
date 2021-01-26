import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/hesap_olustur.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();
  String email, sifre;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool sifregoster = true;
  bool yuklendiMi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text("Giriş Sayfasi"),
      ),
      body: Stack(
        children: [
          LoginPage(context),
          yuklendiMi ? Center(child: CircularProgressIndicator()) : SizedBox(),
        ],
      ),
    );
  }

  Widget LoginPage(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(top: 40),
        ),
        FlutterLogo(
          size: 100,
          style: FlutterLogoStyle.stacked,
          textColor: Colors.black,
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: "Email Adresiniz",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(7.0)))),
                  validator: (girilenDeger) {
                    if (!girilenDeger.contains("@")) {
                      return "Emailinizi Uygun Formatta Giriniz.";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (girilenDeger) {
                    email = girilenDeger;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: sifregoster,
                  decoration: InputDecoration(
                      labelText: "Şifreniz",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(sifregoster
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined),
                        onPressed: () {
                          _sifreGoster();
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)))),
                  validator: (girilenDeger) {
                    if (girilenDeger.trim().length < 6) {
                      return "Şifreniz 6 Karakterden Az Olamaz";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (girilenDeger) {
                    sifre = girilenDeger;
                  },
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HesapOlustur()));
                        },
                        color: Colors.grey.shade600,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          _girisYap(context);
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "veya",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                FlatButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://images.theconversation.com/files/93616/original/image-20150902-6700-t2axrz.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1000&fit=clip",
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Google ile Giriş",
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _googleIleGiris();
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Şifremi unuttum",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _girisYap(BuildContext context) async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        yuklendiMi = true;
      });

      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
      } catch (hata) {
        setState(() {
          yuklendiMi = false;
        });
        _scafoldKey.currentState.showSnackBar(SnackBar(
          content: Text("$hata"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _sifreGoster() {
    setState(() {
      sifregoster = !sifregoster;
    });
  }

  Future<UserCredential> _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yuklendiMi = true;
    });

    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici firestoreKullanici =
            await FireStoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FireStoreServisi().kullaniciOlustur(
            id: kullanici.id,
            email: kullanici.email,
            kullaniciAdi: kullanici.kullaniciAdi,
            fotoUrl: kullanici.fotoUrl,
          );
          print("Kullanıcı Dökümanı Oluşturuldu");
        }
      }
    } catch (e) {
      setState(() {
        yuklendiMi = false;
      });
      _scafoldKey.currentState.showSnackBar(SnackBar(
        content: Text("$e"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
