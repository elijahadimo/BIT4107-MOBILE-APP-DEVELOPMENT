package com.example.student_app.ui.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.Student
import kotlinx.coroutines.launch

class LoginViewModel(private val repository: StudentRepository) : ViewModel() {

    private val _loginResult = MutableLiveData<Student?>()
    val loginResult: LiveData<Student?> = _loginResult

    fun login(id: String, pass: String) {
        viewModelScope.launch {
            val student = repository.login(id, pass)
            _loginResult.postValue(student)
        }
    }
}
