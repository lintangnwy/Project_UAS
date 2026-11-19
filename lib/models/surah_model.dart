import 'dart:convert';

// ─── Top-level helpers ────────────────────────────────────────────────────────

/// Decode list surah dari response /surat
List<SurahModel> surahListFromJson(String str) {
  final Map<String, dynamic> json = jsonDecode(str);
  return List<SurahModel>.from(
    (json['data'] as List).map((x) => SurahModel.fromJson(x)),
  );
}

/// Decode detail surah dari response /surat/:nomor
SurahDetailModel surahDetailFromJson(String str) {
  final Map<String, dynamic> json = jsonDecode(str);
  return SurahDetailModel.fromJson(json['data']);
}

// ─── SurahModel (list item) ───────────────────────────────────────────────────

class SurahModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;

  const SurahModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
        nomor: json['nomor'] as int,
        nama: json['nama'] as String,
        namaLatin: json['namaLatin'] as String,
        jumlahAyat: json['jumlahAyat'] as int,
        tempatTurun: json['tempatTurun'] as String,
        arti: json['arti'] as String,
        deskripsi: json['deskripsi'] as String,
        audioFull: _toStringMap(json['audioFull'] as Map),
      );

  /// Cast safely: JSON values come as dynamic, force them to String.
  static Map<String, String> _toStringMap(Map raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v.toString()));
}

// ─── AyatModel ───────────────────────────────────────────────────────────────

class AyatModel {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio;

  const AyatModel({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory AyatModel.fromJson(Map<String, dynamic> json) => AyatModel(
        nomorAyat: json['nomorAyat'] as int,
        teksArab: json['teksArab'] as String,
        teksLatin: json['teksLatin'] as String,
        teksIndonesia: json['teksIndonesia'] as String,
        audio: _toStringMap(json['audio'] as Map),
      );

  static Map<String, String> _toStringMap(Map raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v.toString()));
}

// ─── SurahDetailModel ─────────────────────────────────────────────────────────

class SurahDetailModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;
  final List<AyatModel> ayat;

  const SurahDetailModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.ayat,
  });

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) =>
      SurahDetailModel(
        nomor: json['nomor'] as int,
        nama: json['nama'] as String,
        namaLatin: json['namaLatin'] as String,
        jumlahAyat: json['jumlahAyat'] as int,
        tempatTurun: json['tempatTurun'] as String,
        arti: json['arti'] as String,
        deskripsi: json['deskripsi'] as String,
        audioFull: _toStringMap(json['audioFull'] as Map),
        ayat: List<AyatModel>.from(
          (json['ayat'] as List).map((x) => AyatModel.fromJson(x)),
        ),
      );

  static Map<String, String> _toStringMap(Map raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v.toString()));
}
