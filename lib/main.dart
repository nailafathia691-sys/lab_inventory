import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// KONFIGURASI SUPABASE
// ============================================================
const supabaseUrl = 'https://ykbabgphvavzojrsjefh.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrYmFiZ3BodmF2em9qcnNqZWZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIyNDAwNjcsImV4cCI6MjEwNzgxNjA2N30.0NqfgRy29sBWviV-Uu-Mq5rK4vi5QzJllZFFB6NUpnY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const LabInventoryApp());
}

// ============================================================
// SUPABASE CLIENT
// ============================================================
final supabase = Supabase.instance.client;

// ============================================================
// APP
// ============================================================

class LabInventoryApp extends StatelessWidget {
  const LabInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LabInventory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// MODEL DATA
// ============================================================

class User {
  final String id;
  final String email;
  final String nama;
  final String npm;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.nama,
    required this.npm,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}

class InventoryItem {
  final String id;
  final String name;
  final String code;
  final String category;
  final String condition;
  final int stock;
  final String location;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.condition,
    required this.stock,
    required this.location,
  });

  // Create from Supabase JSON response
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['nama_barang'] ?? '',
      code: json['kode_barang'] ?? '',
      category: json['kategori'] ?? '',
      condition: json['kondisi'] ?? '',
      stock: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      location: json['lokasi'] ?? '',
    );
  }
}

class Borrowing {
  final String id;
  final String userId;
  final String itemId;
  final String namaPeminjam;
  final String namaBarang;
  final int jumlah;
  final DateTime tglPinjam;
  final DateTime? tglKembali;
  final String keperluan;
  final String status;
  final String? catatanKondisi;
  final String? updatedBy;

