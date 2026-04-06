import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/utils/app_constants.dart';
import 'package:frontend_mob/core/widgets/app_button.dart';
import 'package:frontend_mob/features/transactions/presentation/cubit/transaction_form_cubit.dart';
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
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefilled && widget.isEdit) {
      _prefilled = true;
      final bloc = context.read<TransactionBloc>();
      if (bloc.state is TransactionLoaded) {
        final transactions = (bloc.state as TransactionLoaded).transactions;
        try {
          final t = transactions.firstWhere(
            (tx) => tx.id == widget.transactionId,
          );
          _amountCtrl.text = t.amount.toString();
          _noteCtrl.text = t.note ?? '';
          context.read<TransactionFormCubit>().prefill(
            type: t.type,
            category: t.category,
            date: t.date,
          );
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionFormCubit(),
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
        builder: (context, txState) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isEdit ? 'Edit Transaction' : 'Add Transaction',
                  style: AppTextStyles.subHeading(context),
                ),
              ),
              body: BlocBuilder<TransactionFormCubit, TransactionFormState>(
                builder: (context, form) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTypeToggle(context, form),
                          const SizedBox(height: 24),
                          _buildAmountField(context),
                          const SizedBox(height: 24),
                          _buildCategorySection(context, form),
                          const SizedBox(height: 24),
                          _buildDatePicker(context, form),
                          const SizedBox(height: 24),
                          _buildNoteField(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(context, txState, form),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeToggle(BuildContext context, TransactionFormState form) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context
                  .read<TransactionFormCubit>()
                  .setType(TransactionType.expense),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: form.type == TransactionType.expense
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
                      color: form.type == TransactionType.expense
                          ? Colors.white
                          : AppColors.expense,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: form.type == TransactionType.expense
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
              onTap: () => context
                  .read<TransactionFormCubit>()
                  .setType(TransactionType.income),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: form.type == TransactionType.income
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
                      color: form.type == TransactionType.income
                          ? Colors.white
                          : AppColors.income,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: form.type == TransactionType.income
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
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.heading(
            context,
          ).copyWith(fontSize: 24, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: AppTextStyles.heading(
              context,
            ).copyWith(fontSize: 24, fontWeight: FontWeight.w700),
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

  Widget _buildCategorySection(
      BuildContext context, TransactionFormState form) {
    final categories = form.type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = form.category == cat;
            return GestureDetector(
              onTap: () =>
                  context.read<TransactionFormCubit>().setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.categoryIcons[cat] ?? '💰',
                      style:
                          AppTextStyles.body(context).copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
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

  Widget _buildDatePicker(BuildContext context, TransactionFormState form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: form.date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null && context.mounted) {
              context.read<TransactionFormCubit>().setDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMMM yyyy').format(form.date),
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
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildSubmitButton(
    BuildContext context,
    TransactionState txState,
    TransactionFormState form,
  ) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: widget.isEdit ? 'Update Transaction' : 'Add Transaction',
        loading: txState is TransactionLoading,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final transaction = Transaction(
              id: widget.transactionId ?? const Uuid().v4(),
              amount: double.parse(_amountCtrl.text),
              type: form.type,
              category: form.category,
              date: form.date,
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
      ),
    );
  }
}
