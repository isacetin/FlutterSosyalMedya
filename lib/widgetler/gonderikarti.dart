import 'package:bitirme_projemm/modeller/gonderi.dart';
import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/yorumlar.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  bool _favoriledin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    // TODO: implement initState
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi =
        await FireStoreServisi().begeniVarmi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            _gonderiBasligi(),
            _gonderiResmi(),
            _gonderiAlt(),
          ],
        ));
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
              ? NetworkImage((widget.yayinlayan.fotoUrl))
              : AssetImage("assets/images/profil.png"),
        ),
      ),
      title: Text(widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text(
              "Favorilere Ekle",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 1) {
            print("Favori Ekle Tiklandi");
            _favoriDegistir();
          }
        },
      ),
      contentPadding: EdgeInsets.all(0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: !_begendin
                    ? Icon(
                        Icons.favorite_border,
                        size: 30,
                      )
                    : Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      ),
                onPressed: _begeniDegistir),
            IconButton(
                icon: Icon(
                  Icons.comment,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Yorumlar(gonderi: widget.gonderi)));
                }),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text("$_begeniSayisi beğeni ",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 2,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: RichText(
                  text: TextSpan(
                      text: widget.yayinlayan.kullaniciAdi + " ",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: widget.gonderi.aciklama,
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14))
                      ]),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FireStoreServisi().gonderiBegeniAzalt(widget.gonderi, _aktifKullaniciId);
    } else {
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }

  void _favoriDegistir() {
    if (!_favoriledin) {
      setState(() {
        _favoriledin = true;
      });
      FireStoreServisi().gonderiFavori(widget.gonderi, _aktifKullaniciId);
    } else {
      setState(() {
        _favoriledin = false;
      });
    }
  }
}
