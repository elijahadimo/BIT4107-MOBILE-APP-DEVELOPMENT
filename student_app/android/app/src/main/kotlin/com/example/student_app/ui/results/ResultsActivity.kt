package com.example.student_app.ui.results

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityViewResultsBinding
import com.example.student_app.ui.ViewModelFactory

class ResultsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityViewResultsBinding
    private lateinit var viewModel: ResultsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityViewResultsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val studentId = intent.getStringExtra("STUDENT_ID") ?: ""

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[ResultsViewModel::class.java]

        setupRecyclerView(studentId)
    }

    private fun setupRecyclerView(studentId: String) {
        binding.rvResults.layoutManager = LinearLayoutManager(this)
        viewModel.getResults(studentId).observe(this) { results ->
            binding.rvResults.adapter = ResultsAdapter(results)
        }
    }
}
