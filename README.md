# skripsistis

Template **Quarto** untuk penyusunan skripsi yang **dikhususkan bagi mahasiswa
Program Studi D-IV Komputasi Statistik, Politeknik Statistika STIS**, disusun
mengikuti *Pedoman Skripsi KS Edisi Keenam (2025)*. Paket ini membuat proyek
skripsi siap pakai—lengkap dengan halaman muka, pengaturan format, dan gaya
kutipan **APA edisi ke-7 dengan modifikasi bahasa Indonesia**.

> **Khusus Prodi D-IV Komputasi Statistik.** Seluruh ketentuan (halaman muka,
> peminatan Sains Data / Sistem Informasi Statistik, kerangka bab, gaya sitasi)
> mengacu pada pedoman skripsi Prodi Komputasi Statistik. Template ini **tidak
> ditujukan** untuk program studi lain (mis. D-IV Statistika) yang memiliki
> pedoman dan format berbeda.

> ️ **Status: versi pengembangan (tidak resmi).**
> Paket ini masih dalam tahap pengembangan dan **belum sepenuhnya mengikuti**
> panduan penulisan skripsi Politeknik Statistika STIS. Format, tata letak, dan
> ketentuan yang dihasilkan **dapat berubah** serta perlu diperiksa kembali
> terhadap pedoman resmi sebelum digunakan untuk pengajuan. Ini **bukan** templat
> resmi yang dikeluarkan oleh Politeknik Statistika STIS.
>
> Setelah seluruh ketentuan sesuai dengan panduan penulisan skripsi, **versi
> stabil** akan dirilis. Masukan dan koreksi sangat diharapkan.

## Fitur

- **Halaman muka otomatis**: sampul, halaman judul, pernyataan, pengesahan
  (tim penguji + pembimbing), dan lembar hak cipta — terisi dari argumen fungsi.
  (Catatan: blok tanda tangan pada halaman pernyataan tidak menyertakan kotak
  meterai; tambahkan sendiri bila Program Studi mensyaratkannya.)
- **Format STIS**: kertas A4, margin *mirror* (dalam/binding 4 cm, luar/atas/bawah
  3 cm) untuk cetak bolak-balik, font **Times New Roman** (memakai berkas asli bila
  tersedia di sistem, jika tidak memakai klon metrik TeX Gyre Termes), **spasi 2 pada teks
  isi** dan **1,5 pada bagian awal** (abstrak, daftar, dll.; daftar pustaka 1 spasi
  per-entri), judul bab "BAB I" rata tengah dan kapital (Romawi pada judul, subbab
  bernomor Arab 1.1, 1.2, ...), nomor halaman bagian awal Romawi (tengah bawah) dan
  bagian isi Arab (kanan bawah).
- **Tabel sesuai pedoman**: judul di atas tabel berawalan "Tabel" (bukan "Table"),
  baris nomor kolom (1), (2), (3), baris "Sumber" untuk data sekunder, serta dukungan
  `longtable` (tabel lintas-halaman, judul "Tabel N (lanjutan)") dan `pdflscape`
  (tabel lebar landscape). Pada tabel panjang, **batas kiri & kanan judul/tabel
  terkontrol dan seragam** (judul yang membungkus beberapa baris pun berimpit dengan
  tepi tabel) dengan **lebar minimal 80% lebar teks**. Gambar berjudul "Gambar" di
  bawah objek.
- **Daftar lengkap**: Daftar Isi (entri bab berawalan "BAB I", "BAB II", ...),
  Daftar Tabel, Daftar Gambar, dan **Daftar Lampiran**.
- **Dua varian kerangka bab sesuai peminatan**:
  - *Sains Data* — Bab I Pendahuluan, II Tinjauan Pustaka, III Metode Penelitian,
    IV Hasil dan Pembahasan, V Kesimpulan dan Saran.
  - *Sistem Informasi Statistik* — Bab I–III sama, lalu IV Analisis dan Perancangan,
    V Implementasi dan Evaluasi, VI Kesimpulan dan Saran.
- **Templat Proyek RStudio**: tersedia di *File → New Project → New Directory →
  Skripsi Komputasi Statistik (Politeknik Statistika STIS)*.
- **Contoh chunk R dan Python**: chunk R dieksekusi langsung; chunk Python dapat
  diaktifkan melalui `reticulate`.
