import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final String? transactionId;

  const AddEditTransactionScreen({super.key, this.transactionId});

  bool get isEdit => transactionId != null;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = AppConstants.expenseCategories.first;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == TransactionType.expense
      ? AppConstants.expenseCategories
      : AppConstants.incomeCategories;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionBloc>(),
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            context.pop();
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isEdit ? 'Edit Transaction' : 'Add Transaction',
                style: AppTextStyles.heading(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(),
                    const SizedBox(height: 24),
                    _buildAmountField(context),
                    const SizedBox(height: 24),
                    _buildCategorySection(context),
                    const SizedBox(height: 24),
                    _buildDatePicker(context),
                    const SizedBox(height: 24),
                    _buildNoteField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = TransactionType.expense;
                _category = AppConstants.expenseCategories.first;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.expense
                      ? AppColors.expense
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: _type == TransactionType.expense
                          ? Colors.white
                          : AppColors.expense,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: _type == TransactionType.expense
                            ? Colors.white
                            : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = TransactionType.income;
                _category = AppConstants.incomeCategories.first;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == TransactionType.income
                      ? AppColors.income
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: _type == TransactionType.income
                          ? Colors.white
                          : AppColors.income,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: _type == TransactionType.income
                            ? Colors.white
                            : AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.heading(context).copyWith(fontSize: 24, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: AppTextStyles.heading(context).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            hintText: '0.00',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter an amount';
            if (double.tryParse(v) == null) return 'Enter a valid amount';
            if (double.parse(v) <= 0) return 'Amount must be greater than 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _category == cat;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.categoryIcons[cat] ?? '💰',
                      style: AppTextStyles.body(context).copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _date = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMMM yyyy').format(_date),
                  style: AppTextStyles.body(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (optional)',
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Add a note...'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, TransactionState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is TransactionLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  final transaction = Transaction(
                    id: widget.transactionId ?? const Uuid().v4(),
                    amount: double.parse(_amountCtrl.text),
                    type: _type,
                    category: _category,
                    date: _date,
                    note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
                  );
                  if (widget.isEdit) {
                    context.read<TransactionBloc>().add(
                      UpdateTransactionEvent(transaction),
                    );
                  } else {
                    context.read<TransactionBloc>().add(
                      AddTransactionEvent(transaction),
                    );
                  }
                }
              },
        child: state is TransactionLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.isEdit ? 'Update Transaction' : 'Add Transaction',
                style: AppTextStyles.button(context),
              ),
      ),
    );
  }
}
