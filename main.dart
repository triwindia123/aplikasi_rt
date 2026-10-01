import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const AplikasiRTApp());
}

// ==========================================
// MODEL DATA WARGA
// ==========================================
class Warga {
  String nomorKK;
  String nik;
  String nama;
  String tempatLahir;
  DateTime tanggalLahir;
  String jenisKelamin;
  String pekerjaan;
  String agama;
  String statusPernikahan;
  bool isIbuHamil;
  bool isKurangMampu;

  Warga({
    required this.nomorKK,
    this.nik = '3201000000000000',
    required this.nama,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.pekerjaan = 'Karyawan Swasta',
    this.agama = 'Islam',
    required this.statusPernikahan,
    this.isIbuHamil = false,
    this.isKurangMampu = false,
  });

  int get usia {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age;
  }

  String get kategoriUsia {
    if (usia <= 1) return 'Bayi';
    if (usia <= 12) return 'Anak-anak';
    if (usia <= 59) return 'Dewasa';
    return 'Lansia';
  }

  Map<String, dynamic> toJson() => {
        'nomorKK': nomorKK,
        'nik': nik,
        'nama': nama,
        'tempatLahir': tempatLahir,
        'tanggalLahir': tanggalLahir.toIso8601String(),
        'jenisKelamin': jenisKelamin,
        'pekerjaan': pekerjaan,
        'agama': agama,
        'statusPernikahan': statusPernikahan,
        'isIbuHamil': isIbuHamil,
        'isKurangMampu': isKurangMampu,
      };

  factory Warga.fromJson(Map<String, dynamic> json) => Warga(
        nomorKK: json['nomorKK'],
        nik: json['nik'] ?? '3201000000000000',
        nama: json['nama'],
        tempatLahir: json['tempatLahir'],
        tanggalLahir: DateTime.parse(json['tanggalLahir']),
        jenisKelamin: json['jenisKelamin'],
        pekerjaan: json['pekerjaan'] ?? 'Karyawan Swasta',
        agama: json['agama'] ?? 'Islam',
        statusPernikahan: json['statusPernikahan'],
        isIbuHamil: json['isIbuHamil'] ?? false,
        isKurangMampu: json['isKurangMampu'] ?? false,
      );
}

// ==========================================
// MODEL DATA IURAN / KAS RT
// ==========================================
class TransaksiKas {
  String id;
  String jenis; // 'pemasukan' atau 'pengeluaran'
  String keterangan;
  double jumlah;
  String bulan;
  int tahun;
  DateTime tanggal;
  String? namaWarga;