- **Kerangka pikir**: placeholder diagram kerangka pikir (Permasalahan-Tujuan-Solusi-
  Evaluasi) pada Bab III sesuai pedoman.
- **Urutan halaman sesuai pedoman**: Sampul → Judul → Pernyataan → Pengesahan →
  Hak Cipta → Prakata → Abstrak → Daftar Isi → Daftar Tabel → Daftar Gambar →
  Daftar Lampiran → Bab I–V (atau I–VI untuk Sistem Informasi Statistik) →
  Daftar Pustaka → Lampiran → Riwayat Hidup. Halaman
  muka bernomor Romawi kecil mulai dari Prakata (i), isi bernomor Arab di kanan bawah.
- **Sitasi APA 7 Indonesia** (`apa-stis-id.csl`): penghubung **dan**, tiga penulis
  atau lebih disingkat **dkk.**, tanpa tahun **t.t.**, edisi **ed. ke-2**,
  penerjemah **Penerj.** Daftar pustaka tersusun otomatis dan alfabetis.
- **Komputasi langsung**: contoh tabel dan gambar dihitung dari kode R sehingga
  angka pada naskah selalu konsisten.
- **Penulisan matematika**: lingkungan **Definisi, Teorema, Lema, Akibat, Proposisi,
  Contoh** (judul + rujukan silang berbahasa Indonesia) beserta lingkungan **Bukti**,
  semuanya bernomor dan dapat dirujuk dengan `@def-`, `@thm-`, dan seterusnya.
- **Algoritma**: lingkungan `algorithm2e` dengan nama "Algoritme", kata kunci Indonesia
  (Masukan, Keluaran, untuk, selama, kembalikan), dan penomoran deret tunggal
  (mis. Algoritme 1).
- **Kode sebagai gambar**: potongan kode dapat diberi judul "Gambar x. ..." dan dirujuk
  silang layaknya gambar (masuk pula ke Daftar Gambar), lengkap dengan nomor baris agar
  mudah dijelaskan baris per baris.
- **Font grafik = font dokumen**: grafik R dirender dengan `tikzDevice` (xelatex) sehingga
  ber-font Times New Roman serasi dengan teks dan dapat memuat simbol LaTeX
  (mis. `$\alpha$`, `$\sigma^2$`) pada label.

## Prasyarat

