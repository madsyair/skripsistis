# skripsistis 0.2.4

## Sitasi lembaga & rujukan persamaan

* **Sitasi lembaga/instansi & direktorat kementerian.** Ditambah contoh + panduan:
  lembaga (pedoman 4.4) ditulis pertama nama lengkap+akronim lalu akronim saja
  (`author = {{Badan Pusat Statistik}}`); direktorat di bawah kementerian (APA-7)
  memakai direktorat sebagai **penulis** dan kementerian sebagai **penerbit**
  (`institution = {Kementerian …}`). Pada CSL pola pertama-penuh-akronim ditulis
  manual dengan `[BPS, -@kunci]`.
* **Klarifikasi rujukan persamaan.** Kata "Persamaan"/"persamaan" **ditulis manual**;
  `@eq-...` (dengan `eq-prefix` kosong) hanya menghasilkan nomor "(N)". Tabel panduan
  pada `referensi-perintah.qmd` diperbaiki agar tidak menyiratkan otomatis.

## Koreksi jarak judul daftar 

* **Jarak judul daftar -> "Halaman"/header = 4 spasi.** Pedoman (Lampiran 7 & 8)
  secara eksplisit menganotasi jarak **4 spasi** antara judul daftar
  (DAFTAR ISI/TABEL/GAMBAR/LAMPIRAN) dengan baris "Halaman"/header kolom. Nilai
  ini dipulihkan (`\vskip2\spasi`, terverifikasi rasio thd tinggi entri 2,58 vs
  pedoman 2,60). Jarak "Halaman"/header -> entri pertama ~2 spasi. Selaras dengan
  Overleaf.

## Perbaikan halaman muka & daftar

* **Sampul & halaman judul presisi pedoman.** Konstruksi disamakan dengan template
  LaTeX Overleaf yang sudah diverifikasi terhadap pedoman (Lampiran 1 & 2):
  judul kapital 14 pt jarak antar baris **2 spasi** mulai ~baris kedua
  (terverifikasi **0,71 cm** di bawah margin atas), subjudul 1,5 spasi, blok
  Program Studi/Peminatan **di tengah** (nilai membungkus), tiga baris penutup
  (STIS/JAKARTA/tahun) 14 pt/1,5 spasi terkunci di bawah via `\vfill`. Jarak antar
  bagian memakai satuan `\spasi` (5 spasi, 4,5 spasi, dst.).
* **Jarak daftar lebih wajar.** Pada Daftar Isi/Tabel/Gambar/Lampiran: jarak
  **judul daftar → header/"Halaman"** dipangkas (mis. judul→header tabel dari 4
  menjadi **1,5 baris**) dan jarak **"Halaman"/header → entri** menjadi **1 baris**
  (sebelumnya 2 / 1,5 baris). Selaras dengan Overleaf.

## Perubahan tata letak tabel & gambar

* **Judul tabel & gambar DIPUSATKAN.** `tabel_skripsi()`, `tabel_skripsi_panjang()`,
  dan `gambar_skripsi()` kini menaruh judul (`\captionof`) **di tengah** (boleh
  melebihi tepi kiri-kanan objek), bukan rata tepi kiri objek. Setelan caption
  `justification=centering` pada `preamble.tex`.
