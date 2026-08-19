import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class FinanceModuleScreen extends StatefulWidget {
  const FinanceModuleScreen({super.key});
  @override
  State<FinanceModuleScreen> createState() => _FinanceModuleScreenState();
}

class _FinanceModuleScreenState extends State<FinanceModuleScreen> {
  final _db = ZenDatabase();
  List<Expense> _expenses = [];
  Map<String, double> _categories = {};
  double _total = 0;
  bool _loading = true;

  // Currency settings
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';

  static final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final expenses = await _db.getExpenses(days: 30);
    final cats = await _db.getExpensesByCategory(days: 30);
    final total = await _db.getTotalExpenses(days: 30);
    if (mounted) setState(() { _expenses = expenses; _categories = cats; _total = total; _loading = false; });
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textMuted.withValues(alpha: 0.3)),
              ),
            ),
            SizedBox(height: 16),
            Text('SELECT CURRENCY', style: GoogleFonts.inter(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54), letterSpacing: 2, fontSize: 11)),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _currencies.map((curr) {
                  final isSelected = curr['code'] == _currencyCode;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.orange.withValues(alpha: 0.12) : LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                      ),
                      alignment: Alignment.center,
                      child: Text(curr['symbol']!, style: GoogleFonts.inter(color: isSelected ? AppColors.orange : LibraryDesignSystem.textPrimary, fontSize: 16)),
                    ),
                    title: Text(curr['code']!, style: GoogleFonts.inter(color: LibraryDesignSystem.textPrimary, fontWeight: FontWeight.w700)),
                    subtitle: Text(curr['name']!, style: GoogleFonts.inter(color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.54), fontSize: 9)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.orange) : null,
                    onTap: () {
                      setState(() {
                        _currencyCode = curr['code']!;
                        _currencySymbol = curr['symbol']!;
                      });
                      Navigator.pop(c);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExpense({Expense? existingExpense}) async {
    final amountCtrl = TextEditingController(text: existingExpense?.amount.toStringAsFixed(2) ?? '');
    final descCtrl = TextEditingController(text: existingExpense?.description ?? '');
    String category = existingExpense?.category ?? 'food';
    final cats = ['food', 'transport', 'shopping', 'entertainment', 'bills', 'health', 'education', 'startup', 'other'];
    final isEditing = existingExpense != null;

    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => StatefulBuilder(builder: (c, ss) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(c).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textMuted.withValues(alpha: 0.3)))),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                isEditing ? 'Edit Expense' : 'Add Expense',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              if (isEditing) ...[ 
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(c);
                    await _db.deleteExpense(existingExpense.id);
                    _loadData();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.red.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.red),
                      SizedBox(width: 4),
                      Text('Delete', style: GoogleFonts.inter(fontSize: 9, color: AppColors.red)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 24),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '$_currencySymbol ',
              prefixStyle: GoogleFonts.inter(color: AppColors.orange, fontSize: 24),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: descCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: 'Description (optional)'),
          ),
          SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: cats.map((c2) {
            final sel = category == c2;
            return GestureDetector(
              onTap: () => ss(() => category = c2),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: sel ? AppColors.orange.withValues(alpha: 0.12) : Colors.transparent, border: Border.all(color: sel ? AppColors.orange : AppColors.border)),
                child: Text(c2.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: sel ? AppColors.orange : AppColors.textMuted)),
              ),
            );
          }).toList()),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) return;
              if (isEditing) {
                // Replace by deleting old and inserting new
                await _db.deleteExpense(existingExpense.id);
                await _db.insertExpense(Expense(
                  id: existingExpense.id,
                  amount: amount,
                  category: category,
                  description: descCtrl.text.trim(),
                  date: existingExpense.date,
                ));
              } else {
                await _db.insertExpense(Expense(amount: amount, category: category, description: descCtrl.text.trim(), date: DateTime.now()));
              }
              if (c.mounted) Navigator.pop(c);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: LibraryDesignSystem.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(isEditing ? 'Save Changes' : 'Log Expense', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          )),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Finance', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        actions: [
          // Currency selector
          GestureDetector(
            onTap: _showCurrencyPicker,
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.orange.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currencySymbol, style: GoogleFonts.inter(color: AppColors.orange, fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Text(_currencyCode, style: GoogleFonts.inter(color: AppColors.orange, fontSize: 9)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.orange),
                ],
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.add), onPressed: () => _addExpense()),
        ],
      ),
      body: _loading ? Center(child: CircularProgressIndicator(color: AppColors.orange)) : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          MetricCard(
            title: '30-DAY SPENDING',
            value: '$_currencySymbol${_total.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet,
            color: AppColors.orange,
          ),
          SizedBox(height: 12),
          // Category breakdown
          if (_categories.isNotEmpty) ...[
            SectionHeader(title: 'BY CATEGORY', icon: Icons.pie_chart, color: AppColors.orange),
            ..._categories.entries.map((e) {
              final pct = _total > 0 ? (e.value / _total * 100) : 0;
              return Container(
                margin: EdgeInsets.only(bottom: 6),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  SizedBox(width: 80, child: Text(e.key.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: (pct / 100).clamp(0.0, 1.0), backgroundColor: AppColors.textMuted, valueColor: AlwaysStoppedAnimation(AppColors.orange), minHeight: 6),
                  )),
                  SizedBox(width: 10),
                  Text('$_currencySymbol${e.value.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              );
            }),
          ],
          SizedBox(height: 12),
          SectionHeader(title: 'RECENT', icon: Icons.receipt_long, color: AppColors.green),
          if (_expenses.isEmpty)
            EmptyState(icon: Icons.receipt, title: 'No Expenses', subtitle: 'Start tracking your spending', color: AppColors.orange)
          else ..._expenses.take(20).map((exp) => Container(
            margin: EdgeInsets.only(bottom: 6),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.03), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Text(exp.categoryEmoji, style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((exp.description != null && exp.description!.isNotEmpty) ? exp.description! : exp.category, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                Text(exp.category.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, color: AppColors.textMuted)),
              ])),
              Text('-$_currencySymbol${exp.amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.red)),
              SizedBox(width: 8),
              // Edit button
              GestureDetector(
                onTap: () => _addExpense(existingExpense: exp),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
                  ),
                  child: Icon(Icons.edit_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}