- [R](https://www.r-project.org/) beserta paket `knitr`, `rmarkdown`, dan `tikzDevice`
- [Quarto](https://quarto.org/) >= 1.4
- Distribusi LaTeX dengan **XeLaTeX** dan paket `algorithm2e` (mis. TinyTeX:
  `quarto install tinytex`; paket LaTeX akan dipasang otomatis saat render pertama)

## Pemasangan

```r
remotes::install_github("madsyair/skripsistis")
```

## Penggunaan

```r
library(skripsistis)

buat_skripsi(
  path       = "skripsi-saya",
  judul      = "Pemodelan Proxy Means Test Berbasis GPBoost di Provinsi Jawa Timur",
  subjudul   = NULL,
  nama       = "Nama Mahasiswa",
  nim        = "222212501",
  peminatan  = "Sains Data",
  ketua_prodi = "Nama Ketua Program Studi",
  pembimbing = "Nama Pembimbing",
  render     = TRUE        # langsung render ke PDF
)
```

Render manual kapan saja:

```bash
quarto render skripsi-saya
```

Hasil PDF berada di `skripsi-saya/_output/`.

### Daftar Singkatan dan Simbol (opsional)

Pedoman KS 2025 tidak mewajibkan elemen ini, sehingga **nonaktif secara
bawaan**. Aktifkan dengan `daftar_singkatan = TRUE`; elemen muncul setelah
Daftar Lampiran dengan gaya judul dan penomoran halaman yang seragam. Isinya
*live-computed* dari `singkatan.csv` (kolom 1 = singkatan/simbol, boleh memuat
matematika dalam `$...$`; kolom 2 = keterangan) dan dapat diisi langsung:

```r
buat_skripsi(
  path = "skripsi-saya", peminatan = "Sains Data",
  daftar_singkatan = TRUE,
  singkatan = c(
    "BPS"        = "Badan Pusat Statistik",
    "RMSE"       = "Root Mean Squared Error",
    "$\\mu$"     = "rata-rata populasi",
    "$\\sigma$"  = "simpangan baku populasi"
  ),
  render = TRUE
)
```

`singkatan` menerima vektor karakter bernama, `data.frame` 2 kolom, atau matriks
2 kolom. Tanpa argumen ini, dipakai contoh `singkatan.csv` bawaan yang dapat
disunting langsung. Entri diurutkan alfabetis otomatis.

#### Mode otomatis: Daftar Singkatan & Daftar Simbol (glossaries)

`daftar_singkatan = "glossaries"` memakai paket `glossaries`
(`\\makenoidxglossaries`, murni LaTeX). Istilah **muncul otomatis hanya bila
dipakai** di teks, terpisah menjadi dua daftar: **Daftar Singkatan** dan **Daftar
Simbol** (dibedakan kolom `tipe`). Entri dapat berasal dari dua sumber yang
digabung tanpa konflik (sumber pusat diutamakan):

1. **Daftar pusat** `singkatan.csv` (kolom `kunci,tipe,nama,keterangan`).
2. **Langsung di teks**: `\\istilah{kunci}{nama}{keterangan}` untuk singkatan dan
   `\\simbol{kunci}{nama}{keterangan}` untuk simbol. Cukup ditulis sekali di
   mana pun dalam naskah; sebuah pemindai pra-render (`scan_singkatan.R`)
   mengangkat definisinya secara otomatis.

```r
buat_skripsi(
  path = "skripsi-saya", daftar_singkatan = "glossaries",
  singkatan = data.frame(
    kunci = c("bps", "alpha"),
    tipe  = c("singkatan", "simbol"),
    nama  = c("BPS", "$\\alpha$"),
    keterangan = c("Badan Pusat Statistik", "taraf nyata")
  ),
  render = TRUE
)
```

Di teks, rujuk dengan `\\gls{bps}`, `\\gls{alpha}`, dst. Hanya istilah yang
dipakai yang tampil; urutannya otomatis.

## Struktur proyek yang dihasilkan

Contoh untuk peminatan **Sains Data** (varian Sistem Informasi Statistik memakai
`bab3_metode_si.qmd`, `bab4_analisis.qmd`, `bab5_implementasi.qmd`, `bab5_kesimpulan.qmd`):

```
skripsi-saya/
├── _quarto.yml              # konfigurasi (format, CSL, bibliografi)
├── _skripsistis.yml         # konfigurasi paket (untuk pembaruan terkelola)
├── index.qmd                # Prakata, Abstrak, Daftar Isi/Tabel/Gambar, include bab
├── referensi.bib            # basis data referensi (BibTeX)
├── apa-stis-id.csl          # gaya sitasi APA 7 modifikasi Indonesia
├── singkatan.csv            # isi Daftar Singkatan/Simbol (bila diaktifkan)
├── bab/
│   ├── bab1_pendahuluan.qmd
│   ├── bab2_tinjauan_pustaka.qmd
│   ├── bab3_metode.qmd
│   ├── bab4_hasil.qmd
│   ├── bab5_kesimpulan.qmd
│   └── lampiran.qmd
├── tex/
│   ├── preamble.tex            # format terkelola (margin, font, spasi, judul bab)
│   ├── preamble-tambahan.tex   # kustomisasi LaTeX Anda (TIDAK ditimpa saat pembaruan)
│   └── 00_frontmatter.tex      # sampul s.d. lembar hak cipta
└── img/                     # logo_stis.png sudah disertakan (boleh diganti)
```

Berkas infrastruktur format **dikelola paket** dan disegarkan otomatis dari paket
terpasang setiap kali `render_skripsi()` dijalankan (atau manual via
`perbarui_template()`), sehingga perbaikan format cukup dengan **memperbarui paket**
lalu render ulang — tanpa membuat ulang proyek. Isi skripsi (`bab/`, `referensi.bib`,
`singkatan.csv`, `img/`, `index.qmd`) tidak pernah disentuh.

## Menulis kutipan

Tambahkan entri ke `referensi.bib`, lalu rujuk di naskah:

| Penulisan         | Hasil                       |
|-------------------|-----------------------------|
| `[@kunci2025]`    | (Nama dkk., 2025)           |
| `@kunci2025`      | Nama dkk. (2025)            |
| `[@a2020; @b2021]`| (A dkk., 2020; B dkk., 2021)|

## Penulisan matematika, algoritma, dan kode-sebagai-gambar

**Definisi / Teorema / Lema / Bukti** (rujuk dengan `@def-`, `@thm-`, dst.):

````markdown
::: {#def-pmt}
**(Proxy Means Test).** Misalkan $y_i$ ... .
:::

::: {#thm-takbias}
Penduga kuadrat terkecil bersifat takbias.
:::

::: {.proof}
Bukti ... . $\qed$
:::

Lihat @def-pmt dan @thm-takbias.
````

**Algoritma** (penomoran deret tunggal; rujuk dengan `\ref{...}`):

````markdown
```{=latex}
\begin{algorithm}[H]
\caption{Estimasi PMT}\label{alg-pmt}
\KwIn{Data $\mathbf{X}$, target $y$}
\KwOut{Model $\hat{f}$}
\ForEach{kandidat $m$}{ Latih $m$\; }
\Return $\hat{f}$\;
\end{algorithm}
```
Lihat Algoritme \ref{alg-pmt}.
````

**Kode sebagai gambar** (judul "Gambar x."; nomor baris dengan `.numberLines`; rujuk dengan `@fig-`):

````markdown
::: {#fig-kode-regresi}
```{.r .numberLines}
model <- lm(y ~ x, data = dat)
```

Kode penghitungan regresi linear
:::

Lihat @fig-kode-regresi.
````

**Font grafik = Times + simbol LaTeX.** Setelan global pada `index.qmd` sudah mengaktifkan
`dev = "tikz"` untuk semua gambar saat output PDF, sehingga grafik ber-font Times dan
dapat memuat simbol LaTeX pada label, mis. `xlab = "Sumbu $\\alpha$"` (perhatikan *double
backslash* di dalam string R). Untuk satu gambar tertentu yang tidak ingin memakai tikz,
tambahkan opsi chunk `#| dev: ragg_png`.

### Chunk R dan Python

Template memakai mesin **knitr**. Chunk **R** dieksekusi langsung. Chunk **Python**
dapat dijalankan pada dokumen yang sama melalui paket `reticulate`:

````markdown
```{r}
nilai <- c(70, 85, 90, 65, 78)
mean(nilai)
```

```{python}
#| eval: false
import numpy as np
print(np.array([70, 85, 90, 65, 78]).mean())
```
````

Untuk mengaktifkan Python: `install.packages("reticulate")`, arahkan ke interpreter
Python (mis. `reticulate::install_miniconda()`), lalu hapus `#| eval: false`. Contoh
kedua chunk sudah tersedia di Bab IV (Hasil dan Pembahasan) pada peminatan Sains Data.

## Catatan modifikasi APA 7 → Indonesia

Berkas `apa-stis-id.csl` diturunkan dari gaya resmi *APA 7th edition* (CSL),
kemudian disesuaikan: penghubung antarpenulis menggunakan kata "dan" (bukan
"&"), istilah dilokalkan ke bahasa Indonesia (`dkk.`, `t.t.`, `dalam`,
`diakses`, `ed. ke-N`, `Penerj.`), dan dokumen di-set `lang: id`.

## Catatan kepatuhan & spasi

Beberapa ketentuan format telah disesuaikan dengan Pedoman Skripsi KS Edisi Keenam
(2025): penamaan "Tabel"/"Gambar", baris nomor kolom dan baris sumber pada tabel,
judul bab "BAB I" dengan subbab Arab, nomor halaman isi di kanan bawah, Daftar
Lampiran, ukuran font institusi 14 pt, logo 5 cm, serta placeholder kerangka pikir.

Mengenai jarak baris (sesuai pedoman hlm. 34, diterapkan **otomatis**): **teks isi
(Bab I dst.) diketik 2 spasi**, sedangkan **halaman muka, abstrak, dan daftar-daftar
1,5 spasi**; Daftar Pustaka 1 spasi di dalam entri dengan jarak ~1,5 spasi antar-entri.
Tidak diperlukan penyuntingan manual: pengaturan ini sudah ditanam pada `index.qmd`
dan `tex/preamble.tex`. Bila Program Studi meminta jarak berbeda, sesuaikan
`\doublespacing`/`\onehalfspacing` pada bagian terkait di `tex/preamble.tex`
(kustomisasi yang tidak ditimpa saat pembaruan paket ditulis di
`tex/preamble-tambahan.tex`).

Pada Daftar Isi, entri bab tampil dengan awalan "BAB I", "BAB II", ... (Romawi)
diikuti judul bab, sedangkan subbab bernomor Arab (1.1, 1.2, ...) — sesuai contoh
Daftar Isi pada pedoman (Lampiran 7).
