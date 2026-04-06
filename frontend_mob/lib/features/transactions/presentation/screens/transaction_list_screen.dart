import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/features/transactions/presentation/cubit/transaction_filter_cubit.dart';
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

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<TransactionBloc>()..add(LoadTransactions()),
        ),
        BlocProvider(create: (_) => TransactionFilterCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          centerTitle: true,
          title: Text(
            'Transactions',
            style: AppTextStyles.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90.0, right: 8.0),
          child: Builder(
            builder: (ctx) => FloatingActionButton(
              heroTag: 'transaction_add_fab',
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => ctx.push('/transactions/add'),
            ),
          ),
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
            return _buildBody(context, state);
          },
        ),
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
      return BlocBuilder<TransactionFilterCubit, String>(
        builder: (context, activeFilter) {
          List<Transaction> filteredList = state.transactions;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          if (activeFilter == 'Income') {
            filteredList = filteredList
                .where((t) => t.type == TransactionType.income)
                .toList();
          } else if (activeFilter == 'Expenses') {
            filteredList = filteredList
                .where((t) => t.type == TransactionType.expense)
                .toList();
          } else if (activeFilter == 'Today') {
            filteredList = filteredList.where((t) {
              final tDate = DateTime(t.date.year, t.date.month, t.date.day);
              return tDate == today;
            }).toList();
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<TransactionBloc>().add(LoadTransactions()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildFilterPills(context, activeFilter),
                ),
                if (filteredList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions found',
                      subtitle:
                          'Try changing your filter or add a new transaction',
                      actionLabel: 'Add Transaction',
                      onAction: () => context.push('/transactions/add'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: _buildList(context, filteredList),
                  ),
              ],
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilterPills(BuildContext context, String activeFilter) {
    final filters = ['All', 'Income', 'Expenses', 'Today'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = activeFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () =>
                    context.read<TransactionFilterCubit>().setFilter(f),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    f,
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: isActive
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};

    for (final t in transactions) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final date = DateTime(t.date.year, t.date.month, t.date.day);

      String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('dd MMM yyyy').format(t.date);
      }

      grouped.putIfAbsent(key, () => []).add(t);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        final dateStr = grouped.keys.elementAt(i);
        final items = grouped[dateStr]!;

        double netAmount = 0.0;
        for (final transaction in items) {
          if (transaction.type == TransactionType.income) {
            netAmount += transaction.amount;
          } else {
            netAmount -= transaction.amount;
          }
        }

        final isPositiveNet = netAmount >= 0;
        final netLabel =
            (dateStr == 'Yesterday' ||
                dateStr.contains('202') && !dateStr.contains('Today'))
            ? 'Total Spent'
            : 'Net';

        final sign = isPositiveNet && netAmount != 0 ? '+' : '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: AppTextStyles.titleLarge(context).copyWith(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '$netLabel: $sign${NumberFormat.currency(symbol: '\$').format(netAmount)}',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
            ],
          ),
        );
      }, childCount: grouped.length),
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
    final timeStr = DateFormat('HH:mm a').format(transaction.date);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
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
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
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
                  style: AppTextStyles.labelLarge(
                    context,
                  ).copyWith(color: AppColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CategoryBadge(
              category: transaction.category,
              size: 48,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note != null && transaction.note!.isNotEmpty
                        ? transaction.note!
                        : transaction.category,
                    style: AppTextStyles.titleMedium(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    AmountText(
                      amount: transaction.amount,
                      isIncome: transaction.type == TransactionType.income,
                      fontSize: 16,
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
