package com.example.student_app.ui.notifications

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityNotificationsBinding
import com.example.student_app.ui.ViewModelFactory

class NotificationsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityNotificationsBinding
    private lateinit var viewModel: NotificationsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNotificationsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[NotificationsViewModel::class.java]

        setupRecyclerView()
    }

    private fun setupRecyclerView() {
        binding.rvNotifications.layoutManager = LinearLayoutManager(this)
        viewModel.notifications.observe(this) { notifications ->
            binding.rvNotifications.adapter = NotificationsAdapter(notifications)
        }
    }
}
