import 'package:flutter/material.dart';

void main() {
  runApp(const LabInventoryApp());
}

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
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// DATA SEMENTARA
// Nanti bagian ini diganti dengan data dari REST API + MySQL.
// ============================================================

class InventoryItem {
  final String name;
  final String code;
  final String category;
  final String condition;
  final int stock;
  final String location;

  const InventoryItem({
    required this.name,
    required this.code,
    required this.category,
    required this.condition,
    required this.stock,
    required this.location,
  });
}

const inventoryData = [
  InventoryItem(
    name: 'Proyektor Epson',
    code: 'INV-ELK-0012',
    category: 'Elektronik',
    condition: 'Sangat Baik',
    stock: 2,
    location: 'Lemari A - Rak 2',
  ),
  InventoryItem(
    name: 'Laptop Lenovo',
    code: 'INV-CMP-0008',
    category: 'Komputer',
    condition: 'Baik',
    stock: 4,
    location: 'Lemari B - Rak 1',
  ),
  InventoryItem(
    name: 'Kabel HDMI',
    code: 'INV-AKS-0021',
    category: 'Aksesoris',
    condition: 'Baik',
    stock: 6,
    location: 'Lemari C - Rak 3',
  ),
  InventoryItem(
    name: 'Speaker Aktif 15"',
    code: 'INV-ELK-0017',
    category: 'Elektronik',
    condition: 'Baik',
    stock: 3,
    location: 'Lemari A - Rak 4',
  ),
];

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
  String selectedRole = 'Mahasiswa';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void masuk() {
    if (selectedRole == 'Mahasiswa') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardMahasiswa(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardAdmin(),
        ),
      );
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

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: masuk,
                  child: const Text(
                    'MASUK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
// DASHBOARD MAHASISWA
// ============================================================

class DashboardMahasiswa extends StatelessWidget {
  const DashboardMahasiswa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabDrawer(isAdmin: false),
      appBar: AppBar(
        title: const Text(
          'Halo, Naila Fathia! 👋',
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
            // Status peminjaman
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BorrowingHistoryScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Peminjaman'),
                          SizedBox(height: 5),
                          Text(
                            '1 Peminjaman Aktif',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Kategori:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CategoryCard(
                    icon: Icons.desktop_windows_outlined,
                    title: 'Komputer',
                    onTap: () => _openInventory(context, 'Komputer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CategoryCard(
                    icon: Icons.video_camera_back_outlined,
                    title: 'Proyektor',
                    onTap: () => _openInventory(context, 'Elektronik'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CategoryCard(
                    icon: Icons.cable_outlined,
                    title: 'Kabel',
                    onTap: () => _openInventory(context, 'Aksesoris'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Inventaris Sering Dipinjam:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...inventoryData.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InventoryCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailItemScreen(item: item),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static void _openInventory(
    BuildContext context,
    String category,
  ) {
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
}

// ============================================================
// DASHBOARD ADMIN / LABORAN
// ============================================================

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabDrawer(isAdmin: true),
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

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'Semua';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> get filteredItems {
    final query = searchController.text.toLowerCase();

    return inventoryData.where((item) {
      final matchSearch = item.name.toLowerCase().contains(query);
      final matchCategory = selectedCategory == 'Semua' ||
          item.category == selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LabDrawer(isAdmin: widget.isAdmin),
      appBar: AppBar(
        title: const Text(
          'Daftar Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
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
      body: Column(
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
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('Barang tidak ditemukan.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) =>
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

  final purposeController = TextEditingController();

  @override
  void dispose() {
    purposeController.dispose();
    super.dispose();
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pengajuan berhasil dibuat (data sementara).',
                      ),
                    ),
                  );
                },
                child: const Text(
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

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabDrawer(isAdmin: true),
      appBar: AppBar(
        title: const Text(
          'Pengajuan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PendingCard(
            name: 'Naila Fathia',
            item: 'Laptop Lenovo',
            amount: '1 Unit',
          ),
          SizedBox(height: 10),
          PendingCard(
            name: 'Budi Santoso',
            item: 'Proyektor Epson',
            amount: '1 Unit',
          ),
          SizedBox(height: 10),
          PendingCard(
            name: 'Siti Aisyah',
            item: 'Kabel HDMI',
            amount: '2 Unit',
          ),
        ],
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

  @override
  void dispose() {
    nameController.dispose();
    stockController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data barang disimpan sementara.',
                      ),
                    ),
                  );
                },
                child: const Text(
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

class BorrowingHistoryScreen extends StatelessWidget {
  const BorrowingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabDrawer(isAdmin: false),
      appBar: AppBar(
        title: const Text(
          'Peminjaman Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HistoryCard(
            item: 'Proyektor Epson EB-X400',
            date: '20/05/2025 - 27/05/2025',
            status: 'Approved',
          ),
          SizedBox(height: 10),
          HistoryCard(
            item: 'Laptop Lenovo Ideapad 3',
            date: '10/05/2025 - 12/05/2025',
            status: 'Returned',
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LabDrawer(isAdmin: true),
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HistoryCard(
            item: 'Proyektor Epson',
            date: '20/05/2025 - 27/05/2025',
            status: 'Returned',
          ),
          SizedBox(height: 10),
          HistoryCard(
            item: 'Kabel HDMI',
            date: '12/05/2025',
            status: 'Rejected',
          ),
        ],
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

  const PendingCard({
    super.key,
    required this.name,
    required this.item,
    required this.amount,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengajuan disetujui (sementara).'),
                    ),
                  );
                },
                child: const Text('Setujui'),
              ),
              OutlinedButton(
                onPressed: () {
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
