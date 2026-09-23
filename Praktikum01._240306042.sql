-- ==========================================================
-- MODUL PRAKTIKUM 01 - UADW v1.0
-- Nama : Imam Zulfikar Rahman
-- NIM  : 240306042
-- Tanggal: 2026-09-23
-- ==========================================================

-- ==========================================================
-- POINT 7: MEMBUAT DATABASE, SCHEMA, DAN TABEL SOURCE LAYER
-- ==========================================================

-- Buat database
CREATE DATABASE uadw_lab;

-- Setelah terhubung ke uadw_lab, buat schema src
CREATE SCHEMA IF NOT EXISTS src;

-- Verifikasi schema berhasil dibuat
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'src';

-- Buat tabel program_studi
CREATE TABLE IF NOT EXISTS src.program_studi (
    kode_prodi TEXT,
    nama_prodi TEXT,
    fakultas TEXT,
    departemen TEXT,
    status TEXT
);

-- Buat tabel semester
CREATE TABLE IF NOT EXISTS src.semester (
    kode_semester TEXT,
    nama_semester TEXT,
    jenis TEXT,
    urutan INTEGER,
    tanggal_mulai_raw TEXT,
    tanggal_selesai_raw TEXT
);

-- Buat tabel mahasiswa
CREATE TABLE IF NOT EXISTS src.mahasiswa (
    nim TEXT,
    nama_raw TEXT,
    jenis_kelamin_raw TEXT,
    tanggal_lahir_raw TEXT,
    kota_asal_raw TEXT,
    kode_prodi TEXT,
    prodi_raw TEXT,
    angkatan_raw TEXT,
    tanggal_masuk_raw TEXT,
    status_raw TEXT,
    email_raw TEXT
);

-- Buat tabel dosen
CREATE TABLE IF NOT EXISTS src.dosen (
    nip TEXT,
    nama_dosen_raw TEXT,
    jenis_kelamin_raw TEXT,
    prodi_raw TEXT,
    jabatan_akademik_raw TEXT,
    tanggal_masuk_raw TEXT,
    status TEXT
);

-- Buat tabel mata_kuliah
CREATE TABLE IF NOT EXISTS src.mata_kuliah (
    kode_mk TEXT,
    nama_mk TEXT,
    kode_prodi TEXT,
    sks INTEGER,
    semester_rekomendasi INTEGER,
    kelompok TEXT,
    ada_silabus TEXT
);

-- ==========================================================
-- POINT 9: DATA INVENTORY — HITUNG JUMLAH BARIS
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
-- POINT 10: EKSPLORASI AWAL
-- ==========================================================
-- 1. Cek NIM unik & indikasi duplikat
SELECT 
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT nim) AS distinct_nim,
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;

-- 2. Cek kota_asal_raw yang kosong
SELECT COUNT(*) AS missing_kota
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';

-- 3. Lihat variasi label prodi_raw
SELECT prodi_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;

-- ==========================================================
-- POINT 11: PROBLEM CHALLENGE 1–9
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

-- 2. Jumlah NIM unik vs total baris
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
    COUNT(*) - COUNT(DISTINCT nim) AS baris_duplikat
FROM src.mahasiswa;

-- 4. Rentang angkatan
SELECT 
    MIN(angkatan_raw) AS angkatan_paling_awal,
    MAX(angkatan_raw) AS angkatan_paling_akhir
FROM src.mahasiswa;

-- 5. Mahasiswa dengan kota_asal_raw kosong
SELECT 
    COUNT(*) AS kota_asal_kosong
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';

-- 6. Jumlah label prodi_raw unik vs master program studi
SELECT COUNT(DISTINCT prodi_raw) AS jumlah_label_prodi_di_mahasiswa
FROM src.mahasiswa;

SELECT COUNT(*) AS jumlah_prodi_di_master
FROM src.program_studi;

-- 7. Tiga pola ketidakkonsistenan lain
-- a. Variasi format jenis kelamin
SELECT jenis_kelamin_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY jenis_kelamin_raw;

-- b. Variasi format tanggal lahir
SELECT tanggal_lahir_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY tanggal_lahir_raw
LIMIT 15;

-- c. Variasi penulisan nama prodi di dosen
SELECT prodi_raw, COUNT(*) AS jumlah
FROM src.dosen
GROUP BY prodi_raw
ORDER BY prodi_raw;