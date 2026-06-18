part of 'analytics_bloc.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

final class AnalyticsLoaded extends AnalyticsState {
  final int completedThisMonth;
  final int completedToday;
  final double avgCompletionMinutes;
  final double slaCompliancePercent;
  final List<int> weeklyCounts;

  const AnalyticsLoaded({
    required this.completedThisMonth,
    required this.completedToday,
    required this.avgCompletionMinutes,
    required this.slaCompliancePercent,
    required this.weeklyCounts,
  });

  @override
  List<Object?> get props => [
        completedThisMonth,
        completedToday,
        avgCompletionMinutes,
        slaCompliancePercent,
        weeklyCounts,
      ];
}

final class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError({required this.message});
  @override
  List<Object?> get props => [message];
}
