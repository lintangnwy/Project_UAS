# Struktur Project — Al-Qur'an App

```
lib/
├── main.dart
│
├── models/
│   └── surah_model.dart          # SurahModel, SurahDetailModel, AyatModel
│
├── constants/
│   ├── app_colors.dart           # Palet warna
│   ├── app_text_styles.dart      # Typography + font Amiri
│   ├── app_constants.dart        # Spacing, label, route paths
│   └── api_constants.dart        # Base URL equran.id/api/v2
│
├── services/
│   ├── api_service.dart          # HTTP GET wrapper
│   ├── surah_service.dart        # fetchSurahList(), fetchSurahDetail()
│   └── local_storage_service.dart # Bookmark, last read (shared_preferences)
│
├── pages/
│   ├── home_page.dart            # Landing: last read card, stats, menu
│   ├── surah_list_page.dart      # Daftar 114 surah + search
│   ├── surah_detail_page.dart    # Detail surah + ayat + bookmark + share
│   ├── audio_player_page.dart    # Murottal player + pilih qori (5 qori)
│   └── bookmark_page.dart        # Daftar surah yang di-bookmark
│
├── routes/
│   └── app_routes.dart           # GoRouter: /, /bookmark, /surah, /surah/:nomor, /surah/:nomor/audio
│
└── widgets/
    ├── surah_card.dart            # Card item surah di list
    ├── search_field.dart          # Search bar reaktif (StatefulWidget)
    ├── custom_app_bar.dart        # AppBar reusable dengan warna opsional
    ├── audio_player_widget.dart   # Mini player widget (banner)
    └── loading_widget.dart        # LoadingWidget, ErrorWidget, EmptyWidget
```

## Assets

```
assets/
└── fonts/
    ├── Amiri-Regular.ttf   # Font Arab untuk teks Al-Qur'an
    └── Amiri-Bold.ttf
```

## Dependencies

| Package | Versi | Kegunaan |
|---|---|---|
| `go_router` | ^14.2.7 | Routing & navigasi |
| `http` | ^1.6.0 | HTTP request |
| `just_audio` | ^0.9.40 | Murottal audio player |
| `shared_preferences` | ^2.3.2 | Bookmark & last read |
| `share_plus` | ^10.0.2 | Share ayat |

## Architecture Rules

- Gunakan **StatefulWidget + setState()** untuk state UI — tanpa state management package
- HTTP request hanya di `services/`
- JSON parsing hanya di `models/`
- Konfigurasi warna, typography, API di `constants/`
- **GoRouter** untuk routing (nested routes untuk back stack yang benar)
- Reusable widgets di `widgets/`
- Null safety, async/await + try-catch, loading/error/empty state di semua page
