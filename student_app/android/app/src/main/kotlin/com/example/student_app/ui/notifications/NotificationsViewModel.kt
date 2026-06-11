package com.example.student_app.ui.notifications

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.Notification

class NotificationsViewModel(private val repository: StudentRepository) : ViewModel() {
    val notifications: LiveData<List<Notification>> = repository.getNotifications()
}
