// lib/ui/overlays/monthly_summary_modal.dart
// ZERO EMOJIS - Kairosoft Double-Bordered Monthly Financial Statement.

import 'package:flutter/material.dart';
import '../../domain/models/monthly_ledger.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class MonthlySummaryModal extends StatelessWidget {
  final MonthlyLedger ledger;
  final VoidCallback onDismiss;

  const MonthlySummaryModal({
    super.key,
    required this.ledger,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final rawMonth = GameStateProvider.monthNames[(ledger.month - 1) % 12];
    final monthShort = rawMonth.split(' ').first.toUpperCase();
    final isProfit = ledger.netProfit >= 0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 330,
          title: 'BUWANANG ULAT SA KEUWANGAN',
          backgroundColor: const Color(0xFF1E293B),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calendar Period Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RetroColors.deepBackground,
                  border: Border.all(color: RetroColors.gold, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TAON ${ledger.year}',
                      style: const TextStyle(
                        color: RetroColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      monthShort,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 1. REVENUE BREAKDOWN
              _buildSectionTitle('MGA KITA (REVENUE)', RetroColors.green),
              const SizedBox(height: 4),
              _buildFinanceRow('Tuition ng Estudyante', '+P${ledger.tuitionIncome}', RetroColors.green),
              if (ledger.passiveIncome > 0)
                _buildFinanceRow('Sari-sari Store', '+P${ledger.passiveIncome}', RetroColors.green),
              if (ledger.sponsorIncome > 0)
                _buildFinanceRow('Sponsor / Donasyon', '+P${ledger.sponsorIncome}', RetroColors.green),
              if (ledger.prizeIncome > 0)
                _buildFinanceRow('Premyo sa Laban', '+P${ledger.prizeIncome}', RetroColors.green),
              const Divider(color: Color(0xFF334155), height: 8),
              _buildFinanceRow('Kabuuang Kita', '+P${ledger.totalIncome}', RetroColors.green, isBold: true),

              const SizedBox(height: 10),

              // 2. EXPENSES BREAKDOWN
              _buildSectionTitle('MGA GASTOS (EXPENSES)', RetroColors.red),
              const SizedBox(height: 4),
              _buildFinanceRow('Kuryente at Renta (Upkeep)', '-P${ledger.upkeepDeduction}', RetroColors.red),
              if (ledger.trainerSalaries > 0)
                _buildFinanceRow('Sahod ng mga Guro', '-P${ledger.trainerSalaries}', RetroColors.red),
              if (ledger.debtRepayment > 0)
                _buildFinanceRow('Hulog sa Pautang', '-P${ledger.debtRepayment}', RetroColors.red),
              const Divider(color: Color(0xFF334155), height: 8),
              _buildFinanceRow('Kabuuang Gastos', '-P${ledger.totalExpenses}', RetroColors.red, isBold: true),

              const SizedBox(height: 10),

              // 3. NET PROFIT / LOSS SUMMARY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isProfit
                      ? RetroColors.green.withValues(alpha: 0.15)
                      : RetroColors.red.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isProfit ? RetroColors.green : RetroColors.red,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isProfit ? 'TUBÒ (NET PROFIT):' : 'LUGI (DEFICIT):',
                      style: TextStyle(
                        color: isProfit ? RetroColors.green : RetroColors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      isProfit ? '+P${ledger.netProfit}' : '-P${ledger.netProfit.abs()}',
                      style: TextStyle(
                        color: isProfit ? RetroColors.green : RetroColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 4. CURRENT BANK BALANCE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KABAN NG KAMPO (BALANCE):',
                    style: TextStyle(
                      color: RetroColors.textMuted,
                      fontSize: 9,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'P${ledger.endingMoney}',
                    style: const TextStyle(
                      color: RetroColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),

              // 5. BAILOUT / SAFETY NET ALERT
              if (ledger.hadBailout) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  ),
                  child: const Text(
                    '[SAKLOPO] Naubusan ng pondo ang kampo! Nagbigay ng P2,000 pautang ang kamag-anak (P250/linggo ibabawas sa loob ng 8 linggo).',
                    style: TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 8,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              // 6. LOW MONEY WARNING
              if (ledger.endingMoney < 200 && !ledger.hadBailout) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D),
                    border: Border.all(color: RetroColors.red, width: 1.5),
                  ),
                  child: const Text(
                    '[BABALA] Mababa na ang natitirang pera ng kampo (<P200)! Magtipid sa pagpapatayo ng gamit o magsanay para makasingil ng tuition.',
                    style: TextStyle(
                      color: Color(0xFFFEE2E2),
                      fontSize: 8,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // DISMISS BUTTON
              RetroButton(
                color: RetroColors.gold,
                onTap: onDismiss,
                child: const Text(
                  'TANGGAPIN AT MAGPATULOY',
                  style: TextStyle(
                    color: Color(0xFF1A1C2C),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildFinanceRow(String label, String amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : const Color(0xFFE2E8F0),
              fontSize: 8,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
