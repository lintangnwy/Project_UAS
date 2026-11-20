import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan data persisten lokal:
/// - Bookmark surah (daftar nomor surah)
/// - Last read (nomor surah + nomor ayat terakhir)
class LocalStorageService {
  static const _keyBookmarks = 'bookmarked_surahs';
  static const _keyLastReadNomor = 'last_read_nomor';
  static const _keyLastReadNamaLatin = 'last_read_nama_latin';
  static const _keyLastReadNama = 'last_read_nama';
  static const _keyLastReadAyat = 'last_read_ayat';

  // ─── Singleton ────────────────────────────────────────────────────────────

  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────

  /// Ambil semua nomor surah yang di-bookmark.
  Future<List<int>> getBookmarks() async {
    final prefs = await _p;
    final raw = prefs.getStringList(_keyBookmarks) ?? [];
    return raw.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  /// Cek apakah surah dengan [nomor] sudah di-bookmark.
  Future<bool> isBookmarked(int nomor) async {
    final list = await getBookmarks();
    return list.contains(nomor);
  }

  /// Tambah bookmark. Tidak duplikat.
  Future<void> addBookmark(int nomor) async {
    final prefs = await _p;
    final list = await getBookmarks();
    if (!list.contains(nomor)) {
      list.add(nomor);
      await prefs.setStringList(
        _keyBookmarks,
        list.map((e) => e.toString()).toList(),
      );
    }
  }

  /// Hapus bookmark.
  Future<void> removeBookmark(int nomor) async {
    final prefs = await _p;
    final list = await getBookmarks();
    list.remove(nomor);
    await prefs.setStringList(
      _keyBookmarks,
      list.map((e) => e.toString()).toList(),
    );
  }

  /// Toggle bookmark — tambah jika belum ada, hapus jika sudah ada.
  /// Mengembalikan status bookmark setelah toggle (true = sekarang di-bookmark).
  Future<bool> toggleBookmark(int nomor) async {
    final already = await isBookmarked(nomor);
    if (already) {
      await removeBookmark(nomor);
      return false;
    } else {
      await addBookmark(nomor);
      return true;
    }
  }

  // ─── Last Read ────────────────────────────────────────────────────────────

  /// Simpan posisi baca terakhir.
  Future<void> saveLastRead({
    required int nomor,
    required String namaLatin,
    required String nama,
    required int nomorAyat,
  }) async {
    final prefs = await _p;
    await prefs.setInt(_keyLastReadNomor, nomor);
    await prefs.setString(_keyLastReadNamaLatin, namaLatin);
    await prefs.setString(_keyLastReadNama, nama);
    await prefs.setInt(_keyLastReadAyat, nomorAyat);
  }

  /// Ambil posisi baca terakhir. Null jika belum pernah.
  Future<LastReadData?> getLastRead() async {
    final prefs = await _p;
    final nomor = prefs.getInt(_keyLastReadNomor);
    if (nomor == null) return null;
    return LastReadData(
      nomor: nomor,
      namaLatin: prefs.getString(_keyLastReadNamaLatin) ?? '',
      nama: prefs.getString(_keyLastReadNama) ?? '',
      nomorAyat: prefs.getInt(_keyLastReadAyat) ?? 1,
    );
  }

  /// Hapus semua data last read.
  Future<void> clearLastRead() async {
    final prefs = await _p;
    await prefs.remove(_keyLastReadNomor);
    await prefs.remove(_keyLastReadNamaLatin);
    await prefs.remove(_keyLastReadNama);
    await prefs.remove(_keyLastReadAyat);
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class LastReadData {
  final int nomor;
  final String namaLatin;
  final String nama;
  final int nomorAyat;

  const LastReadData({
    required this.nomor,
    required this.namaLatin,
    required this.nama,
    required this.nomorAyat,
  });
}
