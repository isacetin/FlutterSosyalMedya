import 'package:bitirme_projemm/modeller/gonderi.dart';
import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:bitirme_projemm/sayfalar/profiliduzenle.dart';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:bitirme_projemm/widgetler/gonderikarti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;

  const Profil({Key key, this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayaci = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  String appBarAd = "";
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  String _aktifKullaniciId;
  Kullanici _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _IsimGetir() async {
    String isim = await FireStoreServisi().KullaniciIsim(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        appBarAd = isim.toString();
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    setState(() {
      _takipEdilen = takipEdilenSayisi;
    });
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayaci = _gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takipVarMi = await FireStoreServisi().takipKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifKullaniciId);
    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipEdilenSayisiGetir();
    _takipciSayisiGetir();
    _IsimGetir();
    _gonderileriGetir();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarAd,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              ? profiliDuzenleButton()
              : _takipButonu()
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Object>(
        future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          _profilSahibi = snapshot.data;
          return ListView(
            children: [
              _profilDetaylari(snapshot.data),
              _gonderileriGoster(snapshot.data),
            ],
          );
        },
      ),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _gonderiler.length,
          itemBuilder: (context, index) {
            return GonderiKarti(
              gonderi: _gonderiler[index],
              yayinlayan: profilData,
            );
          });
    } else {
      List<GridTile> bloklar = [];
      _gonderiler.forEach((gonderi) {
        bloklar.add(_blokOlustur(gonderi));
      });
      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          physics: NeverScrollableScrollPhysics(),
          children: bloklar);
    }
  }

  GridTile _blokOlustur(Gonderi gonderi) {
    return GridTile(
        child: Image.network(
      gonderi.gonderiResmiUrl,
      fit: BoxFit.cover,
    ));
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50,
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage((profilData.fotoUrl))
                    : AssetImage("assets/images/profil.png"),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(child: Text(profilData.hakkinda)),
              SizedBox(height: 5),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sosyalSayac("Gönderiler", _gonderiSayaci),
              _sosyalSayac("Takipçi", _takipci),
              _sosyalSayac("Takip", _takipEdilen),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCik() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        icon: Icon(Icons.person_add),
        onPressed: () {
          FireStoreServisi().takipEt(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = true;
          });
        },
      ),
    );
  }

  Widget _takiptenCik() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        icon: Icon(Icons.person_remove),
        onPressed: () {
          FireStoreServisi().takiptenCik(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = false;
          });
        },
      ),
    );
  }

  Widget profiliDuzenleButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfiliDuzenle(
                        profil: _profilSahibi,
                      )));
        },
      ),
    );
  }

  Widget _sosyalSayac(String baslik, int sayi) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Text(
          baslik,
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
