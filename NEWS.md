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