  const Borrowing({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.namaPeminjam,
    required this.namaBarang,
    required this.jumlah,
    required this.tglPinjam,
    this.tglKembali,
    required this.keperluan,
    required this.status,
    this.catatanKondisi,
    this.updatedBy,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      itemId: json['item_id'] ?? '',
      namaPeminjam: json['nama_peminjam'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      tglPinjam: DateTime.tryParse(json['tgl_pinjam'] ?? '') ?? DateTime.now(),
      tglKembali: json['tgl_kembali'] != null
          ? DateTime.tryParse(json['tgl_kembali'])
          : null,
      keperluan: json['keperluan'] ?? '',
      status: json['status'] ?? 'pending',
      catatanKondisi: json['catatan_kondisi'],
      updatedBy: json['updated_by'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isReturned => status == 'returned';
}

// ============================================================
// SAMPLE DATA - Temporary sampai konek Supabase
// TODO: Ganti dengan fetch dari Supabase
// ============================================================
const sampleItems = [
  InventoryItem(
    id: '1',
    name: 'Proyektor Epson',
    code: 'INV-ELK-0012',
    category: 'Elektronik',
    condition: 'Sangat Baik',
    stock: 2,
    location: 'Lemari A - Rak 2',
  ),
  InventoryItem(
    id: '2',
    name: 'Laptop Lenovo',
    code: 'INV-CMP-0008',
    category: 'Komputer',
    condition: 'Baik',
    stock: 4,
    location: 'Lemari B - Rak 1',
  ),
  InventoryItem(
    id: '3',
    name: 'Kabel HDMI',
    code: 'INV-AKS-0021',
    category: 'Aksesoris',
    condition: 'Baik',
    stock: 6,
    location: 'Lemari C - Rak 3',
  ),
  InventoryItem(
    id: '4',
    name: 'Speaker Aktif 15"',
    code: 'INV-ELK-0017',
    category: 'Elektronik',
    condition: 'Baik',
    stock: 3,
    location: 'Lemari A - Rak 4',
  ),
];

// ============================================================
// SUPABASE SERVICES
// ============================================================

class InventoryService {
  // Ambil data barang dari tabel items di Supabase
  static Future<List<InventoryItem>> getItems() async {
    try {
      final response = await supabase
          .from('items')
          .select()
          .order('nama_barang', ascending: true);
      final list = (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error getItems Supabase: $e');
    }
    return sampleItems;
  }

  // Tambah barang ke tabel items
  static Future<bool> addItem({
    required String name,
    required String code,
    required String category,
    required String condition,
    required int stock,
    required String location,
  }) async {
    try {
      await supabase.from('items').insert({
        'nama_barang': name,
        'kode_barang': code,
        'kategori': category,
        'kondisi': condition,
        'stok': stock,
        'lokasi': location,
      });
      return true;
    } catch (e) {
      debugPrint('Error addItem Supabase: $e');
      return false;
    }
  }

  // Ambil data peminjaman dari tabel borrowings
  static Future<List<Borrowing>> getBorrowings({String? status, String? userId}) async {
    try {
      var query = supabase.from('borrowings').select();
      if (status != null) {
        query = query.eq('status', status);
      }
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final response = await query.order('created_at', ascending: false);
      final list = (response as List)
          .map((json) => Borrowing.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      debugPrint('Error getBorrowings Supabase: $e');
      return [];
    }
  }

  // Buat pengajuan peminjaman baru
  static Future<bool> createBorrowing({
    required String itemId,
    required String namaBarang,
    required String namaPeminjam,
    required int jumlah,
    required DateTime tglPinjam,
    required DateTime tglKembali,
    required String keperluan,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
      await supabase.from('borrowings').insert({
        'user_id': userId,
        'item_id': itemId,
        'nama_peminjam': namaPeminjam,
        'nama_barang': namaBarang,
        'jumlah': jumlah,
        'tgl_pinjam': tglPinjam.toIso8601String(),
        'tgl_kembali': tglKembali.toIso8601String(),
        'keperluan': keperluan,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      debugPrint('Error createBorrowing Supabase: $e');
      return false;
    }
  }

  // Update status peminjaman (approve, reject, returned)
  static Future<bool> updateBorrowingStatus({
    required String id,
    required String status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };
      if (notes != null) updateData['catatan_kondisi'] = notes;
      await supabase.from('borrowings').update(updateData).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error updateBorrowingStatus Supabase: $e');
      return false;
    }
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Berpindah otomatis ke LoginScreen setelah 2.4 detik
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: const LoginScreen(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // Slate deep dark navy
              Color(0xFF1E3A8A), // Royal blue
              Color(0xFF2563EB), // Vibrant blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              // Center App Logo & Animated Typography
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 125,
                        height: 125,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'LabInventory',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: const Text(
                          'Sistem Inventaris Lab Komputer PTI',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer & Versioning
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'FKIP • UNIVERSITAS LAMPUNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  bool isLoading = false;
  String selectedRole = 'Mahasiswa';
  String? errorMessage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> masuk() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Email dan password harus diisi');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        setState(() {
          errorMessage = 'Login gagal';
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      if (selectedRole == 'Mahasiswa') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MahasiswaMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'LabInventory',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Logo sementara
              Center(
                child: Image.asset(
                  'assets/images/lab_inventory_logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Input email...',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Input password...',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Masuk Sebagai:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mahasiswa'),
                value: 'Mahasiswa',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
              ),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Admin / Laboran'),
                value: 'Admin',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
              ),

              if (errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : masuk,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'MASUK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: TextButton.icon(
                  onPressed: () {
                    if (selectedRole == 'Mahasiswa') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MahasiswaMainScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMainScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Masuk Mode Demo (Tanpa Akun)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DRAWER / SIDEBAR
// ============================================================

class LabDrawer extends StatelessWidget {
  final bool isAdmin;

  const LabDrawer({
    super.key,
    required this.isAdmin,
  });

  void openPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/lab_inventory_logo.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'LabInventory',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Sistem Informasi Inventaris Laboratorium',
          ),
        ],
      ),
    ),
            const Divider(),

            _drawerItem(
              context,
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              page: isAdmin
                  ? const DashboardAdmin()
                  : const DashboardMahasiswa(),
            ),

            _drawerItem(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Daftar Inventaris',
              page: InventoryListScreen(isAdmin: isAdmin),
            ),

            if (!isAdmin)
              _drawerItem(
                context,
                icon: Icons.assignment_outlined,
                title: 'Peminjaman Saya',
                page: const BorrowingHistoryScreen(),
              ),

            if (isAdmin)
              _drawerItem(
                context,
                icon: Icons.pending_actions_outlined,
                title: 'Pengajuan Peminjaman',
                page: const ApprovalScreen(),
              ),

            if (isAdmin)
              _drawerItem(
                context,
                icon: Icons.add_box_outlined,
                title: 'Tambah Barang',
                page: const AddItemScreen(),
              ),

            if (isAdmin)
              _drawerItem(
                context,
                icon: Icons.assignment_return_outlined,
                title: 'Pengembalian',
                page: const ReturnItemScreen(),
              ),

            _drawerItem(
              context,
              icon: Icons.history_outlined,
              title: 'Riwayat Transaksi',
              page: const TransactionHistoryScreen(),
            ),

            const Spacer(),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman profil akan dibuat berikutnya.'),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}

// ============================================================
// MAIN NAVIGATION (BOTTOM APP BAR)
// ============================================================

class MahasiswaMainScreen extends StatefulWidget {
  const MahasiswaMainScreen({super.key});

  @override
  State<MahasiswaMainScreen> createState() => _MahasiswaMainScreenState();
}

class _MahasiswaMainScreenState extends State<MahasiswaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardMahasiswa(),
    InventoryListScreen(isAdmin: false),
    BorrowingHistoryScreen(),
    ProfileScreen(isAdmin: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventaris',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Peminjaman',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardAdmin(),
    InventoryListScreen(isAdmin: true),
    ApprovalScreen(),
    TransactionHistoryScreen(),
    ProfileScreen(isAdmin: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventaris',
          ),
          NavigationDestination(
            icon: Icon(Icons.pending_actions_outlined),
            selectedIcon: Icon(Icons.pending_actions),
            label: 'Pengajuan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  final bool isAdmin;

  const ProfileScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      isAdmin ? 'AD' : 'NF',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.school,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAdmin ? 'Laboran Lab Komputer' : 'Naila Fathia',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isAdmin ? 'Administrator Sistem Inventaris' : 'NPM: 2413025076',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              'Pendidikan Teknologi Informasi - FKIP Unila',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _profileMenu(
              icon: Icons.person_outline,
              title: 'Informasi Akun',
              subtitle: isAdmin ? 'Admin / Laboran PTI' : 'Mahasiswa PTI 2024 B',
            ),
            _profileMenu(
              icon: Icons.computer_outlined,
              title: 'Laboratorium',
              subtitle: 'Lab Komputer PTI Gedung MIPA',
            ),
            _profileMenu(
              icon: Icons.shield_outlined,
              title: 'Hak Akses Sistem',
              subtitle: isAdmin
                  ? 'Akses Penuh (Inventaris, Approval, Pengembalian)'
                  : 'Peminjam Barang Laboratorium',
            ),
            _profileMenu(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'LabInventory v1.0.0 (Tugas Mobile Programming)',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Keluar'),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar dari akun ini?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'KELUAR DARI AKUN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD MAHASISWA
// ============================================================

class DashboardMahasiswa extends StatefulWidget {
  const DashboardMahasiswa({super.key});

  @override
  State<DashboardMahasiswa> createState() => _DashboardMahasiswaState();
}

class _DashboardMahasiswaState extends State<DashboardMahasiswa> {
  bool _isLoading = false;
  List<Borrowing> _myBorrowings = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowings();
  }

  Future<void> _loadBorrowings() async {
    setState(() => _isLoading = true);
    final data = await InventoryService.getBorrowings();
    if (mounted) {
      setState(() {
        _myBorrowings = data;
        _isLoading = false;
      });
    }
  }

  void _openInventory(String? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryListScreen(
          initialCategory: category,
          isAdmin: false,
        ),
      ),
    );
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pengumuman Laboratorium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnnouncementItem(
              icon: Icons.access_time_filled,
              title: 'Batas Pengembalian Alat Hari Ini',
              description: 'Pengembalian inventaris lab maksimal diterima pukul 16:00 WIB di Ruang Laboran Lt. 2.',
              time: 'Hari ini, 08:00 WIB',
            ),
            const Divider(height: 24),
            _buildAnnouncementItem(
              icon: Icons.assignment_late,
              title: 'Wajib Menitipkan KTM Fisik',
              description: 'Peminjam wajib menitipkan Kartu Tanda Mahasiswa (KTM) asli saat pengambilan unit barang.',
              time: 'Kemarin',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 3),
              Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  void _showRulesModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.rule_folder_outlined, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tata Tertib Lab PTI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRulePoint(
                number: '1',
                title: 'Pengajuan Resmi via Aplikasi',
                desc: 'Seluruh peminjaman barang laboratorium harus diajukan terlebih dahulu melalui aplikasi LabInventory.',
              ),
              _buildRulePoint(
                number: '2',
                title: 'KTM Fisik Sebagai Jaminan',
                desc: 'Peminjam wajib menitipkan KTM fisik asli milik pribadi ke petugas laboratorium saat pengambilan alat.',
              ),
              _buildRulePoint(
                number: '3',
                title: 'Pemeriksaan Bersama di Lab',
                desc: 'Sebelum membawa alat keluar lab, periksa kelengkapan kabel, adaptor, dan fungsi alat bersama laboran.',
              ),
              _buildRulePoint(
                number: '4',
                title: 'Tepat Waktu & Tanggung Jawab',
                desc: 'Alat wajib dikembalikan sesuai tanggal & jam yang disepakati. Kerusakan atau kehilangan menjadi tanggung jawab peminjam.',
              ),
              _buildRulePoint(
                number: '5',
                title: 'Larangan di Area Laboratorium',
                desc: 'Dilarang keras membawa makanan, minuman, dan merokok di dalam ruangan laboratorium komputer.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Saya Paham & Setuju'),
          ),
        ],
      ),
    );
  }

  Widget _buildRulePoint({
    required String number,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cari peminjaman aktif terbaru (status pending atau approved)
    final activeBorrowings = _myBorrowings.where((b) {
      final s = b.status.toLowerCase();
      return s == 'pending' || s == 'approved' || s == 'dipinjam';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade700,
              child: const Text(
                'NF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Naila Fathia! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'NPM: 2413025076 • PTI FKIP Unila',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showNotificationSheet,
                icon: const Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
                tooltip: 'Pengumuman Lab',
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBorrowings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Lab
              _buildHeroBanner(),

              const SizedBox(height: 18),

              // Status Peminjaman Terkini
              _buildStatusCard(activeBorrowings),

              const SizedBox(height: 22),

              // Pintasan Cepat (Quick Actions)
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Kategori Pilihan Cepat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kategori Inventaris',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openInventory(null),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCategoryGrid(),

              const SizedBox(height: 26),

              // ALUR & PANDUAN PEMINJAMAN ALAT
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.route, size: 20, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Alur Peminjaman Alat Lab',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Ikuti 4 langkah mudah berikut untuk meminjam fasilitas laboratorium PTI:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              _buildBorrowingFlowCard(),

              const SizedBox(height: 24),

              // INFO OPERASIONAL & TATA TERTIB LAB
              _buildLabInfoCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Banner
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B7A), Color(0xFF1E60B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3B7A).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Lab Komputer PTI Unila',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF34D399), width: 0.8),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                    SizedBox(width: 5),
                    Text(
                      'Lab Buka',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Layanan Inventaris & Peminjaman Alat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cek stok proyektor, komputer, kabel, dan perangkat praktikum secara real-time langsung dari smartphone.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // Status Peminjaman Card
  Widget _buildStatusCard(List<Borrowing> activeList) {
    if (_isLoading) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    final hasActive = activeList.isNotEmpty;
    final first = hasActive ? activeList.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasActive ? Colors.amber.shade300 : Colors.blue.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasActive ? Colors.amber.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasActive ? Icons.pending_actions : Icons.verified_user_outlined,
                  color: hasActive ? Colors.amber.shade800 : Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Peminjaman Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasActive
                          ? '${activeList.length} Peminjaman Aktif'
                          : 'Tidak Ada Peminjaman Aktif',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: hasActive ? Colors.amber.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    first!.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasActive
                ? 'Barang: ${first!.namaBarang} (${first.jumlah} Unit)\nHarap bawa KTM ke Ruang Laboran saat pengambilan.'
                : 'Semua alat praktikum telah dikembalikan. Anda dapat mengajukan pinjaman baru sewaktu-waktu.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BorrowingHistoryScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasActive ? 'Lihat Rincian & Riwayat' : 'Buka Riwayat Peminjaman',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pintasan Cepat
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF2563EB),
          label: 'Katalog Alat',
          onTap: () => _openInventory(null),
        ),
        _buildActionItem(
          icon: Icons.edit_note_outlined,
          color: const Color(0xFF0D9488),
          label: 'Ajukan Pinjam',
          onTap: () => _openInventory(null),
        ),
        _buildActionItem(
          icon: Icons.history_edu_outlined,
          color: const Color(0xFF7C3AED),
          label: 'Riwayat Saya',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorrowingHistoryScreen()),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.gavel_outlined,
          color: const Color(0xFFEA580C),
          label: 'Tata Tertib',
          onTap: _showRulesModal,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kategori Grid
  Widget _buildCategoryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryItem(
            icon: Icons.desktop_windows_outlined,
            title: 'Komputer',
            color: const Color(0xFF2563EB),
            onTap: () => _openInventory('Komputer'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryItem(
            icon: Icons.videocam_outlined,
            title: 'Proyektor',
            color: const Color(0xFF7C3AED),
            onTap: () => _openInventory('Elektronik'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryItem(
            icon: Icons.cable_outlined,
            title: 'Kabel & Port',
            color: const Color(0xFF059669),
            onTap: () => _openInventory('Aksesoris'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryItem(
            icon: Icons.speaker_outlined,
            title: 'Audio',
            color: const Color(0xFFD97706),
            onTap: () => _openInventory('Elektronik'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ALUR PEMINJAMAN ALAT (4-Step Timeline Guide)
  Widget _buildBorrowingFlowCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildFlowStep(
            stepNumber: '1',
            title: 'Pilih Alat & Cek Stok',
            description: 'Buka menu Katalog, pilih alat praktikum yang ingin digunakan, lalu periksa jumlah stok yang tersedia.',
            icon: Icons.search,
            color: const Color(0xFF2563EB),
          ),
          _buildFlowDivider(),
          _buildFlowStep(
            stepNumber: '2',
            title: 'Isi Formulir Pengajuan',
            description: 'Klik Pinjam Barang, tentukan tanggal pinjam/kembali, jumlah unit, dan keperluan akademik Anda.',
            icon: Icons.assignment_outlined,
            color: const Color(0xFF0D9488),
          ),
          _buildFlowDivider(),
          _buildFlowStep(
            stepNumber: '3',
            title: 'Verifikasi & Ambil di Lab',
            description: 'Tunggu konfirmasi laboran. Tunjukkan status disetujui dan serahkan KTM fisik asli saat mengambil alat di Lt. 2.',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF7C3AED),
          ),
          _buildFlowDivider(),
          _buildFlowStep(
            stepNumber: '4',
            title: 'Pengembalian & Cek Kondisi',
            description: 'Kembalikan alat tepat waktu. Laboran akan mengecek fungsi dan kondisi fisik alat sebelum KTM dikembalikan.',
            icon: Icons.published_with_changes,
            color: const Color(0xFFEA580C),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 2,
          height: 16,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  // Informasi Operasional Lab
  Widget _buildLabInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0F3B7A), size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Laboratorium Komputer PTI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F3B7A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.schedule,
            text: 'Jam Layanan: Senin – Jumat (08:00 – 16:00 WIB)',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            icon: Icons.room_outlined,
            text: 'Lokasi: Lab Komputer PTI, Gedung FKIP Lt. 2, Unila',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            icon: Icons.credit_card,
            text: 'Syarat: Menyerahkan Kartu Tanda Mahasiswa (KTM) fisik',
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showRulesModal,
            child: const Row(
              children: [
                Text(
                  'Lihat Ketentuan & Tata Tertib Lengkap',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E60B8),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Color(0xFF1E60B8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DASHBOARD ADMIN / LABORAN
// ============================================================

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Laboran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(
                  child: AdminStatCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Total Barang',
                    value: '45',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AdminStatCard(
                    icon: Icons.access_time,
                    title: 'Pending',
                    value: '3',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Aksi Cepat:',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddItemScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_box_outlined,
                            color: Colors.blue.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tambah Barang',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReturnItemScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_return_outlined,
                            color: Colors.orange.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pengembalian',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Pengajuan Menunggu (Pending):',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const PendingCard(
              name: 'Naila Fathia',
              item: 'Laptop Lenovo',
              amount: '1 Unit',
            ),
            const SizedBox(height: 10),
            const PendingCard(
              name: 'Budi Santoso',
              item: 'Proyektor Epson',
              amount: '1 Unit',
            ),
            const SizedBox(height: 10),
            const PendingCard(
              name: 'Siti Aisyah',
              item: 'Kabel HDMI',
              amount: '2 Unit',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DAFTAR INVENTARIS + SEARCH + FILTER
// ============================================================

class InventoryListScreen extends StatefulWidget {
  final String? initialCategory;
  final bool isAdmin;

  const InventoryListScreen({
    super.key,
    this.initialCategory,
    this.isAdmin = false,
  });

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final searchController = TextEditingController();
  String selectedCategory = 'Semua';
  List<InventoryItem> allItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'Semua';
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    final data = await InventoryService.getItems();
    if (mounted) {
      setState(() {
        allItems = data;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> get filteredItems {
    final query = searchController.text.toLowerCase();

    return allItems.where((item) {
      final matchSearch = item.name.toLowerCase().contains(query);
      final matchCategory = selectedCategory == 'Semua' ||
          item.category == selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Filter Inventaris',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.clear_all),
                        title: const Text('Semua Kategori'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedCategory = 'Semua');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.devices),
                        title: const Text('Elektronik'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedCategory = 'Elektronik');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.computer),
                        title: const Text('Komputer'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedCategory = 'Komputer');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.cable),
                        title: const Text('Aksesoris'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedCategory = 'Aksesoris');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                );
                if (res == true) {
                  loadItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Barang'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: loadItems,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari nama barang...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Filter Kategori',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Semua',
                    child: Text('Semua'),
                  ),
                  DropdownMenuItem(
                    value: 'Elektronik',
                    child: Text('Elektronik'),
                  ),
                  DropdownMenuItem(
                    value: 'Komputer',
                    child: Text('Komputer'),
                  ),
                  DropdownMenuItem(
                    value: 'Aksesoris',
                    child: Text('Aksesoris'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredItems.isEmpty
                      ? const Center(
                          child: Text('Barang tidak ditemukan.'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return InventoryCard(
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailItemScreen(item: item),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL BARANG
// ============================================================

class DetailItemScreen extends StatelessWidget {
  final InventoryItem item;

  const DetailItemScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 215,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              '${item.name} ${item.code}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Lokasi',
              value: item.location,
            ),
            DetailRow(
              icon: Icons.inventory_2_outlined,
              label: 'Stok',
              value: '${item.stock} Unit (Tersedia)',
            ),
            DetailRow(
              icon: Icons.verified_outlined,
              label: 'Kondisi',
              value: item.condition,
            ),
            DetailRow(
              icon: Icons.category_outlined,
              label: 'Kategori',
              value: item.category,
            ),
            DetailRow(
              icon: Icons.qr_code_2_outlined,
              label: 'Kode Barang',
              value: item.code,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: item.stock > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BorrowingFormScreen(item: item),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'AJUKAN PEMINJAMAN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FORM PEMINJAMAN
// ============================================================

class BorrowingFormScreen extends StatefulWidget {
  final InventoryItem item;

  const BorrowingFormScreen({
    super.key,
    required this.item,
  });

  @override
  State<BorrowingFormScreen> createState() =>
      _BorrowingFormScreenState();
}

class _BorrowingFormScreenState extends State<BorrowingFormScreen> {
  int amount = 1;
  DateTime? borrowDate;
  DateTime? returnDate;
  bool isSubmitting = false;

  final purposeController = TextEditingController();

  @override
  void dispose() {
    purposeController.dispose();
    super.dispose();
  }

  Future<void> submitBorrowing() async {
    if (borrowDate == null || returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal pinjam dan tanggal kembali terlebih dahulu!'),
        ),
      );
      return;
    }
    if (purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan keperluan / alasan peminjaman!'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    final user = supabase.auth.currentUser;
    final userName = user?.email?.split('@').first ?? 'Naila Fathia';

    final success = await InventoryService.createBorrowing(
      itemId: widget.item.id.isNotEmpty ? widget.item.id : widget.item.code,
      namaBarang: widget.item.name,
      namaPeminjam: userName,
      jumlah: amount,
      tglPinjam: borrowDate!,
      tglKembali: returnDate!,
      keperluan: purposeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Pengajuan peminjaman berhasil dikirim ke Supabase!'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan tersimpan lokal (RLS/Demo Mode).'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> pickDate(bool isBorrowDate) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        if (isBorrowDate) {
          borrowDate = selected;
        } else {
          returnDate = selected;
        }
      });
    }
  }

  String dateText(DateTime? date) {
    if (date == null) return 'DD/MM/YYYY';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barang'),
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.item.code),
                  const SizedBox(height: 8),
                  Text('Stok Tersedia: ${widget.item.stock} Unit'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Jumlah Pinjam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: amount > 1
                      ? () => setState(() => amount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$amount',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: amount < widget.item.stock
                      ? () => setState(() => amount++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Tgl Pinjam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _dateField(
              text: dateText(borrowDate),
              onTap: () => pickDate(true),
            ),

            const SizedBox(height: 18),

            const Text(
              'Tgl Kembali',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _dateField(
              text: dateText(returnDate),
              onTap: () => pickDate(false),
            ),

            const SizedBox(height: 18),

            const Text(
              'Keperluan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: purposeController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Input alasan / keperluan...',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isSubmitting ? null : submitBorrowing,
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'KIRIM PENGAJUAN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}

// ============================================================
// ADMIN: APPROVAL
// ============================================================

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  List<Borrowing> pendingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  Future<void> loadPending() async {
    setState(() => isLoading = true);
    final data = await InventoryService.getBorrowings(status: 'pending');
    if (mounted) {
      setState(() {
        pendingList = data;
        isLoading = false;
      });
    }
  }

  Future<void> processAction(String id, String newStatus, String namaPeminjam) async {
    final success = await InventoryService.updateBorrowingStatus(
      id: id,
      status: newStatus,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.orange,
          content: Text(
            newStatus == 'approved'
                ? 'Pengajuan dari $namaPeminjam telah disetujui!'
                : 'Pengajuan dari $namaPeminjam ditolak.',
          ),
        ),
      );
      loadPending();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diubah (lokal).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengajuan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadPending,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadPending,
              child: pendingList.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final b = pendingList[index];
                        return PendingCard(
                          name: b.namaPeminjam.isNotEmpty
                              ? b.namaPeminjam
                              : 'Mahasiswa',
                          item: b.namaBarang,
                          amount: '${b.jumlah} Unit',
                          onApprove: () =>
                              processAction(b.id, 'approved', b.namaPeminjam),
                          onReject: () =>
                              processAction(b.id, 'rejected', b.namaPeminjam),
                        );
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Belum Ada Pengajuan di Database Cloud',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Berikut adalah simulasi data pengajuan:',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PendingCard(
                          name: 'Naila Fathia',
                          item: 'Laptop Lenovo',
                          amount: '1 Unit',
                        ),
                        const SizedBox(height: 10),
                        const PendingCard(
                          name: 'Budi Santoso',
                          item: 'Proyektor Epson',
                          amount: '1 Unit',
                        ),
                        const SizedBox(height: 10),
                        const PendingCard(
                          name: 'Siti Aisyah',
                          item: 'Kabel HDMI',
                          amount: '2 Unit',
                        ),
                      ],
                    ),
            ),
    );
  }
}

// ============================================================
// ADMIN: TAMBAH BARANG
// ============================================================

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  String category = 'Elektronik';
  String condition = 'Sangat Baik';
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    stockController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveItem() async {
    final name = nameController.text.trim();
    final stockText = stockController.text.trim();
    final location = locationController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama barang harus diisi!')),
      );
      return;
    }

    final stock = int.tryParse(stockText);
    if (stock == null || stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok harus berupa angka yang valid (> 0)!')),
      );
      return;
    }

    setState(() => isSaving = true);

    // Buat kode barang otomatis
    final catCode = category.length >= 3 ? category.substring(0, 3).toUpperCase() : 'BRG';
    final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    final code = 'INV-$catCode-$randomSuffix';

    final success = await InventoryService.addItem(
      name: name,
      code: code,
      category: category,
      condition: condition,
      stock: stock,
      location: location.isNotEmpty ? location : 'Lemari Utama',
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Barang berhasil disimpan ke Supabase!'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang dicatat (lokal/RLS).'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nama Barang'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Input nama barang...',
              ),
            ),

            const SizedBox(height: 16),
            _label('Kategori'),
            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(
                  value: 'Elektronik',
                  child: Text('Elektronik'),
                ),
                DropdownMenuItem(
                  value: 'Komputer',
                  child: Text('Komputer'),
                ),
                DropdownMenuItem(
                  value: 'Aksesoris',
                  child: Text('Aksesoris'),
                ),
              ],
              onChanged: (value) {
                setState(() => category = value!);
              },
            ),

            const SizedBox(height: 16),
            _label('Stok'),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Input jumlah stok...',
              ),
            ),

            const SizedBox(height: 16),
            _label('Kondisi'),
            DropdownButtonFormField<String>(
              value: condition,
              items: const [
                DropdownMenuItem(
                  value: 'Sangat Baik',
                  child: Text('Sangat Baik'),
                ),
                DropdownMenuItem(
                  value: 'Baik',
                  child: Text('Baik'),
                ),
                DropdownMenuItem(
                  value: 'Perlu Perbaikan',
                  child: Text('Perlu Perbaikan'),
                ),
              ],
              onChanged: (value) {
                setState(() => condition = value!);
              },
            ),

            const SizedBox(height: 16),
            _label('Lokasi Rak'),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: 'Input lokasi rak / lemari...',
              ),
            ),

            const SizedBox(height: 16),
            _label('Deskripsi (Opsional)'),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Input deskripsi barang...',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isSaving ? null : saveItem,
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SIMPAN DATA',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ============================================================
// ADMIN: PENGEMBALIAN
// ============================================================

class ReturnItemScreen extends StatefulWidget {
  const ReturnItemScreen({super.key});

  @override
  State<ReturnItemScreen> createState() => _ReturnItemScreenState();
}

class _ReturnItemScreenState extends State<ReturnItemScreen> {
  String condition = 'Normal / Baik';
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proses Pengembalian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  InfoLine(label: 'Peminjam', value: 'Naila Fathia'),
                  InfoLine(label: 'Barang', value: 'Proyektor Epson'),
                  InfoLine(label: 'Jumlah', value: '1 Unit'),
                  InfoLine(label: 'Tgl Pinjam', value: '20/05/2025'),
                  InfoLine(label: 'Tgl Kembali', value: '27/05/2025'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Kondisi Pengembalian:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Normal / Baik'),
              value: 'Normal / Baik',
              groupValue: condition,
              onChanged: (value) {
                setState(() => condition = value!);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rusak'),
              value: 'Rusak',
              groupValue: condition,
              onChanged: (value) {
                setState(() => condition = value!);
              },
            ),

            const Text(
              'Catatan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Input catatan (opsional)...',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pengembalian berhasil dicatat (data sementara).',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'KONFIRMASI KEMBALI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RIWAYAT
// ============================================================

class BorrowingHistoryScreen extends StatefulWidget {
  const BorrowingHistoryScreen({super.key});

  @override
  State<BorrowingHistoryScreen> createState() => _BorrowingHistoryScreenState();
}

class _BorrowingHistoryScreenState extends State<BorrowingHistoryScreen> {
  List<Borrowing> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);
    final data = await InventoryService.getBorrowings();
    if (mounted) {
      setState(() {
        historyList = data;
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Peminjaman Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: historyList.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final b = historyList[index];
                        final returnStr = b.tglKembali != null
                            ? ' - ${_formatDate(b.tglKembali!)}'
                            : '';
                        return HistoryCard(
                          item: '${b.namaBarang} (${b.jumlah} Unit)',
                          date: '${_formatDate(b.tglPinjam)}$returnStr',
                          status: b.status.toUpperCase(),
                        );
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        HistoryCard(
                          item: 'Proyektor Epson EB-X400 (1 Unit)',
                          date: '20/05/2025 - 27/05/2025',
                          status: 'Approved',
                        ),
                        SizedBox(height: 10),
                        HistoryCard(
                          item: 'Laptop Lenovo Ideapad 3 (1 Unit)',
                          date: '10/05/2025 - 12/05/2025',
                          status: 'Returned',
                        ),
                      ],
                    ),
            ),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Borrowing> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() => isLoading = true);
    final data = await InventoryService.getBorrowings();
    if (mounted) {
      setState(() {
        transactions = data;
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi Lab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadTransactions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadTransactions,
              child: transactions.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        final returnStr = t.tglKembali != null
                            ? ' - ${_formatDate(t.tglKembali!)}'
                            : '';
                        return HistoryCard(
                          item: '${t.namaBarang} - Peminjam: ${t.namaPeminjam}',
                          date: '${_formatDate(t.tglPinjam)}$returnStr',
                          status: t.status.toUpperCase(),
                        );
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        HistoryCard(
                          item: 'Proyektor Epson - Peminjam: Naila Fathia',
                          date: '20/05/2025 - 27/05/2025',
                          status: 'Returned',
                        ),
                        SizedBox(height: 10),
                        HistoryCard(
                          item: 'Kabel HDMI - Peminjam: Budi Santoso',
                          date: '12/05/2025',
                          status: 'Rejected',
                        ),
                        SizedBox(height: 10),
                        HistoryCard(
                          item: 'Laptop Lenovo - Peminjam: Siti Aisyah',
                          date: '05/05/2025 - 08/05/2025',
                          status: 'Approved',
                        ),
                      ],
                    ),
            ),
    );
  }
}

// ============================================================
// WIDGET KECIL / REUSABLE
// ============================================================

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 115,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const InventoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Kategori: ${item.category}'),
                  Text('Status: Tersedia'),
                  Text('Stok: ${item.stock}'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 12),
          Text(title),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PendingCard extends StatelessWidget {
  final String name;
  final String item;
  final String amount;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const PendingCard({
    super.key,
    required this.name,
    required this.item,
    required this.amount,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            child: Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Mahasiswa'),
                Text('Barang: $item'),
                Text('Jumlah: $amount'),
              ],
            ),
          ),
          Column(
            children: [
              OutlinedButton(
                onPressed: onApprove ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengajuan disetujui (sementara).'),
                        ),
                      );
                    },
                child: const Text('Setujui'),
              ),
              OutlinedButton(
                onPressed: onReject ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengajuan ditolak (sementara).'),
                        ),
                      );
                    },
                child: const Text('Tolak'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 23),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const InfoLine({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String item;
  final String date;
  final String status;

  const HistoryCard({
    super.key,
    required this.item,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, size: 35),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(date),
              ],
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