  TransaksiKas({
    required this.id,
    required this.jenis,
    required this.keterangan,
    required this.jumlah,
    required this.bulan,
    required this.tahun,
    required this.tanggal,
    this.namaWarga,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenis': jenis,
        'keterangan': keterangan,
        'jumlah': jumlah,
        'bulan': bulan,
        'tahun': tahun,
        'tanggal': tanggal.toIso8601String(),
        'namaWarga': namaWarga,
      };

  factory TransaksiKas.fromJson(Map<String, dynamic> json) => TransaksiKas(
        id: json['id'],
        jenis: json['jenis'],
        keterangan: json['keterangan'],
        jumlah: (json['jumlah'] as num).toDouble(),
        bulan: json['bulan'],
        tahun: json['tahun'],
        tanggal: DateTime.parse(json['tanggal']),
        namaWarga: json['namaWarga'],
      );
}

// ==========================================
// MAIN APP & THEME
// ==========================================
class AplikasiRTApp extends StatelessWidget {
  const AplikasiRTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi RT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005691),
          primary: const Color(0xFF005691),
          surface: const Color(0xFFF7F9FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        fontFamily: 'sans-serif',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// HALAMAN LOADING / SPLASH SCREEN MODERN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Memberikan jeda loading modern 2.5 detik
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BerandaUtama()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005691),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.holiday_village_rounded,
                size: 80,
                color: Color(0xFF005691),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Aplikasi Pelayanan RT',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mudah, Transparan, & Praktis',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            const Text(
              'Memuat data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// BERANDA UTAMA
// ==========================================
class BerandaUtama extends StatefulWidget {
  const BerandaUtama({super.key});

  @override
  State<BerandaUtama> createState() => _BerandaUtamaState();
}

class _BerandaUtamaState extends State<BerandaUtama> {
  List<Warga> listWarga = [];
  List<TransaksiKas> listTransaksi = [];

  String noRT = '05';
  String noRW = '02';
  String namaDesa = 'Sukamaju';
  String namaKecamatan = 'Cibinong';

  @override
  void initState() {
    super.initState();
    _loadDataAplikasi();
  }

  Future<void> _saveDataAplikasi() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listJsonWarga = listWarga.map((w) => jsonEncode(w.toJson())).toList();
    List<String> listJsonKas = listTransaksi.map((t) => jsonEncode(t.toJson())).toList();

    await prefs.setStringList('data_warga_rt', listJsonWarga);
    await prefs.setStringList('data_kas_rt', listJsonKas);
    await prefs.setString('no_rt', noRT);
    await prefs.setString('no_rw', noRW);
    await prefs.setString('nama_desa', namaDesa);
    await prefs.setString('nama_kecamatan', namaKecamatan);
  }

  Future<void> _loadDataAplikasi() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? listJsonWarga = prefs.getStringList('data_warga_rt');
    List<String>? listJsonKas = prefs.getStringList('data_kas_rt');

    setState(() {
      if (listJsonWarga != null) {
        listWarga = listJsonWarga
            .map((item) => Warga.fromJson(jsonDecode(item)))
            .toList()
            .cast<Warga>();
      }
      if (listJsonKas != null) {
        listTransaksi = listJsonKas
            .map((item) => TransaksiKas.fromJson(jsonDecode(item)))
            .toList()
            .cast<TransaksiKas>();
      }
      noRT = prefs.getString('no_rt') ?? '05';
      noRW = prefs.getString('no_rw') ?? '02';
      namaDesa = prefs.getString('nama_desa') ?? 'Sukamaju';
      namaKecamatan = prefs.getString('nama_kecamatan') ?? 'Cibinong';
    });
  }

  void _tambahWarga(Warga wargaBaru) {
    setState(() {
      listWarga.add(wargaBaru);
    });
    _saveDataAplikasi();
  }

  void _tambahTransaksi(TransaksiKas transaksiBaru) {
    setState(() {
      listTransaksi.add(transaksiBaru);
    });
    _saveDataAplikasi();
  }

