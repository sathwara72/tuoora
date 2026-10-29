import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/student_controller.dart';

/// Edit a fee's milestones (title + amount), like web's "Edit Milestones".
/// Milestones with payments recorded can be changed but not removed, and the
/// total can't go below what has already been paid.
class EditMilestonesSheet extends StatefulWidget {
  final StudentFee fee;

  const EditMilestonesSheet({super.key, required this.fee});

  static Future<void> show(StudentFee fee) {
    return Get.bottomSheet(
      EditMilestonesSheet(fee: fee),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<EditMilestonesSheet> createState() => _EditMilestonesSheetState();
}

class _MilestoneRow {
  final int? id;
  final double paidAmount;
  final TextEditingController title;
  final TextEditingController amount;

  _MilestoneRow({
    this.id,
    this.paidAmount = 0,
    String title = '',
    String amount = '',
  }) : title = TextEditingController(text: title),
       amount = TextEditingController(text: amount);

  double get amountValue => double.tryParse(amount.text.trim()) ?? 0;

  void dispose() {
    title.dispose();
    amount.dispose();
  }
}

class _EditMilestonesSheetState extends State<EditMilestonesSheet> {
  final _controller = Get.find<InstituteStudentController>();
  String _money(double v) => formatRupees(v);
  late final List<_MilestoneRow> _rows;
  String? _error;

  @override
  void initState() {
    super.initState();
    final sorted = [...widget.fee.installments]
      ..sort((a, b) => a.order.compareTo(b.order));
    _rows = [
      for (final inst in sorted)
        _MilestoneRow(
          id: inst.id,
          paidAmount: inst.paidAmount,
          title: inst.title,
          amount: inst.amount.toStringAsFixed(inst.amount % 1 == 0 ? 0 : 2),
        ),
    ];
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  double get _total => _rows.fold(0, (sum, r) => sum + r.amountValue);

  /// Paid milestones can't be removed, so this is everything paid on the fee.
  double get _alreadyPaid => _rows.fold(0, (sum, r) => sum + r.paidAmount);

  void _addRow() {
    setState(() {
      _rows.add(_MilestoneRow(title: 'Installment ${_rows.length + 1}'));
      _error = null;
    });
  }

  void _removeRow(int index) {
    if (_rows.length == 1 || _rows[index].paidAmount > 0) return;
    setState(() {
      _rows.removeAt(index).dispose();
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_rows.any((r) => r.amountValue < 1)) {
      setState(
        () => _error = 'Every milestone needs an amount of at least ₹1.',
      );
      return;
    }
    if (_total < _alreadyPaid) {
      setState(
        () => _error =
            'Milestones total (${_money(_total)}) cannot be less than '
            'the amount already paid (${_money(_alreadyPaid)}).',
      );
      return;
    }
    setState(() => _error = null);

    final saved = await _controller.saveMilestones(widget.fee.id, [
      for (var i = 0; i < _rows.length; i++)
        {
          if (_rows[i].id != null) 'id': _rows[i].id,
          'title': _rows[i].title.text.trim().isNotEmpty
              ? _rows[i].title.text.trim()
              : 'Installment ${i + 1}',
          'amount': _rows[i].amountValue,
        },
    ]);
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.v16,
              Text(
                'Edit Milestones',
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v4,
              Text(
                'Change titles and amounts, add or remove milestones. '
                'Milestones with payments can\'t be removed.',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.v16,
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _rows.length; i++) _buildRow(i),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Milestone',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _buildTotals(),
              if (_error != null) ...[
                AppSpacing.v8,
                Text(
                  _error!,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
              AppSpacing.v16,
              Obx(
                () => AppButton(
                  label: 'Save Milestones',
                  isLoading: _controller.isSavingMilestones.value,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int i) {
    final row = _rows[i];
    final locked = row.paidAmount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: row.title,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Title',
                    hintText: 'Installment ${i + 1}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              AppSpacing.h8,
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,7}(\.\d{0,2})?'),
                    ),
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  style: AppTextStyles.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixText: '₹ ',
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: locked
                    ? 'Has payments, can\'t be removed'
                    : 'Remove milestone',
                onPressed: (_rows.length > 1 && !locked)
                    ? () => _removeRow(i)
                    : null,
                icon: Icon(
                  locked
                      ? Icons.lock_outline_rounded
                      : Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '${_money(row.paidAmount)} paid',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total: ${_money(_total)}',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_alreadyPaid > 0)
            Text(
              'Paid: ${_money(_alreadyPaid)}',
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
        ],
      ),
    );
  }
}
