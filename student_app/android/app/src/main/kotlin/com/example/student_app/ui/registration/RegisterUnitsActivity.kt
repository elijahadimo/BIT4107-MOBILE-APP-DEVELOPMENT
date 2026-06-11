package com.example.student_app.ui.registration

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityRegisterUnitsBinding
import com.example.student_app.ui.ViewModelFactory

class RegisterUnitsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityRegisterUnitsBinding
    private lateinit var viewModel: RegisterUnitsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityRegisterUnitsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val studentId = intent.getStringExtra("STUDENT_ID") ?: ""

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[RegisterUnitsViewModel::class.java]

        viewModel.loadCurrentRegistrations(studentId)
        setupRecyclerView()

        binding.btnSubmit.setOnClickListener {
            viewModel.submitRegistration(studentId)
        }

        viewModel.registrationSuccess.observe(this) { success ->
            if (success) {
                Toast.makeText(this, "Units Registered Successfully", Toast.LENGTH_SHORT).show()
                finish()
            }
        }
    }

    private fun setupRecyclerView() {
        binding.rvRegisterUnits.layoutManager = LinearLayoutManager(this)
        viewModel.availableUnits.observe(this) { units ->
            val adapter = RegisterUnitsAdapter(units, viewModel.getCurrentSelection()) { code, isSelected ->
                viewModel.toggleSelection(code, isSelected)
            }
            binding.rvRegisterUnits.adapter = adapter
        }
    }
}
