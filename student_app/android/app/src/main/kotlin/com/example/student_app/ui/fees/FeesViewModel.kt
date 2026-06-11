package com.example.student_app.ui.fees

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.FeeTransaction

class FeesViewModel(private val repository: StudentRepository) : ViewModel() {
    fun getFeeTransactions(studentId: String): LiveData<List<FeeTransaction>> = 
        repository.getFeeTransactions(studentId)
}
