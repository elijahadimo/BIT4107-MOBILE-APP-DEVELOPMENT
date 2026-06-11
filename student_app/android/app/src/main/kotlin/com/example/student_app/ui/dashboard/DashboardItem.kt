package com.example.student_app.ui.dashboard

data class DashboardItem(
    val title: String,
    val iconResId: Int,
    val type: DashboardType
)

enum class DashboardType {
    REGISTER_UNITS,
    VIEW_REGISTERED,
    VIEW_RESULTS,
    CHECK_FEES,
    NOTIFICATIONS,
    UNITS_OFFER,
    TIMETABLE,
    HISTORY
}
