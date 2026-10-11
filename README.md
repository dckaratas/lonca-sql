# 🗄️ Lonca — SQL

Bu klasörde iki ayrı SQL Server betiği var:

| Dosya | Amaç |
|---|---|
| `AdSoyad_NovaStore_Proje.sql` | **SQL dersi teslimi.** NovaStore yönergesine birebir uygun (DDL, örnek veri, 6 sorgu, VIEW, BACKUP) |
| `LoncaDB.sql` | Lonca projesinin kendi veri tabanı. Aynı yapı Lonca temasına uyarlanmıştır (+ `Quests` tablosu) |

## Çalıştırma

1. SQL Server Management Studio (SSMS) ile sunucuya bağlanın.
2. Dosyayı açıp **Execute (F5)** ile çalıştırın. Betik veri tabanını sıfırdan oluşturur.
3. Yedekleme adımından önce `C:\Yedek\` klasörünü oluşturun.

## NovaStore teslim kontrol listesi

- [ ] Dosya adlarındaki `AdSoyad` kısmını kendi adınla değiştir
- [ ] `AdSoyad_NovaStore_Proje.sql`: tüm adımlar, yorum satırlarıyla
- [ ] `AdSoyad_NovaStore_Proje.docx`: kodlar (kod kutusu), sorgu sonuçlarının ekran görüntüleri ve açıklamalar
- [ ] `AdSoyad_NovaStore_Proje.png`: SSMS → Database Diagrams ile tablo ilişkilerinin tek ekran görüntüsü
