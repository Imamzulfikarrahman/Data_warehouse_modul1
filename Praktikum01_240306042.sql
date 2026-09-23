-- ==========================================================
-- MODUL PRAKTIKUM 01 - UADW v1.0
-- Pengenalan Lingkungan Data Warehouse & Eksplorasi Sumber Data
-- Nama : Imam Zulfikar Rahman
-- NIM  : 240306042
-- Tanggal: 2026-09-23
-- ==========================================================

-- ==========================================================
-- POINT 7: Membuat Database & Schema Source Layer
-- ==========================================================
-- Buat database
CREATE DATABASE uadw_lab;

-- Setelah terhubung ke uadw_lab, buat schema src
CREATE SCHEMA IF NOT EXISTS src;

-- Verifikasi schema berhasil dibuat
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'src';

-- ==========================================================
-- POINT 9: Membuat Data Inventory – Hitung Jumlah Baris
-- ==========================================================
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris
FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah;

-- ==========================================================
-- POINT 10: Eksplorasi Awal – Kualitas Data Mahasiswa
-- ==========================================================
-- 1. Cek NIM unik & indikasi duplikat
SELECT 
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT nim) AS distinct_nim,
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;

-- 2. Cek nilai kosong pada kota_asal_raw
SELECT COUNT(*) AS missing_kota
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';

-- 3. Lihat variasi label program studi dari data mahasiswa
SELECT prodi_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;

-- ==========================================================
-- POINT 11: Problem Challenge 1–9
-- ==========================================================

-- 1. Jumlah baris masing-masing tabel
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah;

-- 2. Jumlah NIM unik & perbandingan dengan total baris
SELECT 
    COUNT(*) AS total_baris,
    COUNT(DISTINCT nim) AS jumlah_nim_unik,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT nim) THEN 'SAMA'
        ELSE 'TIDAK SAMA'
    END AS status_perbandingan
FROM src.mahasiswa;

-- 3. Baris duplikat berlebih jika NIM = Natural Key
SELECT 
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;

-- 4. Rentang angkatan
SELECT 
    MIN(angkatan_raw) AS angkatan_paling_awal,
    MAX(angkatan_raw) AS angkatan_paling_akhir
FROM src.mahasiswa;

-- 5. Mahasiswa dengan kota_asal_raw kosong
SELECT 
    COUNT(*) AS jumlah_kota_asal_kosong
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';

-- 6. Jumlah label prodi_raw unik vs master program studi
SELECT COUNT(DISTINCT prodi_raw) AS jumlah_label_prodi_raw
FROM src.mahasiswa;

SELECT COUNT(*) AS jumlah_program_studi_canonical
FROM src.program_studi;

-- 7. Tiga pola lain ketidakkonsistenan
-- a. Format/jenis kelamin tidak konsisten
SELECT jenis_kelamin_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY jenis_kelamin_raw;

-- b. Format tanggal lahir beragam
SELECT tanggal_lahir_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY tanggal_lahir_raw
LIMIT 15;

-- c. Pola penulisan nama tidak seragam
SELECT nama_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY nama_raw
HAVING COUNT(*) > 1
LIMIT 10;