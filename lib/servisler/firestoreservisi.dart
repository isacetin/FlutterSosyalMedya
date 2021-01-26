import 'package:bitirme_projemm/modeller/gonderi.dart';
import 'package:bitirme_projemm/modeller/kullanici.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle(
      {String kullaniciId,
      String kullaniciAdi,
      String fotoUrl = "",
      String hakkinda}) {
    _firestore.collection("kullanicilar").doc(kullaniciId).update({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl,
    });
  }

  Future<List<Kullanici>>kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .get();
    List<Kullanici> kullanicilar = snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }
  void takipEt({String aktifKullaniciId, String profilSahibiId}){
    _firestore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicinTakipcileri").doc(aktifKullaniciId).set({});

    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicinintakipleri").doc(profilSahibiId).set({});
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}){
    _firestore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicinTakipcileri").doc(aktifKullaniciId).get().then((DocumentSnapshot doc){
          if(doc.exists){
            doc.reference.delete();
          }
    });

    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri").doc(profilSahibiId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }
  Future<bool>takipKontrol({String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri").doc(profilSahibiId).get();
    if(doc.exists){
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .doc(kullaniciId)
        .collection("kullanicinTakipcileri")
        .get();
    return snapshot.docs.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .doc(kullaniciId)
        .collection("kullanicininTakipleri")
        .get();
    return snapshot.docs.length;
  }

  Future<String> KullaniciIsim(kullaniciId) async {
    DocumentSnapshot snapshot =
        await _firestore.doc("kullanicilar/$kullaniciId").get();
    return snapshot.data()["kullaniciAdi"];
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .doc(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .doc(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<List<Gonderi>> favorileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("favoriler")
        .doc(kullaniciId)
        .collection("gonderiFavorileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .set({});
    }
  }

  Future<void> gonderiFavori(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      _firestore
          .collection("favoriler")
          .doc(gonderi.id)
          .collection("gonderiFavorileri")
          .doc(gonderi.id)
          .set({});
    }
  }

  Future<void> gonderiBegeniAzalt(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .get();
      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .doc(gonderi.id)
        .collection("gonderiBegenileri")
        .doc(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .doc(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}) {
    _firestore
        .collection("yorumlar")
        .doc(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });
  }
}
