import 'dart:io';
import 'package:bitirme_projemm/servisler/firestoreservisi.dart';
import 'package:bitirme_projemm/servisler/storageservisi.dart';
import 'package:bitirme_projemm/servisler/yetkilendirmeServisi.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextController = TextEditingController();
  TextEditingController konumTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        icon: Icon(
          Icons.file_upload,
          size: 50,
        ),
        onPressed: () {
          fotografSec();
        });
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: _gonderiOlustur)
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: TextFormField(
              controller: konumTextController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  hintText: "Konum Ekle",
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.file(
                dosya,
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: aciklamaTextController,
            decoration: InputDecoration(
                hintMaxLines: 3,
                hintText: "Açıklama Ekle",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.add_comment_rounded)),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya);
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      await FireStoreServisi().gonderiOlustur(
          gonderiResmiUrl: resimUrl,
          aciklama: aciklamaTextController.text,
          yayinlayanId: aktifKullaniciId,
          konum: konumTextController.text);
    }
    setState(() {
      yukleniyor = false;
      aciklamaTextController.clear();
      konumTextController.clear();
      dosya = null;
    });
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: [
              SimpleDialogOption(
                child: Text("Fotoğraf Çek"),
                onPressed: () {
                  fotoCek();
                },
              ),
              SimpleDialogOption(
                child: Text("Galeriden Yükle"),
                onPressed: () {
                  GaleridenYukle();
                },
              ),
              SimpleDialogOption(
                child: Text("İptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }

  GaleridenYukle() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }
}
