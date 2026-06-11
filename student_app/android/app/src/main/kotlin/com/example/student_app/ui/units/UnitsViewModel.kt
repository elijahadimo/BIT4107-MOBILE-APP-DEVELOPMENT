package com.example.student_app.ui.units

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.CourseUnit

class UnitsViewModel(private val repository: StudentRepository) : ViewModel() {
    val unitsOnOffer: LiveData<List<CourseUnit>> = repository.getUnitsOnOffer()
}
