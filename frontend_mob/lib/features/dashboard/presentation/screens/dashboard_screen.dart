import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/core/widgets/app_snackbar.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:frontend_mob/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:frontend_mob/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:frontend_mob/features/dashboard/presentation/widgets/market_watch.dart';
import 'package:frontend_mob/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:frontend_mob/features/dashboard/presentation/widgets/savings_card.dart';
import 'package:frontend_mob/shared/widgets/error_state_widget.dart';
import 'package:frontend_mob/shared/widgets/loading_shrimmer_list.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DashboardBloc>()..add(LoadDashboard()),
        ),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardBloc>().add(LoadDashboard()),
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (state is DashboardLoading)
                  const SliverFillRemaining(child: LoadingShimmerList())
                else if (state is DashboardError)
                  SliverFillRemaining(
                    child: ErrorStateWidget(
                      message: state.message,
                      onRetry: () =>
                          context.read<DashboardBloc>().add(LoadDashboard()),
                    ),
                  )
                else if (state is DashboardLoaded)
                  ..._buildContent(context, state.summary)
                else
                  const SliverFillRemaining(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent, // Let Scaffold bg show through
      scrolledUnderElevation: 0,
      title: Text(
        'Finance Companion',
        style: AppTextStyles.displaySmall(context).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () async {
            await getIt<NotificationService>().requestPermissions();
            await getIt<NotificationService>().scheduleTestReminder();
            if (context.mounted) {
              AppSnackbar.show(
                context,
                'Test reminder scheduled for 5 seconds! 🔔',
              );
            }
          },
        ),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => getIt<ThemeCubit>().toggle(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context, DashboardSummary summary) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            BalanceCard(summary: summary),
            const SizedBox(height: 36),
            RecentTransactions(
              transactions: summary.recentTransactions,
              onSeeAll: () => context.go('/transactions'),
            ),
            const SizedBox(height: 36),
            const SavingsCard(),
            const SizedBox(height: 24),
            const MarketWatch(),
            const SizedBox(height: 120), // Padding for nav bar
          ]),
        ),
      ),
    ];
  }
}