* **Sumber tetap di tepi kiri objek.** Baris *Sumber*/*Keterangan* tetap dirata-
  kirikan pada tepi kiri tabel/gambar (via `\parbox` selebar objek). Untuk
  **gambar**, urutan tetap **gambar → Sumber → judul**.
* Selaras dengan template LaTeX Overleaf (`skripsistis-overleaf`).

# skripsistis 0.2.3

## Perbaikan

* **Pernyataan edisi pada Daftar Pustaka.** CSL kini menulis edisi sebagai
  **"Edisi ke-N"** (mis. "Edisi ke-2") dan istilah `edition` dieja kapital
  "Edisi", konsisten dengan template LaTeX Overleaf. Penyingkatan editor tetap
  **"Ed."** (tunggal) dan **"Eds."** (jamak).

# skripsistis 0.2.2

## Perbaikan (tindak lanjut review pedoman)

* **Font Times New Roman asli.** Template kini memakai berkas *Times New Roman*
  yang sesungguhnya bila tersedia di sistem (Windows/macOS atau Linux dengan
  msttcorefonts), dan hanya jatuh ke klon metrik *TeX Gyre Termes* bila tidak ada.
  Berlaku untuk teks dokumen maupun font grafik (tikz/`gambar_skripsi`).
* **Jarak judul deterministik.** Jarak judul bab/subbab tidak lagi "dikalibrasi
  mendekati": kini eksak dalam satuan `\normalbaselineskip` (1 spasi tunggal) sesuai
  pedoman hlm. 34-35 — **bab -> subbab = 4 spasi**, **bab/subbab -> teks = 3 spasi**,
  judul level-4 (pokok bahasan) **4 spasi** di atasnya.
* **Sistematika penulisan sesuai jenis skripsi.** Paragraf "Sistematika Penulisan"
  pada Bab I kini otomatis menyebut **lima bab** (Analisis) atau **enam bab**
  (Pengembangan Sistem) — sebelumnya "lima bab" ter-*hardcode* dan salah untuk
  varian Sistem Informasi Statistik.
* **Singkatan editor & halaman pada CSL** (mengikuti pedoman & APA 7 Indonesia):
  - **Editor** disingkat **"Ed."** (tunggal) dan **"Eds."** (jamak) — sebelumnya
    "ed." untuk keduanya.
  - Penunjuk halaman memakai **"hal."** (sesuai contoh pedoman), menggantikan "hlm.".
    Teks petunjuk pada template diselaraskan; locator `[@kunci, hal. 5]` dikenali.
* **Posisi tabel di tengah halaman.** Tabel panjang (`tabel_skripsi_panjang()`) kini
  **dipusatkan** (simetris di tengah lebar teks, sesuai pedoman) — bukan rata kiri —
  sambil mempertahankan lebar minimal 80% serta batas kiri judul/Sumber yang tetap
  berimpit dengan tepi kiri tabel.

# skripsistis 0.2.1

## Perbaikan

* **Batas kiri & kanan + lebar minimal tabel panjang.** `tabel_skripsi_panjang()`
  kini menjamin tepi tabel rapi dan seragam:
  - Judul tabel (termasuk judul panjang yang membungkus ke beberapa baris) serta
    baris Sumber/Keterangan **diikat ke lebar tabel** sehingga **batas kirinya
    berimpit dengan tepi kiri tabel** — seragam dengan `tabel_skripsi()`
    (sebelumnya judul membentang selebar teks).
  - **Lebar tabel panjang kini minimal 80% lebar teks** (default 0,8; nilai `< 0,8`
    dinaikkan otomatis ke 0,8; maksimum 1) dengan **batas kanan terkontrol** pada
    lebar target — tepi kanan tidak lagi menggantung mengikuti isi. Kolom label
    (perataan `"l"`) melebar mengisi ruang, kolom angka tetap ringkas.

* **Dokumentasi (README).** Disinkronkan dengan implementasi: jarak baris (teks isi
  **2 spasi**, bagian awal **1,5 spasi**) kini diterapkan otomatis tanpa penyuntingan
  manual; catatan Daftar Isi "1 PENDAHULUAN" yang usang dihapus (entri bab sudah tampil
  "BAB I"); klaim "meterai" pada halaman pernyataan diluruskan; struktur proyek dilengkapi
  berkas terkelola/opsional; nomor versi pemasangan diperbaiki.

# skripsistis 0.2.0

## Fitur baru

* **Pembaruan tanpa menyusun ulang.** Berkas infrastruktur format kini
  *dikelola paket* dan disegarkan otomatis dari paket terpasang setiap kali
  `render_skripsi()` dijalankan (atau manual via `perbarui_template()`).
  Mahasiswa cukup **memperbarui paket** lalu render ulang  -  perbaikan format
  langsung berlaku tanpa membuat ulang proyek. Isi skripsi (`bab/`,
  `referensi.bib`, `singkatan.csv`, `img/`, `index.qmd`, `_quarto.yml`,
  `tex/00_frontmatter.tex`) tidak pernah disentuh. Kustomisasi LaTeX mahasiswa
  ditulis di `tex/preamble-tambahan.tex` (tidak ditimpa).

* **Fungsi tabel patuh pedoman**: `tabel_skripsi()` dan
  `tabel_skripsi_panjang()`. Satu pemanggilan menghasilkan tabel sesuai
  Pedoman KS 2025 (judul di atas, grid, baris nomor kolom rata tengah dengan
  garis pemisah, Sumber/Keterangan menyatu, non-float). Menggantikan blok
  LaTeX panjang yang sebelumnya disalin ke tiap bab.

* `perbarui_template()` (baru, terekspor): menyegarkan berkas terkelola pada
  proyek lama, mencadangkan berkas lama ke `.bak`, melaporkan perubahan.

* `render_skripsi(perbarui = TRUE)`: menyegarkan berkas terkelola sebelum render.

## Perbaikan

* **Jarak persamaan** (display math) diperbaiki agar ~1 baris dari teks
  sebelum/sesudahnya sesuai pedoman hlm. 8 (sebelumnya membengkak beberapa
  baris akibat spasi ganda). Diatur via `\AtBeginEnvironment` pada lingkungan
  persamaan di `preamble.tex`.

# skripsistis 0.1.0

## Fitur baru

* Mode `"glossaries"` kini memisahkan **Daftar Singkatan** dan **Daftar
  Simbol** (dua glossary, kolom `tipe`). Entri dapat ditulis langsung di teks
  via `\\istilah{...}` / `\\simbol{...}` (diangkat ke preamble oleh pemindai
  pra-render `scan_singkatan.R`) selain dari `singkatan.csv`; bila kunci sama,
  sumber pusat diutamakan sehingga tidak ada konflik. Daftar memakai header kolom.

* `buat_skripsi(daftar_singkatan = "glossaries")` menambah mode otomatis
  berbasis paket `glossaries` (`\\makenoidxglossaries`): singkatan/simbol muncul
  di daftar **hanya bila dipakai** di teks lewat `\\gls{kunci}`, terurut otomatis.
  Entri didefinisikan di `tex/singkatan-entries.tex`. Mode tabel CSV manual
  (`TRUE`/`"csv"`) tetap tersedia sebagai default elemen.

* `buat_skripsi()` kini mendukung elemen **Daftar Singkatan dan Simbol** yang
  opsional melalui argumen `daftar_singkatan` (default `FALSE`). Isi daftar
  bersifat *live-computed* dari berkas `singkatan.csv` dan dapat diisi langsung
  lewat argumen `singkatan` (data.frame 2 kolom, matriks 2 kolom, atau vektor
  karakter bernama). Elemen ditempatkan setelah Daftar Lampiran dengan gaya judul
  dan penomoran halaman (angka Romawi kecil) yang seragam dengan daftar lain.
  Pedoman KS 2025 tidak mewajibkan elemen ini sehingga default-nya nonaktif.

## Rilis awal

* Template Quarto + XeLaTeX skripsi D-IV Komputasi Statistik (peminatan Sains Data
  dan Sistem Informasi Statistik) sesuai Pedoman KS 2025: sampul/pengesahan,
  penomoran tabel/gambar/persamaan deret tunggal, header daftar, kutipan APA 7
  modifikasi Indonesia, dan templat proyek RStudio.
