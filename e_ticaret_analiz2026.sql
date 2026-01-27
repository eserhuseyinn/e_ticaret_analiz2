select * from musteriler


-- ÝL BAZLI VERÝMLÝLÝK VE KAR MARJI ANALÝZÝ
SELECT COUNT(DISTINCT sehir) FROM musteriler;
SELECT  
    m.sehir,
    COALESCE(SUM(s.toplam_tutar), 0) AS Toplam_Ciro, 
    COALESCE(SUM((sd.birim_fiyat - u.alis_fiyati) * sd.adet), 0) AS toplam_kar,
    ROUND(
        COALESCE(SUM((sd.birim_fiyat - u.alis_fiyati) * sd.adet), 0) / 
        NULLIF(SUM(s.toplam_tutar), 0), 4
    ) AS kar_marji_ham
FROM musteriler m
LEFT JOIN siparisler s ON m.musteri_id = s.musteri_id
LEFT JOIN siparis_detaylari sd ON s.siparis_id = sd.siparis_id 
LEFT JOIN urunler u ON sd.urun_id = u.urun_id
GROUP BY m.sehir 
ORDER BY kar_marji_ham DESC;

--MÜÞTERÝLER VE SEGMENTASYONLARI 
WITH MusteriSiralamasi AS (
    SELECT 
        m.ad, 
        m.soyad, 
        -- Sipariþi olmayanlar için NULL yerine 0 yazdýrýyoruz:
        COALESCE(SUM(s.toplam_tutar), 0) AS ciro,
        -- Sýralamayý yaparken cirosu 0 olanlar en sonda kalacak:
        ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(s.toplam_tutar), 0) DESC) AS sira
    FROM musteriler m
    -- LEFT JOIN kullanarak sipariþi olmayan müþterileri de koruyoruz:
    LEFT JOIN siparisler s ON m.musteri_id = s.musteri_id
    GROUP BY m.ad, m.soyad, m.musteri_id
)
SELECT 
    ad, 
    soyad, 
    ciro,
    CASE 
        -- Ciro 0 ise direkt Potansiyel diyelim:
        WHEN ciro = 0 THEN 'Potansiyel Müþteri'
        WHEN sira = 1 THEN 'SAMPÝYON - En Deðerli Müþteri'
        WHEN sira BETWEEN 2 AND 5 THEN 'V.I.P. Destekçiler'
        WHEN sira BETWEEN 6 AND 10 THEN 'Sadýk Kitle'
        ELSE 'Geliþmekte Olanlar'
    END AS musteri_unvani
FROM MusteriSiralamasi;

select * from musteriler


