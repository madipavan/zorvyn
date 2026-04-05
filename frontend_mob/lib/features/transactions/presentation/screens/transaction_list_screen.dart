import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/core/utils/app_constants.dart';
import 'package:frontend_mob/shared/widgets/amount_text.dart';
import 'package:frontend_mob/shared/widgets/category_badge.dart';
import 'package:frontend_mob/shared/widgets/empty_state_widget.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  TransactionType? _selectedType;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionBloc>()..add(LoadTransactions()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions', style: AppTextStyles.heading(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => context.push('/transactions/add'),
            ),
          ],
        ),
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.expense,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is TransactionActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.income,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildSearchAndFilter(context),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => _reload(context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedType == null,
                  onTap: () => setState(() {
                    _selectedType = null;
                    _reload(context);
                  }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  selected: _selectedType == TransactionType.income,
                  color: AppColors.income,
                  onTap: () => setState(() {
                    _selectedType = _selectedType == TransactionType.income
                        ? null
                        : TransactionType.income;
                    _reload(context);
                  }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  selected: _selectedType == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () => setState(() {
                    _selectedType = _selectedType == TransactionType.expense
                        ? null
                        : TransactionType.expense;
                    _reload(context);
                  }),
                ),
                const SizedBox(width: 8),
                ...AppConstants.expenseCategories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: cat,
                      selected: _selectedCategory == cat,
                      onTap: () => setState(() {
                        _selectedCategory = _selectedCategory == cat
                            ? null
                            : cat;
                        _reload(context);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reload(BuildContext context) {
    context.read<TransactionBloc>().add(
      LoadTransactions(
        category: _selectedCategory,
        type: _selectedType,
        search: _searchCtrl.text,
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransactionState state) {
    if (state is TransactionLoading) {
      return const LoadingShimmerList();
    }
    if (state is TransactionError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<TransactionBloc>().add(LoadTransactions()),
      );
    }
    if (state is TransactionLoaded) {
      if (state.transactions.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions yet',
          subtitle: 'Tap the + button to add your first transaction',
          actionLabel: 'Add Transaction',
          onAction: () => context.push('/transactions/add'),
        );
      }
      return _buildList(context, state.transactions);
    }
    return const SizedBox.shrink();
  }

  Widget _buildList(BuildContext context, List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key = DateFormat('dd MMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final date = grouped.keys.elementAt(i);
        final items = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: AppTextStyles.body(context).copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...items.map(
              (t) => _TransactionTile(
                transaction: t,
                onDelete: () => context.read<TransactionBloc>().add(
                  DeleteTransactionEvent(t.id),
                ),
                onEdit: () => context.push('/transactions/${t.id}/edit'),
              ),
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? activeColor : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected
                ? activeColor
                : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TransactionTile({
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: AppTextStyles.body(context).copyWith(color: AppColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              CategoryBadge(category: transaction.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty)
                      Text(
                        transaction.note!,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              AmountText(
                amount: transaction.amount,
                isIncome: transaction.type == TransactionType.income,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
