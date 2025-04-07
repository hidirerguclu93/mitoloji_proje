# Aetherium

Aetherium, mitolojik bilgileri ve karakterleri bir araya getiren, kullanıcıların hem okuyabileceği hem de kendi hikâyelerini yazabileceği bir mobil uygulamadır. Proje, Flutter ile geliştirilmiş olup Supabase altyapısı kullanılarak veritabanı bağlantıları sağlanmıştır.

## Özellikler

- Farklı mitolojiler arasında gezinebilme (Yunan, Mısır, İskandinav vb.)
- Mitolojik hikâyeleri ve karakterleri kronolojik veya kategoriye göre listeleme
- Detay sayfaları ile bilgi sunumu
- Kullanıcı girişi ve kayıt sistemi (Supabase Auth)
- Geliştirme aşamasında olan:
  - Gerçek zamanlı sohbet odası (WebSocket)
  - Hikâye beğenme ve favorilere ekleme
  - Kullanıcıların kendi hikâyesini yazabilmesi
  - Harita üzerinden mitolojik olayları inceleme

## Kurulum

1. Flutter SDK ve VS Code kurulumunu tamamlayın.
2. Bu projeyi klonlayın:

   ```bash
   https://github.com/hidirerguclu93/mitoloji_proje
   ```

3. Paketleri yükleyin:

   ```bash
   flutter pub get
   ```

4. `lib/main.dart` içerisinde yer alan Supabase bağlantı bilgilerini kendi projenize göre düzenleyin:

   ```dart
   await Supabase.initialize(
     url: 'https://projeurl.supabase.co',
   ```
     anonKey: 'your-anon-key',
   );
   ```

5. Projeyi çalıştırmak için:

   ```bash
   flutter run -d chrome
   ```
