package com.example.student_app.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.student_app.data.StudentRepository
import com.example.student_app.ui.login.LoginViewModel
import com.example.student_app.ui.units.UnitsViewModel
import com.example.student_app.ui.results.ResultsViewModel
import com.example.student_app.ui.fees.FeesViewModel
import com.example.student_app.ui.timetable.TimetableViewModel
import com.example.student_app.ui.registration.RegisterUnitsViewModel
import com.example.student_app.ui.notifications.NotificationsViewModel

class ViewModelFactory(private val repository: StudentRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return when {
            modelClass.isAssignableFrom(LoginViewModel::class.java) -> LoginViewModel(repository) as T
            modelClass.isAssignableFrom(UnitsViewModel::class.java) -> UnitsViewModel(repository) as T
            modelClass.isAssignableFrom(ResultsViewModel::class.java) -> ResultsViewModel(repository) as T
            modelClass.isAssignableFrom(FeesViewModel::class.java) -> FeesViewModel(repository) as T
            modelClass.isAssignableFrom(TimetableViewModel::class.java) -> TimetableViewModel(repository) as T
            modelClass.isAssignableFrom(RegisterUnitsViewModel::class.java) -> RegisterUnitsViewModel(repository) as T
            modelClass.isAssignableFrom(NotificationsViewModel::class.java) -> NotificationsViewModel(repository) as T
            else -> throw IllegalArgumentException("Unknown ViewModel class")
        }
    }
}
