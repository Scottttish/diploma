from datetime import datetime, timezone, date, timedelta
from sqlalchemy import func, and_
from sqlalchemy.orm import Session
from app.models.task import Task, TaskStatus
from app.models.user import User, UserRole


class AnalyticsService:
    def __init__(self, db: Session):
        self.db = db

    def get_overview(self) -> dict:
        counts = (
            self.db.query(Task.status, func.count(Task.id))
            .group_by(Task.status)
            .all()
        )
        by_status = {str(s.value): c for s, c in counts}
        total        = sum(by_status.values())
        overdue_count = by_status.get(TaskStatus.overdue.value, 0)
        return {"by_status": by_status, "total": total, "overdue_count": overdue_count}

    def get_worker_stats(self) -> list[dict]:
        rows = (
            self.db.query(
                User.id,
                User.full_name,
                func.count(Task.id).label("total"),
                func.avg(
                    func.extract("epoch", Task.updated_at) - func.extract("epoch", Task.created_at)
                ).label("avg_seconds"),
            )
            .join(Task, Task.assigned_to == User.id)
            .filter(
                User.role == UserRole.worker,
                Task.status == TaskStatus.completed,
            )
            .group_by(User.id, User.full_name)
            .all()
        )
        return [
            {
                "worker_id": r.id,
                "full_name": r.full_name,
                "completed_tasks": r.total,
                "avg_completion_seconds": round(float(r.avg_seconds or 0), 1),
            }
            for r in rows
        ]

    def get_my_stats(self, worker_id: int) -> dict:
        now = datetime.now(timezone.utc)
        month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

        base_q = self.db.query(Task).filter(
            Task.assigned_to == worker_id,
            Task.status == TaskStatus.completed,
        )

        completed_this_month = base_q.filter(Task.completed_at >= month_start).count()
        completed_today = base_q.filter(Task.completed_at >= today_start).count()

        avg_row = base_q.filter(Task.completed_at.isnot(None), Task.started_at.isnot(None)).with_entities(
            func.avg(
                func.extract("epoch", Task.completed_at) - func.extract("epoch", Task.started_at)
            )
        ).scalar()
        avg_completion_minutes = round((avg_row or 0) / 60, 1)

        # SLA compliance: tasks completed before completion_deadline vs total completed with a deadline
        with_deadline = base_q.filter(Task.completion_deadline.isnot(None)).count()
        on_time = base_q.filter(
            Task.completion_deadline.isnot(None),
            Task.completed_at <= Task.completion_deadline,
        ).count()
        sla_compliance = round((on_time / with_deadline * 100) if with_deadline > 0 else 100.0, 1)

        # Weekly counts: last 7 days (index 0 = 6 days ago, index 6 = today)
        weekly_counts = []
        for i in range(6, -1, -1):
            day_start = (today_start - timedelta(days=i))
            day_end = day_start + timedelta(days=1)
            count = base_q.filter(Task.completed_at >= day_start, Task.completed_at < day_end).count()
            weekly_counts.append(count)

        return {
            "completed_this_month": completed_this_month,
            "completed_today": completed_today,
            "avg_completion_minutes": avg_completion_minutes,
            "sla_compliance_percent": sla_compliance,
            "weekly_counts": weekly_counts,
        }

    def get_service_type_stats(self) -> list[dict]:
        from app.models.service_type import ServiceType
        rows = (
            self.db.query(
                ServiceType.id,
                ServiceType.name,
                func.count(Task.id).label("total"),
            )
            .join(Task, Task.service_type_id == ServiceType.id, isouter=True)
            .group_by(ServiceType.id, ServiceType.name)
            .all()
        )
        return [{"service_type_id": r.id, "name": r.name, "total_tasks": r.total} for r in rows]
