# 📱 techcareer.net SwiftUI for iOS Bootcamp — Bitirme Projesi
SwiftUI ile geliştirilen, filmleri listeleyip detayına gidebildiğiniz; favori ve sepet akışlarını barındıran eğitim amaçlı demo uygulama. Ticari amaçla kullanılmamıştır.

---

## 🎯 Özellikler
- ✅ Filmleri Listeleme
- ✅ Film Detayı Görme
- ✅ Favorilere Ekleme / Çıkarma
- ✅ Sepete Ekleme / Çıkarma
- ✅ Sepetteki Filmleri Görüntüleme
- ✅ REST API Entegrasyonu (async/await, URLSession)
- ✅ Karanlık / Açık Mod Uyumu
Not: Akışlar demo amaçlıdır; ödeme vb. gerçek işlemler içermez.
---

## 🧩 Ana Ekranlar

### 🏠 Ana Sayfa & 🔍 Arama & ❤️ Favoriler & 🛒 Sepet

<div align="center">
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/f39e3b36-affa-471d-bf51-41424005c30b" width="300" alt="AnaSayfa">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/40badc72-2eec-4e49-b1ab-629b62c0d4d9" width="300" alt="Keşfet">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/ac931b91-db6d-40a1-a801-de5009c15835" width="300" alt="Favoriler">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/9b5c529a-9e01-4dd1-bc9a-2c67a665e7ee" width="300" alt="Sepet">
    </td>
  </tr>
  <tr>
    <td align="center"><b>Ana Sayfa</b></td>
    <td align="center"><b>Keşfet</b></td>
    <td align="center"><b>Favoriler</b></td>
    <td align="center"><b>Sepet</b></td>
  </tr>
</table>
</div>

---

## 🧩 Uygulama Özellikleri

Filmleri keşfet ekranından arayıp istediğimiz filmin detay sayfasına gidebiliriz.

<div align="center">
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/7eb71c5e-8157-41ca-9ca7-49e6a770218a" width="300" alt="FilmArama">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/a645ec2e-9fd0-4185-be1a-ad6c286fd601" width="300" alt="DetaySayfası">
    </td>
  </tr>
  <tr>
    <td align="center"><b>Film Arama</b></td>
    <td align="center"><b>Film Detay Sayfası</b></td>
  </tr>
</table>
</div>

Detay sayfasından istenilen film için istenilen işlemi yapabiliriz. İstersek favorilere ekleyebiliriz, istersek sepete ekleyebiliriz. İstersek her ikisini de yapabiliriz.

<div align="center">
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/9c0358e2-7500-4609-820f-47d728408b5c" width="300" alt="FavoriEkleme">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/9e444b63-8e05-4eb1-9b56-04ef4ee84289" width="300" alt="SepeteEkleme">
    </td>
  </tr>
  <tr>
    <td align="center"><b>Favorilere Ekleme</b></td>
    <td align="center"><b>Sepete Ekleme</b></td>
  </tr>
</table>
</div>

Sepete eklenilen filmi istersek kaldırabiliriz. Filmi sepetten kaldığımız zaman film detay ekranındaki sepete ekle kısmı geri gelir. Silinen film istenildiği zamanda tekrar sepete eklenebilir.

<div align="center">
<table>
  <tr>
    <td>
      <img width="300" alt="SepetFilm" src="https://github.com/user-attachments/assets/c6cf93ef-9643-4b63-a9dd-25cae3332129" />
    </td>
    <td>
      <img width="300" alt="SepetFilmSilme" src="https://github.com/user-attachments/assets/8f0e9f68-b287-49c2-a278-c3f9ad80d1e6" />
    </td>
    <td>
      <img width="300" alt="SepetBoş" src="https://github.com/user-attachments/assets/4f269d5a-13b0-4307-80a2-1a0bf74e5248" />
    </td>
    <td>
      <img width="300" alt="FilmDetay2" src="https://github.com/user-attachments/assets/bec72e41-e0b5-4d5f-aa53-6b0f97997e16" />
    </td>
  </tr>
  <tr>
    <td align="center"><b>Sepette Film</b></td>
    <td align="center"><b>Sepetteki Filmi Silme</b></td>
    <td align="center"><b>Sepet Boş</b></td>
    <td align="center"><b>Detay Sayfasına Yeniden Bakış</b></td>
  </tr>
</table>
</div>

---

## 🛠️ Kullanılan Teknolojiler

- **Dil & Platform**
  - Swift
  - iOS

- **UI Katmanı**
  - **SwiftUI**
    - `NavigationStack`, `.toolbar`, `.searchable`, `.refreshable`
    - Responsive layout
  - **Design System**
    - `AppColors` (özel renk paleti)
    - `NavigationBarStyle` (başlık / görünüm özelleştirmeleri)
    - Kart bileşenleri: `CardCarouselView`, liste/grid kartları

- **Mimari**
  - **MVVM**
    - View / ViewModel / Model ayrımı
    - Protokol tabanlı soyutlama (test edilebilirlik için)

- **DATA Katmanı**
  - SwiftData
  - REST API

- **Networking & Concurrency**
  - `URLSession` ile REST API tüketimi (async/await)
  - JSON decode için `Codable`
  - Hata ve durum yönetimi (loading / error state)

- **Görseller**
  - **Kingfisher**
    - Uzaktan görsel indirme, caching, place­holder’lar

---

## 🚀 Kurulum (Quick Start)
```bash
git clone https://github.com/zaimonur/techcareer-swiftui-odev2.git
cd techcareer-swiftui-odev2
open ToDosAppOdev.xcodeproj
```
---

## 👨🏻‍💻 Bana Ulaşın
- ✉️ **zaimonur08@gmail.com**
- 🌐 **https://www.linkedin.com/in/onur-zaim/**
