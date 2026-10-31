// lib/domain/models/monthly_ledger.dart
// PURE DART - NO FLAME IMPORTS.
// Represents the monthly financial accounting statement (Kairosoft Monthly Summary).

class MonthlyLedger {
  final int month;
  final int year;
  final int startingMoney;
  final int tuitionIncome;
  final int passiveIncome;
  final int sponsorIncome;
  final int prizeIncome;
  final int upkeepDeduction;
  final int trainerSalaries;
  final int debtRepayment;
  final int bailoutGranted;
  final int endingMoney;

  const MonthlyLedger({
    required this.month,
    required this.year,
    required this.startingMoney,
    this.tuitionIncome = 0,
    this.passiveIncome = 0,
    this.sponsorIncome = 0,
    this.prizeIncome = 0,
    this.upkeepDeduction = 0,
    this.trainerSalaries = 0,
    this.debtRepayment = 0,
    this.bailoutGranted = 0,
    required this.endingMoney,
  });

  int get totalIncome => tuitionIncome + passiveIncome + sponsorIncome + prizeIncome;
  int get totalExpenses => upkeepDeduction + trainerSalaries + debtRepayment;
  int get netProfit => totalIncome - totalExpenses;
  bool get hadBailout => bailoutGranted > 0;

  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'startingMoney': startingMoney,
        'tuitionIncome': tuitionIncome,
        'passiveIncome': passiveIncome,
        'sponsorIncome': sponsorIncome,
        'prizeIncome': prizeIncome,
        'upkeepDeduction': upkeepDeduction,
        'trainerSalaries': trainerSalaries,
        'debtRepayment': debtRepayment,
        'bailoutGranted': bailoutGranted,
        'endingMoney': endingMoney,
      };

  factory MonthlyLedger.fromJson(Map<String, dynamic> json) => MonthlyLedger(
        month: json['month'] as int? ?? 1,
        year: json['year'] as int? ?? 1,
        startingMoney: json['startingMoney'] as int? ?? 1000,
        tuitionIncome: json['tuitionIncome'] as int? ?? 0,
        passiveIncome: json['passiveIncome'] as int? ?? 0,
        sponsorIncome: json['sponsorIncome'] as int? ?? 0,
        prizeIncome: json['prizeIncome'] as int? ?? 0,
        upkeepDeduction: json['upkeepDeduction'] as int? ?? 0,
        trainerSalaries: json['trainerSalaries'] as int? ?? 0,
        debtRepayment: json['debtRepayment'] as int? ?? 0,
        bailoutGranted: json['bailoutGranted'] as int? ?? 0,
        endingMoney: json['endingMoney'] as int? ?? 1000,
      );
}
