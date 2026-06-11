package com.example.student_app.ui.timetable

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.TimetableEntry

class TimetableViewModel(private val repository: StudentRepository) : ViewModel() {
    fun getTimetable(): LiveData<List<TimetableEntry>> = repository.getTimetable()
}
