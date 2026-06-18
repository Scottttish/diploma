import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/analytics_remote_datasource.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

final class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRemoteDataSource _datasource;

  AnalyticsBloc({AnalyticsRemoteDataSource? datasource})
      : _datasource = datasource ?? AnalyticsRemoteDataSource(),
        super(const AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await _datasource.fetchMyAnalytics();
      emit(AnalyticsLoaded(
        completedThisMonth: data['completed_this_month'] as int? ?? 0,
        completedToday: data['completed_today'] as int? ?? 0,
        avgCompletionMinutes:
            (data['avg_completion_minutes'] as num?)?.toDouble() ?? 0,
        slaCompliancePercent:
            (data['sla_compliance_percent'] as num?)?.toDouble() ?? 100,
        weeklyCounts: (data['weekly_counts'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            List.filled(7, 0),
      ),);
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }
}
