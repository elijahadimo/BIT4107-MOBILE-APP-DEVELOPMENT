package com.example.student_app.ui.units

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityUnitsOnOfferBinding
import com.example.student_app.ui.ViewModelFactory

class UnitsActivity : AppCompatActivity() {

    private lateinit var binding: ActivityUnitsOnOfferBinding
    private lateinit var viewModel: UnitsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityUnitsOnOfferBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[UnitsViewModel::class.java]

        setupRecyclerView()
    }

    private fun setupRecyclerView() {
        binding.rvUnits.layoutManager = LinearLayoutManager(this)
        viewModel.unitsOnOffer.observe(this) { units ->
            binding.rvUnits.adapter = UnitsAdapter(units)
        }
    }
}
