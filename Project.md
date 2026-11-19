## Architecture dan Coding Rules

Gunakan arsitektur Flutter sederhana, modular, dan terstruktur TANPA Provider, Riverpod, Bloc, GetX, atau state management package lainnya.

Ketentuan:

1. Gunakan StatefulWidget dan setState() untuk mengelola state UI.
2. Gunakan StatelessWidget untuk komponen yang tidak membutuhkan state.
3. Pisahkan seluruh HTTP request ke dalam folder services.
4. Pisahkan representasi data JSON ke dalam folder models.
5. Pisahkan konfigurasi warna, typography, dan API ke dalam constants.
6. Gunakan GoRouter untuk routing dan navigasi.
7. Gunakan reusable widgets untuk komponen UI yang digunakan berulang.
8. Jangan melakukan HTTP request secara langsung di dalam build().
9. Gunakan async/await dan try-catch untuk menangani request API.
10. Implementasikan loading, error, dan empty state.
11. Gunakan null safety dan hindari kode duplikat.
12. Pastikan seluruh kode modular, mudah dibaca, dan mudah dikembangkan.

Untuk pengambilan data:
- Page memanggil method dari SurahService.
- SurahService bertanggung jawab mengambil dan mengolah data.
- ApiService bertanggung jawab menangani HTTP request.
- SurahModel bertanggung jawab mengubah JSON menjadi objek Dart.

Jangan membuat folder providers atau file provider apa pun.

Pastikan semua state dikelola dengan StatefulWidget dan setState() sesuai kebutuhan.

Jangan menambahkan dependency state management yang tidak diperlukan.