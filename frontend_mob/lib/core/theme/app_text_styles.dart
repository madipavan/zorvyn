import 'package:flutter/material.dart';

class AppTextStyles {
  // ── Display (Balance hero numbers) ───────────────────────────────────────
  static TextStyle displayLarge(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      );

  static TextStyle displayMedium(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      );

  static TextStyle displaySmall(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  // Shorthand used for balance hero (48px)
  static TextStyle balanceHero(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
      );

  // ── Headline ─────────────────────────────────────────────────────────────
  static TextStyle headlineLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle headlineMedium(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  // ── Title ─────────────────────────────────────────────────────────────────
  static TextStyle titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w600,
      );

  static TextStyle titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
      );

  static TextStyle titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w600,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  static TextStyle bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  // ── Label ─────────────────────────────────────────────────────────────────
  static TextStyle labelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w600,
      );

  static TextStyle labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!;

  // ── Legacy aliases (keeps existing widgets compiling) ────────────────────
  static TextStyle display(BuildContext context) => displaySmall(context);
  static TextStyle heading(BuildContext context) => headlineMedium(context);
  static TextStyle subHeading(BuildContext context) => titleMedium(context);
  static TextStyle body(BuildContext context) => bodyMedium(context);
  static TextStyle button(BuildContext context) => labelLarge(context);

  // ── Section label ─────────────────────────────────────────────────────────
  static TextStyle sectionHeader(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0,
      );
}