  void _showUbahWilayahDialog() {
    final rtController = TextEditingController(text: noRT);
    final rwController = TextEditingController(text: noRW);
    final desaController = TextEditingController(text: namaDesa);
    final kecController = TextEditingController(text: namaKecamatan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur Wilayah RT / RW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rtController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Nomor RT', hintText: 'Contoh: 05'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rwController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Nomor RW', hintText: 'Contoh: 02'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desaController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Nama Desa / Kelurahan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kecController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Nama Kecamatan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005691),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                noRT = rtController.text.isEmpty ? noRT : rtController.text;
                noRW = rwController.text.isEmpty ? noRW : rwController.text;
                namaDesa = desaController.text.isEmpty ? namaDesa : desaController.text;
                namaKecamatan = kecController.text.isEmpty ? namaKecamatan : kecController.text;
              });
              _saveDataAplikasi();
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color(0xFF005691),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang,', style: TextStyle(fontSize: 16, color: Colors.white70)),
            Text('Pengurus RT', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Kartu Informasi Wilayah
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF005691).withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.location_city, size: 34, color: Color(0xFF005691)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RT $noRT / RW $noRW', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF005691))),
                          const SizedBox(height: 2),
                          Text('Desa $namaDesa, Kec. $namaKecamatan', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.orange, size: 36),
                      onPressed: _showUbahWilayahDialog,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Daftar Menu Utama
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuCard(
                      icon: Icons.people_alt_outlined,
                      title: '1. Data Warga',
                      subtitle: 'Kelola daftar keluarga & NIK warga',
                      color: const Color(0xFF1565C0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanDataWarga(
                              listWarga: listWarga,
                              onTambahWarga: _tambahWarga,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildMenuCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: '2. Iuran & Kas RT',
                      subtitle: 'Pencatatan uang masuk & keluar kas',
                      color: const Color(0xFF00897B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanIuranKas(
                              listWarga: listWarga,
                              listTransaksi: listTransaksi,
                              onTambahTransaksi: _tambahTransaksi,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildMenuCard(
                      icon: Icons.bar_chart_rounded,
                      title: '3. Rekap & Data Lansia',
                      subtitle: 'Lihat jumlah lansia, anak, & balita',
                      color: const Color(0xFF2E7D32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanRekapData(
                              listWarga: listWarga,
                              noRT: noRT,
                              noRW: noRW,
                              namaDesa: namaDesa,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildMenuCard(
                      icon: Icons.assignment_outlined,
                      title: '4. Cetak Surat Pengantar',
                      subtitle: 'Buat & cetak surat pengantar PDF resmi',
                      color: const Color(0xFFE65100),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanMintaSurat(
                              listWarga: listWarga,
                              noRT: noRT,
                              noRW: noRW,
                              namaDesa: namaDesa,
                              namaKecamatan: namaKecamatan,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 34, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 22, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN FITUR IURAN & KAS RT
// ==========================================
class HalamanIuranKas extends StatefulWidget {
  final List<Warga> listWarga;
  final List<TransaksiKas> listTransaksi;
  final Function(TransaksiKas) onTambahTransaksi;

  const HalamanIuranKas({
    super.key,
    required this.listWarga,
    required this.listTransaksi,
    required this.onTambahTransaksi,
  });

  @override
  State<HalamanIuranKas> createState() => _HalamanIuranKasState();
}

class _HalamanIuranKasState extends State<HalamanIuranKas> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  double get totalPemasukan => widget.listTransaksi
      .where((t) => t.jenis == 'pemasukan')
      .fold(0, (sum, item) => sum + item.jumlah);

  double get totalPengeluaran => widget.listTransaksi
      .where((t) => t.jenis == 'pengeluaran')
      .fold(0, (sum, item) => sum + item.jumlah);

  double get sisaKas => totalPemasukan - totalPengeluaran;

  String _formatRupiah(double number) {
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showFormTransaksi(BuildContext context, String jenis) {
    final formKey = GlobalKey<FormState>();
    final nominalController = TextEditingController();
    final keteranganController = TextEditingController();

    Warga? selectedWarga = widget.listWarga.isNotEmpty ? widget.listWarga.first : null;
    String selectedBulan = 'Januari';
    int selectedTahun = DateTime.now().year;

    List<String> listBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jenis == 'pemasukan' ? 'Catat Pemasukan / Iuran' : 'Catat Pengeluaran Kas RT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: jenis == 'pemasukan' ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 10),

                      if (jenis == 'pemasukan') ...[
                        const Text('Pilih Warga Pembayar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        widget.listWarga.isEmpty
                            ? const Text('Belum ada data warga terdaftar', style: TextStyle(color: Colors.red, fontSize: 16))
                            : DropdownButtonFormField<Warga>(
                                initialValue: selectedWarga,
                                style: const TextStyle(fontSize: 18, color: Colors.black87),
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: widget.listWarga.map((w) {
                                  return DropdownMenuItem(value: w, child: Text(w.nama));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedWarga = val),
                              ),
                        const SizedBox(height: 14),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bulan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedBulan,
                                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  items: listBulan.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                                  onChanged: (val) => setModalState(() => selectedBulan = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tahun:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<int>(
                                  initialValue: selectedTahun,
                                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  items: [2024, 2025, 2026, 2027]
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toString())))
                                      .toList(),
                                  onChanged: (val) => setModalState(() => selectedTahun = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Nominal (Rp):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 50000',
                          prefixText: 'Rp ',
                        ),
                        validator: (val) => val!.isEmpty ? 'Nominal harus diisi' : null,
                      ),
                      const SizedBox(height: 14),

                      Text(
                        jenis == 'pemasukan' ? 'Keterangan (Opsional):' : 'Tujuan Pengeluaran Kas:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: keteranganController,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: jenis == 'pemasukan'
                              ? 'Contoh: Iuran Kebersihan'
                              : 'Contoh: Beli Lampu Jalan',
                        ),
                        validator: (val) {
                          if (jenis == 'pengeluaran' && val!.isEmpty) {
                            return 'Keterangan pengeluaran wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jenis == 'pemasukan' ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              TransaksiKas transaksiBaru = TransaksiKas(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                jenis: jenis,
                                keterangan: keteranganController.text.isEmpty
                                    ? (jenis == 'pemasukan' ? 'Iuran Warga' : 'Pengeluaran RT')
                                    : keteranganController.text,
                                jumlah: double.parse(nominalController.text),
                                bulan: selectedBulan,
                                tahun: selectedTahun,
                                tanggal: DateTime.now(),
                                namaWarga: jenis == 'pemasukan' ? selectedWarga?.nama : null,
                              );

                              widget.onTambahTransaksi(transaksiBaru);
                              setState(() {});
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan Data', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TransaksiKas> listPemasukan = widget.listTransaksi.where((t) => t.jenis == 'pemasukan').toList();
    List<TransaksiKas> listPengeluaran = widget.listTransaksi.where((t) => t.jenis == 'pengeluaran').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iuran & Kas RT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF005691),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // KARTU RINGKASAN SALDO KAS
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF005691), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text('Sisa Saldo Kas RT', style: TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 6),
                Text(_formatRupiah(sisaKas), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white38, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Masuk', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(_formatRupiah(totalPemasukan), style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(height: 35, width: 1.5, color: Colors.white38),
                    Column(
                      children: [
                        const Text('Total Keluar', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(_formatRupiah(totalPengeluaran), style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TAB BAR PEMASUKAN / PENGELUARAN
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF005691),
            labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF005691),
            indicatorWeight: 4,
            tabs: const [
              Tab(icon: Icon(Icons.arrow_downward, color: Colors.green, size: 28), text: 'Uang Masuk'),
              Tab(icon: Icon(Icons.arrow_upward, color: Colors.red, size: 28), text: 'Uang Keluar'),
            ],
          ),

          // TAB VIEW RIWAYAT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListTransaksi(listPemasukan, isPemasukan: true),
                _buildListTransaksi(listPengeluaran, isPemasukan: false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 26),
                label: const Text('+ Pemasukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                onPressed: () => _showFormTransaksi(context, 'pemasukan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.remove, color: Colors.white, size: 26),
                label: const Text('+ Pengeluaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                onPressed: () => _showFormTransaksi(context, 'pengeluaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTransaksi(List<TransaksiKas> list, {required bool isPemasukan}) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isPemasukan ? 'Belum ada catatan uang masuk.' : 'Belum ada catatan uang keluar.',
          style: const TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPemasukan ? Colors.green.shade800 : Colors.red.shade800,
                size: 28,
              ),
            ),
            title: Text(
              isPemasukan ? (item.namaWarga ?? 'Iuran Warga') : item.keterangan,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Periode: ${item.bulan} ${item.tahun}', style: const TextStyle(fontSize: 15)),
                if (isPemasukan) Text('Ket: ${item.keterangan}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            trailing: Text(
              '${isPemasukan ? '+' : '-'} ${_formatRupiah(item.jumlah)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPemasukan ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// FITUR MINTA SURAT & GENERATE PDF
// ==========================================
class HalamanMintaSurat extends StatefulWidget {
  final List<Warga> listWarga;
  final String noRT;
  final String noRW;
  final String namaDesa;
  final String namaKecamatan;

  const HalamanMintaSurat({
    super.key,
    required this.listWarga,
    required this.noRT,
    required this.noRW,
    required this.namaDesa,
    required this.namaKecamatan,
  });

  @override
  State<HalamanMintaSurat> createState() => _HalamanMintaSuratState();
}

class _HalamanMintaSuratState extends State<HalamanMintaSurat> {
  Warga? _selectedWarga;
  String _jenisSurat = 'SURAT PENGANTAR';
  String _keperluan = 'Pengurusan Surat Keterangan Catatan Kepolisian (SKCK)';
  final _keperluanCustomController = TextEditingController();

  final List<String> _opsiKeperluan = [
    'Pengurusan KTP Baru / Kartu Keluarga',
    'Pengurusan Surat Keterangan Catatan Kepolisian (SKCK)',
    'Pengurusan Akta Kelahiran / Kematian',
    'Surat Keterangan Tidak Mampu (SKTM)',
    'Pengurusan Izin Usaha / Melamar Pekerjaan',
    'Lainnya (Tulis Sendiri)'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.listWarga.isNotEmpty) {
      _selectedWarga = widget.listWarga.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Surat Pengantar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF005691),
        foregroundColor: Colors.white,
      ),
      body: widget.listWarga.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Belum ada data warga terdaftar.\nSilakan tambahkan data warga terlebih dahulu di menu "Data Warga".',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formulir Pengajuan Surat RT',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF005691)),
                  ),
                  const SizedBox(height: 16),

                  const Text('Pilih Warga Pemohon:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Warga>(
                    initialValue: _selectedWarga,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: widget.listWarga.map((w) {
                      return DropdownMenuItem<Warga>(
                        value: w,
                        child: Text('${w.nama} (NIK: ${w.nik})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedWarga = val),
                  ),
                  const SizedBox(height: 18),

                  const Text('Jenis Surat:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _jenisSurat,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: ['SURAT PENGANTAR', 'SURAT KETERANGAN']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _jenisSurat = val!),
                  ),
                  const SizedBox(height: 18),

                  const Text('Keperluan Surat:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _opsiKeperluan.contains(_keperluan) ? _keperluan : 'Lainnya (Tulis Sendiri)',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: _opsiKeperluan
                        .map((k) => DropdownMenuItem(value: k, child: Text(k, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != 'Lainnya (Tulis Sendiri)') {
                          _keperluan = val!;
                        } else {
                          _keperluan = 'Lainnya';
                        }
                      });
                    },
                  ),
                  if (!_opsiKeperluan.contains(_keperluan) || _keperluan == 'Lainnya') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _keperluanCustomController,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Tuliskan Keperluan Khusus',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => _keperluan = val,
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.print, color: Colors.white, size: 30),
                      label: const Text(
                        'CETAK SURAT (PDF)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: () {
                        if (_selectedWarga == null) return;
                        _generateAndShowPdf(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _generateAndShowPdf(BuildContext context) async {
    final pdf = pw.Document();
    final warga = _selectedWarga!;
    final now = DateTime.now();
    final tanggalSurat = '${now.day} ${_getNamaBulan(now.month)} ${now.year}';
    final nomorSuratFormatted = '045.2 / ${_getRandomNoSurat()} / RT.${widget.noRT} / ${now.year}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'RUKUN TETANGGA ${widget.noRT} RUKUN WARGA ${widget.noRW}',
                        style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'DESA/KELURAHAN ${widget.namaDesa.toUpperCase()} KECAMATAN ${widget.namaKecamatan.toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Alamat Sekretariat: Wilayah RT ${widget.noRT}/RW ${widget.noRW} Desa ${widget.namaDesa}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(thickness: 2),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        _jenisSurat,
                        style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Nomor: $nomorSuratFormatted', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                pw.Text(
                  'Yang bertanda tangan di bawah ini Ketua RT ${widget.noRT} / RW ${widget.noRW} Desa ${widget.namaDesa}, Kecamatan ${widget.namaKecamatan}, menerangkan bahwa:',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 12),

                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16),
                  child: pw.Column(
                    children: [
                      _pdfRow('Nama Lengkap', ': ${warga.nama}'),
                      _pdfRow('NIK (KTP)', ': ${warga.nik}'),
                      _pdfRow('No. Kartu Keluarga', ': ${warga.nomorKK}'),
                      _pdfRow('Tempat / Tgl Lahir', ': ${warga.tempatLahir}, ${warga.tanggalLahir.day}-${warga.tanggalLahir.month}-${warga.tanggalLahir.year}'),
                      _pdfRow('Jenis Kelamin', ': ${warga.jenisKelamin}'),
                      _pdfRow('Agama', ': ${warga.agama}'),
                      _pdfRow('Pekerjaan', ': ${warga.pekerjaan}'),
                      _pdfRow('Status Perkawinan', ': ${warga.statusPernikahan}'),
                      _pdfRow('Alamat Domisili', ': RT ${widget.noRT} / RW ${widget.noRW} Desa ${widget.namaDesa}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Text(
                  'Bahwa nama yang tersebut di atas adalah benar-benar warga domisili di wilayah RT kami, dan surat pengantar ini diberikan untuk keperluan:',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                  width: double.infinity,
                  child: pw.Text(
                    _keperluan,
                    style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Demikian Surat Pengantar ini dibuat agar dapat dipergunakan sebagaimana mestinya.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 30),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Pemohon / Warga', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 50),
                        pw.Text('( ${warga.nama} )', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Mengetahui,\nKetua RW ${widget.noRW}', style: const pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
                        pw.SizedBox(height: 50),
                        pw.Text('( ........................... )', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('${widget.namaDesa}, $tanggalSurat\nKetua RT ${widget.noRT}', style: const pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
                        pw.SizedBox(height: 8),
                        pw.Stack(
                          alignment: pw.Alignment.center,
                          children: [
                            pw.Container(
                              width: 65,
                              height: 65,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue900, width: 2),
                                shape: pw.BoxShape.circle,
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  'STEMPEL RESMI\nRT ${widget.noRT}',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                            pw.Transform.rotate(
                              angle: -0.2,
                              child: pw.Text(
                                'TANDATANGAN\nDIGITAL RT',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('( Pengurus RT ${widget.noRT} )', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Surat_Pengantar_RT_${warga.nama}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: const pw.TextStyle(fontSize: 11))),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  String _getRandomNoSurat() {
    return (100 + DateTime.now().millisecond % 899).toString();
  }

  String _getNamaBulan(int bulan) {
    List<String> listBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return listBulan[bulan];
  }
}

// ==========================================
// LIST DATA WARGA
// ==========================================
class HalamanDataWarga extends StatefulWidget {
  final List<Warga> listWarga;
  final Function(Warga) onTambahWarga;

  const HalamanDataWarga({
    super.key,
    required this.listWarga,
    required this.onTambahWarga,
  });

  @override
  State<HalamanDataWarga> createState() => _HalamanDataWargaState();
}

class _HalamanDataWargaState extends State<HalamanDataWarga> {
  @override
  Widget build(BuildContext context) {
    Map<String, List<Warga>> keluargaMap = {};
    for (var w in widget.listWarga) {
      keluargaMap.putIfAbsent(w.nomorKK, () => []).add(w);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Warga RT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF005691),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormTambahWarga(
                onSimpan: (wargaBaru) {
                  widget.onTambahWarga(wargaBaru);
                  setState(() {});
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 32, color: Colors.white),
        label: const Text('Tambah Warga', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: widget.listWarga.isEmpty
          ? const Center(
              child: Text('Belum ada data warga.\nKlik tombol "Tambah Warga" di bawah.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: keluargaMap.keys.length,
              itemBuilder: (context, index) {
                String noKK = keluargaMap.keys.elementAt(index);
                List<Warga> anggotaKeluarga = keluargaMap[noKK]!;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No KK: $noKK', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF005691))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                              child: Text('${anggotaKeluarga.length} Anggota', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 2),
                        ...anggotaKeluarga.map((warga) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: warga.isKurangMampu ? Colors.orange.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(warga.jenisKelamin == 'Laki-laki' ? Icons.face : Icons.face_3, size: 34, color: const Color(0xFF005691)),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(warga.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('NIK: ${warga.nik}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                Text('TTL: ${warga.tempatLahir}, ${warga.tanggalLahir.day}-${warga.tanggalLahir.month}-${warga.tanggalLahir.year} (${warga.usia} Thn)', style: const TextStyle(fontSize: 16)),
                                Text('Pekerjaan: ${warga.pekerjaan}', style: const TextStyle(fontSize: 16)),
                                Text('Status: ${warga.statusPernikahan} | Agama: ${warga.agama}', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// REKAPITULASI DATA STATISTIK RT
// ==========================================
class HalamanRekapData extends StatelessWidget {
  final List<Warga> listWarga;
  final String noRT;
  final String noRW;
  final String namaDesa;

  const HalamanRekapData({
    super.key,
    required this.listWarga,
    required this.noRT,
    required this.noRW,
    required this.namaDesa,
  });

  void _showDaftarWargaDialog(BuildContext context, String judul, List<Warga> filteredList, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 50, height: 5, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                  ),
                  Text('$judul (${filteredList.length})', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor)),
                  const Divider(thickness: 1.5),
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(child: Text('Tidak ada data warga di kategori ini.', style: TextStyle(fontSize: 18)))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredList.length,
                            itemBuilder: (context, idx) {
                              var w = filteredList[idx];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(w.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Text('NIK: ${w.nik} | Usia: ${w.usia} Thn', style: const TextStyle(fontSize: 16)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Warga> lansiaList = listWarga.where((w) => w.kategoriUsia == 'Lansia').toList();
    List<Warga> anakList = listWarga.where((w) => w.kategoriUsia == 'Anak-anak').toList();
    List<Warga> bayiList = listWarga.where((w) => w.kategoriUsia == 'Bayi').toList();
    List<Warga> ibuHamilList = listWarga.where((w) => w.isIbuHamil).toList();
    List<Warga> wargaMiskinList = listWarga.where((w) => w.isKurangMampu).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekapitulasi Data RT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF005691),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(context, 'Total Warga', '${listWarga.length} Orang', Colors.blue.shade900, () => _showDaftarWargaDialog(context, 'Total Warga', listWarga, Colors.blue.shade900)),
                _buildStatCard(context, 'Lansia', '${lansiaList.length} Orang', Colors.purple.shade800, () => _showDaftarWargaDialog(context, 'Lansia', lansiaList, Colors.purple.shade800)),
                _buildStatCard(context, 'Anak-anak', '${anakList.length} Orang', Colors.teal.shade800, () => _showDaftarWargaDialog(context, 'Anak-anak', anakList, Colors.teal.shade800)),
                _buildStatCard(context, 'Bayi / Balita', '${bayiList.length} Orang', Colors.cyan.shade900, () => _showDaftarWargaDialog(context, 'Bayi / Balita', bayiList, Colors.cyan.shade900)),
                _buildStatCard(context, 'Ibu Hamil', '${ibuHamilList.length} Orang', Colors.pink.shade800, () => _showDaftarWargaDialog(context, 'Ibu Hamil', ibuHamilList, Colors.pink.shade800)),
                _buildStatCard(context, 'Kurang Mampu', '${wargaMiskinList.length} Orang', Colors.deepOrange.shade800, () => _showDaftarWargaDialog(context, 'Kurang Mampu', wargaMiskinList, Colors.deepOrange.shade800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FORM TAMBAH WARGA BARU
// ==========================================
class FormTambahWarga extends StatefulWidget {
  final Function(Warga) onSimpan;

  const FormTambahWarga({super.key, required this.onSimpan});

  @override
  State<FormTambahWarga> createState() => _FormTambahWargaState();
}

class _FormTambahWargaState extends State<FormTambahWarga> {
  final _formKey = GlobalKey<FormState>();

  final _noKKController = TextEditingController();
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();

  String _pekerjaan = 'Karyawan Swasta';
  final List<String> _opsiPekerjaan = [
    'Belum/Tidak Bekerja',
    'Mengurus Rumah Tangga',
    'Pelajar/Mahasiswa',
    'PNS / ASN',
    'TNI / Polri',
    'Karyawan Swasta',
    'Karyawan BUMN',
    'Wiraswasta / Usaha Sendiri',
    'Petani / Peternak',
    'Nelayan',
    'Buruh Harian Lepas',
    'Pensiunan',
    'Lainnya',
  ];

  DateTime _selectedDate = DateTime(2000, 1, 1);
  String _jenisKelamin = 'Laki-laki';
  String _agama = 'Islam';
  String _statusPernikahan = 'Belum Menikah';
  bool _isIbuHamil = false;
  bool _isKurangMampu = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Warga Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF005691),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nomor Kartu Keluarga (KK):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _noKKController,
                style: const TextStyle(fontSize: 18),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '16 angka KK'),
                validator: (val) => val!.isEmpty ? 'Nomor KK tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              const Text('Nama Lengkap Warga:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Sesuai KTP / KK'),
                validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tempat Lahir:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _tempatLahirController,
                          style: const TextStyle(fontSize: 18),
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Kota/Kab'),
                          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Lahir:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 18)),
                                const Icon(Icons.calendar_today, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Pekerjaan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _opsiPekerjaan.contains(_pekerjaan) ? _pekerjaan : _opsiPekerjaan.first,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
                items: _opsiPekerjaan
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _pekerjaan = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              const Text('Agama:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _agama,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Khonghucu']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) => setState(() => _agama = val!),
              ),
              const SizedBox(height: 16),

              const Text('Jenis Kelamin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _jenisKelamin,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Laki-laki', 'Perempuan']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _jenisKelamin = val!;
                    if (_jenisKelamin == 'Laki-laki') _isIbuHamil = false;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Status Pernikahan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _statusPernikahan,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['Belum Menikah', 'Sudah Menikah', 'Meninggal']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) => setState(() => _statusPernikahan = val!),
              ),
              const SizedBox(height: 16),

              if (_jenisKelamin == 'Perempuan')
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Status Ibu Hamil?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  value: _isIbuHamil,
                  onChanged: (val) => setState(() => _isIbuHamil = val!),
                ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kategori Kurang Mampu?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                value: _isKurangMampu,
                onChanged: (val) => setState(() => _isKurangMampu = val!),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Warga wargaBaru = Warga(
                        nomorKK: _noKKController.text,
                        nama: _namaController.text,
                        tempatLahir: _tempatLahirController.text,
                        tanggalLahir: _selectedDate,
                        jenisKelamin: _jenisKelamin,
                        pekerjaan: _pekerjaan,
                        agama: _agama,
                        statusPernikahan: _statusPernikahan,
                        isIbuHamil: _isIbuHamil,
                        isKurangMampu: _isKurangMampu,
                      );

                      widget.onSimpan(wargaBaru);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SIMPAN WARGA', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}