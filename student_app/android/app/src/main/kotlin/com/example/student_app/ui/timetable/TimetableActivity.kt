package com.example.student_app.ui.timetable

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityTimetableBinding
import com.example.student_app.ui.ViewModelFactory

class TimetableActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTimetableBinding
    private lateinit var viewModel: TimetableViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTimetableBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[TimetableViewModel::class.java]

        setupRecyclerView()
    }

    private fun setupRecyclerView() {
        binding.rvTimetable.layoutManager = LinearLayoutManager(this)
        viewModel.getTimetable().observe(this) { timetable ->
            binding.rvTimetable.adapter = TimetableAdapter(timetable)
        }
    }
}
