# 🚀 PR Başlığı: Hashchat Profesyonel Sürüm Yükseltmesi: Vizyon, CI/CD ve Topluluk Standartları

## 📝 Özet
Bu Pull Request, Hashchat projesini standart bir kod deposundan "Elite Command Center" vizyonuna sahip, profesyonel bir açık kaynak projesine dönüştürmeyi amaçlamaktadır. Proje altyapısına otomatik test süreçleri (CI/CD), kapsamlı topluluk dokümantasyonu ve stratejik bir vizyon belgesi eklenmiştir. Mevcut kod tabanına dokunulmadan, projenin kalitesi ve sürdürülebilirliği artırılmıştır.

## ✨ Yapılan Değişiklikler

### 1. 🛡️ Topluluk ve Dokümantasyon
- **`VISION.md`**: Projenin "Kriptografik Egemenlik" vizyonunu ve 2030 hedeflerini anlatan stratejik belge eklendi.
- **`CONTRIBUTING.md`**: Projeye katkıda bulunmak isteyenler için profesyonel rehber eklendi.
- **`CODE_OF_CONDUCT.md`**: Uluslararası standartlarda (Contributor Covenant) topluluk davranış kuralları eklendi.

### 2. ⚙️ DevOps ve Otomasyon (CI/CD)
- **GitHub Actions Entegrasyonu**: `.github/workflows/ci.yml` oluşturuldu. Artık her `push` ve `pull_request` işleminde:
  - Python ortamı otomatik kuruluyor.
  - Bağımlılıklar (`requirements.txt`) yükleniyor.
  - Testler otomatik olarak çalıştırılıyor.

### 3. 🧪 Test Altyapısı
- **Backend Testleri**: `FastAPI` sunucusu için temel sağlık kontrollerini yapan `tests/test_main.py` modülü eklendi.
- **Bağımlılıklar**: Test süreci için `pytest` ve `httpx` kütüphaneleri projeye dahil edildi.

## ✅ Doğrulama Adımları
Bu değişiklikler aşağıdaki adımlarla doğrulanmıştır:
1. Lokal ortamda `pytest` çalıştırılarak backend servisinin sağlıklı olduğu teyit edildi.
2. Oluşturulan Markdown dosyalarının formatları ve içerikleri kontrol edildi.
3. CI/CD workflow dosyasının sözdizimi doğruluğu kontrol edildi.

## 🎯 Sonuç
Bu güncelleme ile Hashchat, sadece bir şifreli sohbet uygulaması olmaktan çıkıp, gelişmeye açık, test edilebilir ve topluluk odaklı profesyonel bir platforma dönüşmüştür.
