package com.example.student_app.ui.dashboard

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import com.example.student_app.databinding.ActivityDashboardBinding
import com.example.student_app.ui.results.ResultsActivity
import com.example.student_app.ui.units.UnitsActivity
import com.example.student_app.ui.fees.FeesActivity
import com.example.student_app.ui.timetable.TimetableActivity
import com.example.student_app.ui.registration.RegisterUnitsActivity
import com.example.student_app.ui.notifications.NotificationsActivity

class DashboardActivity : AppCompatActivity() {

    private lateinit var binding: ActivityDashboardBinding
    private var studentId: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityDashboardBinding.inflate(layoutInflater)
        setContentView(binding.root)

        studentId = intent.getStringExtra("STUDENT_ID") ?: ""

        setupDashboard()
    }

    private fun setupDashboard() {
        val items = listOf(
            DashboardItem("Register Units", android.R.drawable.ic_menu_edit, DashboardType.REGISTER_UNITS),
            DashboardItem("Registered Units", android.R.drawable.ic_menu_view, DashboardType.VIEW_REGISTERED),
            DashboardItem("View Results", android.R.drawable.ic_menu_sort_by_size, DashboardType.VIEW_RESULTS),
            DashboardItem("Check Fees", android.R.drawable.ic_menu_month, DashboardType.CHECK_FEES),
            DashboardItem("Notifications", android.R.drawable.ic_popup_reminder, DashboardType.NOTIFICATIONS),
            DashboardItem("Units on Offer", android.R.drawable.ic_menu_search, DashboardType.UNITS_OFFER),
            DashboardItem("Timetable", android.R.drawable.ic_menu_my_calendar, DashboardType.TIMETABLE),
            DashboardItem("Past History", android.R.drawable.ic_menu_recent_history, DashboardType.HISTORY)
        )

        val adapter = DashboardAdapter(items) { item ->
            handleItemClick(item)
        }

        binding.rvDashboard.layoutManager = GridLayoutManager(this, 2)
        binding.rvDashboard.adapter = adapter
    }

    private fun handleItemClick(item: DashboardItem) {
        when (item.type) {
            DashboardType.UNITS_OFFER -> {
                startActivity(Intent(this, UnitsActivity::class.java))
            }
            DashboardType.VIEW_RESULTS -> {
                val intent = Intent(this, ResultsActivity::class.java)
                intent.putExtra("STUDENT_ID", studentId)
                startActivity(intent)
            }
            DashboardType.CHECK_FEES -> {
                val intent = Intent(this, FeesActivity::class.java)
                intent.putExtra("STUDENT_ID", studentId)
                startActivity(intent)
            }
            DashboardType.TIMETABLE -> {
                startActivity(Intent(this, TimetableActivity::class.java))
            }
            DashboardType.REGISTER_UNITS -> {
                val intent = Intent(this, RegisterUnitsActivity::class.java)
                intent.putExtra("STUDENT_ID", studentId)
                startActivity(intent)
            }
            DashboardType.NOTIFICATIONS -> {
                startActivity(Intent(this, NotificationsActivity::class.java))
            }
            else -> {
                Toast.makeText(this, "Clicked: ${item.title}", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
