package com.example.student_app.ui.login

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.student_app.data.AppDatabase
import com.example.student_app.data.MockDataProvider
import com.example.student_app.databinding.ActivityLoginBinding
import com.example.student_app.ui.dashboard.DashboardActivity
import kotlinx.coroutines.launch

class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        db = AppDatabase.getDatabase(this)

        // Populate mock data on first run
        lifecycleScope.launch {
            MockDataProvider.populateData(db)
        }

        binding.btnLogin.setOnClickListener {
            val studentId = binding.etStudentId.text.toString()
            val password = binding.etPassword.text.toString()

            if (studentId.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            lifecycleScope.launch {
                val student = db.studentDao().login(studentId, password)
                if (student != null) {
                    val intent = Intent(this@LoginActivity, DashboardActivity::class.java)
                    intent.putExtra("STUDENT_ID", student.studentId)
                    startActivity(intent)
                    finish()
                } else {
                    Toast.makeText(this@LoginActivity, "Invalid Credentials", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
}
