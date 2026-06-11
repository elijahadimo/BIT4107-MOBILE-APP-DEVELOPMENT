package com.example.student_app.ui.fees

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.StudentRepository
import com.example.student_app.databinding.ActivityCheckFeesBinding
import com.example.student_app.ui.ViewModelFactory

class FeesActivity : AppCompatActivity() {

    private lateinit var binding: ActivityCheckFeesBinding
    private lateinit var viewModel: FeesViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckFeesBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val studentId = intent.getStringExtra("STUDENT_ID") ?: ""

        val database = AppDatabase.getDatabase(this)
        val repository = StudentRepository(database.studentDao())
        val factory = ViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[FeesViewModel::class.java]

        setupUI(studentId)
    }

    private fun setupUI(studentId: String) {
        binding.rvTransactions.layoutManager = LinearLayoutManager(this)
        
        viewModel.getFeeTransactions(studentId).observe(this) { transactions ->
            binding.rvTransactions.adapter = FeesAdapter(transactions)
            
            val invoiced = transactions.filter { it.type == "DEBIT" }.sumOf { it.amount }
            val paid = transactions.filter { it.type == "CREDIT" }.sumOf { it.amount }
            val balance = invoiced - paid
            
            binding.tvInvoiced.text = "$${String.format("%.2f", invoiced)}"
            binding.tvPaid.text = "$${String.format("%.2f", paid)}"
            binding.tvBalance.text = "$${String.format("%.2f", balance)}"
        }
    }
}
