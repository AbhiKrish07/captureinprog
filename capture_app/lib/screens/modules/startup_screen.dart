import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

import '../../core/modules_mocks.dart';
import '../../models/modules_models.dart';
import '../../widgets/modules_widgets.dart';

class StartupModuleScreen extends StatefulWidget {
  const StartupModuleScreen({super.key});
  @override
  State<StartupModuleScreen> createState() => _StartupModuleScreenState();
}

class _StartupModuleScreenState extends State<StartupModuleScreen> {
  final _db = ZenDatabase();
  final _brain = ZenBrain();
  StartupMetrics? _metrics;
  List<Investor> _investors = [];
  Map<String, dynamic>? _defaultAlive;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final metrics = await _db.getLatestStartupMetrics();
    final investors = await _db.getInvestors();
    final alive = await _brain.defaultAliveCalculation();
    if (mounted) {
      setState(() {
        _metrics = metrics;
        _investors = investors;
        _defaultAlive = alive;
        _loading = false;
      });
    }
  }

  Future<void> _updateMetrics() async {
    final mrrCtrl = TextEditingController(text: _metrics?.mrr.toString() ?? '0');
    final burnCtrl = TextEditingController(text: _metrics?.burnRate.toString() ?? '0');
    final usersCtrl = TextEditingController(text: _metrics?.totalUsers.toString() ?? '0');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(c).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Update Metrics', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            SizedBox(height: 16),
            TextField(
              controller: mrrCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'MRR (\$)', prefixText: '\$ '),
            ),
            SizedBox(height: 8),
            TextField(
              controller: burnCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Monthly Burn (\$)', prefixText: '\$ '),
            ),
            SizedBox(height: 8),
            TextField(
              controller: usersCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Total Users'),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final mrr = double.tryParse(mrrCtrl.text) ?? 0;
                  final burn = double.tryParse(burnCtrl.text) ?? 0;
                  final users = int.tryParse(usersCtrl.text) ?? 0;
                  final runway = burn > 0 ? (mrr / burn) * 12 : 0.0;
                  await _db.insertStartupMetrics(StartupMetrics(
                    mrr: mrr, burnRate: burn, totalUsers: users, runwayMonths: runway,
                  ));
                  if (c.mounted) Navigator.pop(c);
                  _loadData();
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addInvestor() async {
    final nameCtrl = TextEditingController();
    final firmCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(c).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Add Investor', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Investor name'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: firmCtrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Firm (optional)'),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  await _db.insertInvestor(Investor(
                    name: nameCtrl.text.trim(), firm: firmCtrl.text.trim(),
                  ));
                  if (c.mounted) Navigator.pop(c);
                  _loadData();
                },
                child: Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Startup HQ', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _updateMetrics),
          IconButton(icon: Icon(Icons.person_add), onPressed: _addInvestor),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.orange))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.orange,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Default alive card
                    if (_defaultAlive != null && _defaultAlive!['alive'] != null)
                      _buildAliveCard(),
                    // Metrics
                    Row(children: [
                      Expanded(child: MetricCard(
                        title: 'MRR', value: '\$${_metrics?.mrr.toStringAsFixed(0) ?? '0'}',
                        icon: Icons.trending_up, color: AppColors.green,
                      )),
                      SizedBox(width: 8),
                      Expanded(child: MetricCard(
                        title: 'BURN', value: '\$${_metrics?.burnRate.toStringAsFixed(0) ?? '0'}/mo',
                        icon: Icons.local_fire_department, color: AppColors.red,
                      )),
                    ]),
                    SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: MetricCard(
                        title: 'RUNWAY', value: '${_metrics?.runwayMonths.toStringAsFixed(1) ?? '0'} mo',
                        icon: Icons.flight_takeoff, color: AppColors.yellow,
                      )),
                      SizedBox(width: 8),
                      Expanded(child: MetricCard(
                        title: 'USERS', value: '${_metrics?.totalUsers ?? 0}',
                        icon: Icons.people, color: AppColors.textMuted,
                      )),
                    ]),
                    SizedBox(height: 16),
                    // Investor pipeline
                    SectionHeader(title: 'INVESTOR PIPELINE', icon: Icons.business_center, color: Color(0xFFF59E0B)),
                    if (_investors.isEmpty)
                      EmptyState(
                        icon: Icons.person_add, title: 'No Investors',
                        subtitle: 'Track your fundraising pipeline',
                        color: Color(0xFFF59E0B),
                      )
                    else
                      ..._investors.map((inv) => _buildInvestorCard(inv)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAliveCard() {
    final isAlive = _defaultAlive!['alive'] as bool;
    final color = isAlive ? AppColors.green : AppColors.red;
    return GlassContainer(
      margin: EdgeInsets.only(bottom: 12),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(isAlive ? '✅' : '🔴', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Text(
              isAlive ? 'DEFAULT ALIVE' : 'DEFAULT DEAD',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ]),
          SizedBox(height: 8),
          Text(
            _defaultAlive!['message'] as String,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorCard(Investor inv) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Text(inv.stageEmoji, style: TextStyle(fontSize: 20)),
        SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inv.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (inv.firm.isNotEmpty)
              Text(inv.firm, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
          ],
        )),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.orange.withValues(alpha: 0.12),
          ),
          child: Text(
            inv.stage.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.orange),
          ),
        ),
      ]),
    );
  }
}