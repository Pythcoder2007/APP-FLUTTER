import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database.dart';

const Color accent = Color(0xFFFF5722);
const Color pageBg = Color(0xFF0F141E);
const Color cardBg = Color(0xFF1A212D);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  runApp(const SportsEmporiumApp());
}

class SportsEmporiumApp extends StatelessWidget {
  const SportsEmporiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shri Shakra Sports',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: cardBg,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0B0F17)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF121824),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF252D3D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

String money(num value, String symbol) {
  return '$symbol ${NumberFormat('#,##0.00').format(value)}';
}

String displayDate(Object? raw) {
  if (raw == null) return '-';
  final parsed = DateTime.tryParse(raw.toString());
  if (parsed == null) return raw.toString();
  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
}

double numberDouble(Object? value) => (value as num?)?.toDouble() ?? 0;
int numberInt(Object? value) => (value as num?)?.toInt() ?? 0;

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : null,
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _password = TextEditingController();
  bool _hidden = true;
  bool _working = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_working) return;
    setState(() => _working = true);
    final stored = await AppDatabase.instance.getSetting(
      'app_password',
      fallback: '12345678',
    );
    if (!mounted) return;
    setState(() => _working = false);
    if (_password.text == stored) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      showMessage(context, 'Incorrect password.', error: true);
      _password.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                color: cardBg,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: accent,
                        child: Icon(Icons.bolt, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Shri Shakra Sports',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Secure POS & inventory manager',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _password,
                        obscureText: _hidden,
                        autofocus: true,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hidden = !_hidden),
                            icon: Icon(
                              _hidden ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Default password: 12345678',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _working ? null : _login,
                        icon: _working
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Text('Unlock System'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _titles = const [
    'Dashboard',
    'Inventory',
    'Billing',
    'Customers',
    'Billing History',
    'Revenue & Profit',
    'Settings',
  ];

  final _icons = const [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.receipt_long_outlined,
    Icons.people_outline,
    Icons.history,
    Icons.bar_chart_outlined,
    Icons.settings_outlined,
  ];

  final _pages = const [
    DashboardScreen(),
    InventoryScreen(),
    BillingScreen(),
    CustomersScreen(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              FutureBuilder<String>(
                future: AppDatabase.instance.getSetting(
                  'shop_name',
                  fallback: 'Shri Shakra Sports',
                ),
                builder: (context, snapshot) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    color: const Color(0xFF121824),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: accent,
                          child: Icon(Icons.bolt, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.data ?? 'Shri Shakra Sports',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Mobile POS Manager',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _titles.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      selected: i == _index,
                      selectedColor: accent,
                      leading: Icon(_icons[i]),
                      title: Text(_titles[i]),
                      onTap: () {
                        setState(() => _index = i);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Lock app'),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle = '',
  });

  final String label;
  final String value;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white54)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardBundle {
  const _DashboardBundle({
    required this.symbol,
    required this.summary,
    required this.recent,
    required this.lowStock,
  });

  final String symbol;
  final Map<String, Object?> summary;
  final List<Map<String, Object?>> recent;
  final List<Map<String, Object?>> lowStock;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardBundle> _load() async {
    final results = await Future.wait([
      AppDatabase.instance.getSetting('currency_symbol', fallback: 'Rs.'),
      AppDatabase.instance.dashboardSummary(),
      AppDatabase.instance.getRecentSales(limit: 8),
      AppDatabase.instance.getLowStockProducts(limit: 8),
    ]);
    return _DashboardBundle(
      symbol: results[0] as String,
      summary: results[1] as Map<String, Object?>,
      recent: results[2] as List<Map<String, Object?>>,
      lowStock: results[3] as List<Map<String, Object?>>,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final s = data.summary;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle(
                'Business Overview',
                subtitle: 'A quick look at how the shop is performing.',
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.28,
                children: [
                  MetricCard(
                    label: "Today's Revenue",
                    value: money(numberDouble(s['today_total']), data.symbol),
                    subtitle: '${numberInt(s['today_count'])} transactions',
                    icon: Icons.today,
                  ),
                  MetricCard(
                    label: "This Month",
                    value: money(numberDouble(s['month_total']), data.symbol),
                    subtitle: '${numberInt(s['month_count'])} transactions',
                    icon: Icons.calendar_month,
                  ),
                  MetricCard(
                    label: "This Year",
                    value: money(numberDouble(s['year_total']), data.symbol),
                    subtitle: '${numberInt(s['year_count'])} transactions',
                    icon: Icons.trending_up,
                  ),
                  MetricCard(
                    label: 'Low Stock',
                    value: '${numberInt(s['low_stock_count'])}',
                    subtitle: 'Items need attention',
                    icon: Icons.warning_amber,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionTitle('Recent Sales'),
              if (data.recent.isEmpty)
                const Card(
                  child: ListTile(title: Text('No sales have been recorded yet.')),
                )
              else
                ...data.recent.map(
                  (sale) => Card(
                    color: cardBg,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x332196F3),
                        child: Icon(Icons.receipt_long),
                      ),
                      title: Text(sale['invoice_no'].toString()),
                      subtitle: Text(
                        '${sale['customer_name'] ?? 'Walk-in'} • ${displayDate(sale['sale_date'])}',
                      ),
                      trailing: Text(
                        money(numberDouble(sale['total']), data.symbol),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const SectionTitle('Low Stock Alerts'),
              if (data.lowStock.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Stock levels look healthy.'),
                  ),
                )
              else
                ...data.lowStock.map(
                  (product) => Card(
                    color: cardBg,
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(product['name'].toString()),
                      subtitle: Text(product['category']?.toString() ?? 'Uncategorized'),
                      trailing: Text(
                        '${numberInt(product['quantity'])} left',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _search = TextEditingController();
  late Future<List<Map<String, Object?>>> _future;
  String _symbol = 'Rs.';

  @override
  void initState() {
    super.initState();
    _future = AppDatabase.instance.getProducts();
    _search.addListener(_reload);
    AppDatabase.instance
        .getSetting('currency_symbol', fallback: 'Rs.')
        .then((value) {
      if (mounted) setState(() => _symbol = value);
    });
  }

  @override
  void dispose() {
    _search.removeListener(_reload);
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = AppDatabase.instance.getProducts(search: _search.text);
    });
  }

  Future<void> _edit([Map<String, Object?>? product]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      builder: (_) => ProductEditorSheet(product: product),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(Map<String, Object?> product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete “${product['name']}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AppDatabase.instance.deleteProduct(numberInt(product['id']));
      if (mounted) showMessage(context, 'Product deleted.');
      _reload();
    } catch (_) {
      if (mounted) {
        showMessage(
          context,
          'This product is linked to old bills and cannot be deleted.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search name, SKU, or category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, Object?>>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!;
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final qty = numberInt(product['quantity']);
                      final threshold = numberInt(product['low_stock_threshold']);
                      final low = qty <= threshold;
                      return Card(
                        color: cardBg,
                        child: ListTile(
                          onTap: () => _edit(product),
                          leading: CircleAvatar(
                            backgroundColor: low
                                ? const Color(0x44FF5722)
                                : const Color(0x332196F3),
                            child: Icon(
                              low ? Icons.warning_amber : Icons.inventory_2,
                              color: low ? Colors.orange : null,
                            ),
                          ),
                          title: Text(product['name'].toString()),
                          subtitle: Text(
                            '${product['sku'] ?? 'No SKU'} • ${product['category'] ?? 'Uncategorized'}\n'
                            'Sell: ${money(numberDouble(product['sell_price']), _symbol)} • Cost: ${money(numberDouble(product['cost_price']), _symbol)}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _edit(product);
                              if (value == 'delete') _delete(product);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$qty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: low ? Colors.orange : Colors.white,
                                  ),
                                ),
                                const Text(
                                  'in stock',
                                  style: TextStyle(fontSize: 11, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductEditorSheet extends StatefulWidget {
  const ProductEditorSheet({super.key, this.product});

  final Map<String, Object?>? product;

  @override
  State<ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<ProductEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sku;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _cost;
  late final TextEditingController _sell;
  late final TextEditingController _quantity;
  late final TextEditingController _threshold;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _sku = TextEditingController(text: p?['sku']?.toString() ?? '');
    _name = TextEditingController(text: p?['name']?.toString() ?? '');
    _category = TextEditingController(text: p?['category']?.toString() ?? '');
    _cost = TextEditingController(text: p?['cost_price']?.toString() ?? '0');
    _sell = TextEditingController(text: p?['sell_price']?.toString() ?? '0');
    _quantity = TextEditingController(text: p?['quantity']?.toString() ?? '0');
    _threshold = TextEditingController(
      text: p?['low_stock_threshold']?.toString() ?? '5',
    );
  }

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _category.dispose();
    _cost.dispose();
    _sell.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final args = (
        sku: _sku.text,
        name: _name.text,
        category: _category.text,
        cost: double.parse(_cost.text),
        sell: double.parse(_sell.text),
        quantity: int.parse(_quantity.text),
        threshold: int.parse(_threshold.text),
      );
      if (widget.product == null) {
        await AppDatabase.instance.addProduct(
          sku: args.sku,
          name: args.name,
          category: args.category,
          costPrice: args.cost,
          sellPrice: args.sell,
          quantity: args.quantity,
          lowStockThreshold: args.threshold,
        );
      } else {
        await AppDatabase.instance.updateProduct(
          id: numberInt(widget.product!['id']),
          sku: args.sku,
          name: args.name,
          category: args.category,
          costPrice: args.cost,
          sellPrice: args.sell,
          quantity: args.quantity,
          lowStockThreshold: args.threshold,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(
          context,
          'Could not save product. Check that the SKU is unique.',
          error: true,
        );
      }
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _decimal(String? value) {
    final n = double.tryParse(value ?? '');
    if (n == null || n < 0) return 'Enter a valid number';
    return null;
  }

  String? _whole(String? value) {
    final n = int.tryParse(value ?? '');
    if (n == null || n < 0) return 'Enter a whole number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.product == null ? 'Add Product' : 'Edit Product',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  validator: _required,
                  decoration: const InputDecoration(labelText: 'Product name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sku,
                        decoration: const InputDecoration(labelText: 'SKU'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _category,
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cost,
                        validator: _decimal,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Cost price'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sell,
                        validator: _decimal,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Sell price'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantity,
                        validator: _whole,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _threshold,
                        validator: _whole,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Low-stock level'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _search = TextEditingController();
  late Future<List<Map<String, Object?>>> _future;
  final List<CartItem> _cart = [];
  String _symbol = 'Rs.';

  @override
  void initState() {
    super.initState();
    _future = AppDatabase.instance.getProducts();
    _search.addListener(_reload);
    AppDatabase.instance
        .getSetting('currency_symbol', fallback: 'Rs.')
        .then((value) {
      if (mounted) setState(() => _symbol = value);
    });
  }

  @override
  void dispose() {
    _search.removeListener(_reload);
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = AppDatabase.instance.getProducts(search: _search.text);
    });
  }

  Future<void> _addProduct(Map<String, Object?> product) async {
    final stock = numberInt(product['quantity']);
    if (stock <= 0) {
      showMessage(context, 'This product is out of stock.', error: true);
      return;
    }
    final existing = _cart.where((e) => e.productId == numberInt(product['id']));
    final current = existing.isEmpty ? 0 : existing.first.quantity;
    final controller = TextEditingController(text: '1');
    final qty = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name'].toString()),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity',
            helperText: '${stock - current} available',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null || value <= 0 || value + current > stock) return;
              Navigator.pop(context, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (qty == null) return;
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.quantity += qty;
      } else {
        _cart.add(
          CartItem(
            productId: numberInt(product['id']),
            productName: product['name'].toString(),
            unitPrice: numberDouble(product['sell_price']),
            costPrice: numberDouble(product['cost_price']),
            quantity: qty,
            availableStock: stock,
          ),
        );
      }
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(cart: _cart, symbol: _symbol),
      ),
    );
    if (saved == true) {
      setState(() => _cart.clear());
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _cart.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SafeArea(
        child: Material(
          color: cardBg,
          child: InkWell(
            onTap: _cart.isEmpty ? null : _checkout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Badge(
                    label: Text('${_cart.length}'),
                    child: const Icon(Icons.shopping_cart_outlined, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cart.isEmpty ? 'Cart is empty' : 'Open current bill',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          money(total, _symbol),
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search products to add',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, Object?>>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final stock = numberInt(p['quantity']);
                    return Card(
                      color: cardBg,
                      child: ListTile(
                        title: Text(p['name'].toString()),
                        subtitle: Text(
                          '${p['category'] ?? 'Uncategorized'} • $stock in stock\n${money(numberDouble(p['sell_price']), _symbol)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton.filled(
                          onPressed: stock <= 0 ? null : () => _addProduct(p),
                          icon: const Icon(Icons.add_shopping_cart),
                        ),
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

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart, required this.symbol});

  final List<CartItem> cart;
  final String symbol;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _customer = TextEditingController();
  final _phone = TextEditingController();
  final _discount = TextEditingController(text: '0');
  final _taxPercent = TextEditingController(text: '5');
  String _payment = 'Cash';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.getSetting('tax_rate', fallback: '5').then((value) {
      if (mounted) setState(() => _taxPercent.text = value);
    });
    _discount.addListener(_refresh);
    _taxPercent.addListener(_refresh);
  }

  @override
  void dispose() {
    _discount.removeListener(_refresh);
    _taxPercent.removeListener(_refresh);
    _customer.dispose();
    _phone.dispose();
    _discount.dispose();
    _taxPercent.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  double get _subtotal =>
      widget.cart.fold<double>(0, (sum, item) => sum + item.lineTotal);
  double get _discountValue =>
      (double.tryParse(_discount.text) ?? 0).clamp(0, _subtotal).toDouble();
  double get _taxValue {
    final taxable = _subtotal - _discountValue;
    final percent = double.tryParse(_taxPercent.text) ?? 0;
    return taxable <= 0
        ? 0.0
        : (taxable * percent.clamp(0, 100) / 100).toDouble();
  }

  Future<void> _save() async {
    if (widget.cart.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await AppDatabase.instance.createSale(
        items: widget.cart,
        discount: _discountValue,
        tax: _taxValue,
        paymentMethod: _payment,
        customerName: _customer.text,
        customerPhone: _phone.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text('Bill Saved'),
          content: Text(
            '${result.invoiceNo}\nTotal: ${money(result.total, widget.symbol)}',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString().replaceFirst('Bad state: ', ''), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _subtotal - _discountValue + _taxValue;
    return Scaffold(
      appBar: AppBar(title: const Text('Current Bill')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Items'),
          ...widget.cart.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              color: cardBg,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${money(item.unitPrice, widget.symbol)} each\n${money(item.lineTotal, widget.symbol)}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: item.quantity <= 1
                          ? null
                          : () => setState(() => item.quantity--),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      onPressed: item.quantity >= item.availableStock
                          ? null
                          : () => setState(() => item.quantity++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    IconButton(
                      onPressed: () => setState(() => widget.cart.removeAt(index)),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          const SectionTitle('Customer & payment'),
          TextField(
            controller: _customer,
            decoration: const InputDecoration(labelText: 'Customer name (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _payment,
            items: const [
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'Card', child: Text('Card')),
              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _payment = value ?? 'Cash'),
            decoration: const InputDecoration(labelText: 'Payment method'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Discount (flat)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _taxPercent,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Tax %'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: cardBg,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _TotalRow('Subtotal', money(_subtotal, widget.symbol)),
                  _TotalRow('Discount', '- ${money(_discountValue, widget.symbol)}'),
                  _TotalRow('Tax', money(_taxValue, widget.symbol)),
                  const Divider(),
                  _TotalRow(
                    'TOTAL',
                    money(total, widget.symbol),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: widget.cart.isEmpty || _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Save Bill'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 18 : 14,
      color: bold ? accent : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();
  late Future<List<Map<String, Object?>>> _future;
  String _symbol = 'Rs.';

  @override
  void initState() {
    super.initState();
    _future = AppDatabase.instance.getCustomers();
    _search.addListener(_reload);
    AppDatabase.instance
        .getSetting('currency_symbol', fallback: 'Rs.')
        .then((value) {
      if (mounted) setState(() => _symbol = value);
    });
  }

  @override
  void dispose() {
    _search.removeListener(_reload);
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = AppDatabase.instance.getCustomers(search: _search.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Search customers',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, Object?>>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final customers = snapshot.data!;
              if (customers.isEmpty) {
                return const Center(child: Text('No customer records yet.'));
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      color: cardBg,
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        title: Text(customer['name'].toString()),
                        subtitle: Text(customer['phone']?.toString().isNotEmpty == true
                            ? customer['phone'].toString()
                            : 'No phone number'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total spent',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              money(numberDouble(customer['total_spent']), _symbol),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryBundle {
  const _HistoryBundle({required this.symbol, required this.sales});
  final String symbol;
  final List<Map<String, Object?>> sales;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<_HistoryBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryBundle> _load() async {
    final symbol = await AppDatabase.instance.getSetting(
      'currency_symbol',
      fallback: 'Rs.',
    );
    final sales = await AppDatabase.instance.getRecentSales(limit: 500);
    return _HistoryBundle(symbol: symbol, sales: sales);
  }

  Future<void> _showReceipt(Map<String, Object?> sale, String symbol) async {
    final saleId = numberInt(sale['id']);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt ${sale['invoice_no']}'),
        content: SizedBox(
          width: 500,
          child: FutureBuilder<List<Map<String, Object?>>>(
            future: AppDatabase.instance.getSaleItems(saleId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(displayDate(sale['sale_date'])),
                    Text('Customer: ${sale['customer_name'] ?? 'Walk-in'}'),
                    Text('Payment: ${sale['payment_method']}'),
                    const Divider(),
                    ...snapshot.data!.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['product_name']} × ${item['quantity']}',
                              ),
                            ),
                            Text(money(numberDouble(item['line_total']), symbol)),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    _TotalRow('Subtotal', money(numberDouble(sale['subtotal']), symbol)),
                    _TotalRow('Discount', money(numberDouble(sale['discount']), symbol)),
                    _TotalRow('Tax', money(numberDouble(sale['tax']), symbol)),
                    _TotalRow(
                      'TOTAL',
                      money(numberDouble(sale['total']), symbol),
                      bold: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoryBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        if (data.sales.isEmpty) {
          return const Center(child: Text('No saved bills yet.'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = _load());
            await _future;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.sales.length,
            itemBuilder: (context, index) {
              final sale = data.sales[index];
              return Card(
                color: cardBg,
                child: ListTile(
                  onTap: () => _showReceipt(sale, data.symbol),
                  leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                  title: Text(sale['invoice_no'].toString()),
                  subtitle: Text(
                    '${sale['customer_name'] ?? 'Walk-in'}\n${displayDate(sale['sale_date'])}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    money(numberDouble(sale['total']), data.symbol),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReportBundle {
  const _ReportBundle({
    required this.symbol,
    required this.summary,
    required this.top,
  });
  final String symbol;
  final Map<String, Object?> summary;
  final List<Map<String, Object?>> top;
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<_ReportBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReportBundle> _load() async {
    final symbol = await AppDatabase.instance.getSetting(
      'currency_symbol',
      fallback: 'Rs.',
    );
    final summary = await AppDatabase.instance.reportSummary();
    final top = await AppDatabase.instance.topSellingProducts(limit: 10);
    return _ReportBundle(symbol: symbol, summary: summary, top: top);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ReportBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final s = data.summary;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = _load());
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle(
                'Revenue & Profit',
                subtitle: 'Profit uses the cost price saved when each bill was made.',
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.25,
                children: [
                  MetricCard(
                    label: 'Today',
                    value: money(numberDouble(s['today_total']), data.symbol),
                    icon: Icons.today,
                  ),
                  MetricCard(
                    label: 'This Month',
                    value: money(numberDouble(s['month_total']), data.symbol),
                    icon: Icons.calendar_month,
                  ),
                  MetricCard(
                    label: 'This Year',
                    value: money(numberDouble(s['year_total']), data.symbol),
                    icon: Icons.trending_up,
                  ),
                  MetricCard(
                    label: 'All-time Revenue',
                    value: money(numberDouble(s['all_revenue']), data.symbol),
                    icon: Icons.payments_outlined,
                  ),
                  MetricCard(
                    label: 'Estimated Cost',
                    value: money(numberDouble(s['all_cost']), data.symbol),
                    icon: Icons.shopping_bag_outlined,
                  ),
                  MetricCard(
                    label: 'Estimated Profit',
                    value: money(numberDouble(s['all_profit']), data.symbol),
                    icon: Icons.savings_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionTitle('Top Selling Products'),
              if (data.top.isEmpty)
                const Card(child: ListTile(title: Text('No sales data yet.')))
              else
                ...data.top.asMap().entries.map(
                  (entry) => Card(
                    color: cardBg,
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${entry.key + 1}')),
                      title: Text(entry.value['product_name'].toString()),
                      subtitle: Text('${numberInt(entry.value['qty_sold'])} units sold'),
                      trailing: Text(
                        money(numberDouble(entry.value['revenue']), data.symbol),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shop = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _tax = TextEditingController();
  final _currency = TextEditingController();
  final _password = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _shop.dispose();
    _address.dispose();
    _phone.dispose();
    _tax.dispose();
    _currency.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await AppDatabase.instance.getAllSettings();
    _shop.text = settings['shop_name'] ?? 'Shri Shakra Sports';
    _address.text = settings['shop_address'] ?? '';
    _phone.text = settings['shop_phone'] ?? '';
    _tax.text = settings['tax_rate'] ?? '5';
    _currency.text = settings['currency_symbol'] ?? 'Rs.';
    _password.text = settings['app_password'] ?? '12345678';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_shop.text.trim().isEmpty || _password.text.isEmpty) {
      showMessage(context, 'Shop name and password cannot be empty.', error: true);
      return;
    }
    final tax = double.tryParse(_tax.text);
    if (tax == null || tax < 0 || tax > 100) {
      showMessage(context, 'Enter a valid tax percentage.', error: true);
      return;
    }
    setState(() => _saving = true);
    final values = {
      'shop_name': _shop.text.trim(),
      'shop_address': _address.text.trim(),
      'shop_phone': _phone.text.trim(),
      'tax_rate': _tax.text.trim(),
      'currency_symbol': _currency.text.trim().isEmpty ? 'Rs.' : _currency.text.trim(),
      'app_password': _password.text,
    };
    for (final entry in values.entries) {
      await AppDatabase.instance.setSetting(entry.key, entry.value);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    showMessage(context, 'Settings saved. Reopen the drawer to see the new shop name.');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(
          'Shop Settings',
          subtitle: 'These details are stored only on this device.',
        ),
        TextField(
          controller: _shop,
          decoration: const InputDecoration(labelText: 'Shop name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tax,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Default tax %'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _currency,
                decoration: const InputDecoration(labelText: 'Currency symbol'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          decoration: const InputDecoration(
            labelText: 'App password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Text('Save Settings'),
          ),
        ),
        const SizedBox(height: 20),
        const Card(
          color: cardBg,
          child: ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Offline database'),
            subtitle: Text(
              'Products, customers and bills are stored in the app’s private SQLite database.',
            ),
          ),
        ),
      ],
    );
  }
}
