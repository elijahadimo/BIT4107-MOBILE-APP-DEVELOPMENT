package com.example.student_app.data

import androidx.lifecycle.LiveData
import com.example.student_app.data.dao.StudentDao
import com.example.student_app.data.entities.AcademicResult
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.data.entities.FeeTransaction
import com.example.student_app.data.entities.Notification
import com.example.student_app.data.entities.Registration
import com.example.student_app.data.entities.Student
import com.example.student_app.data.entities.TimetableEntry

class StudentRepository(private val studentDao: StudentDao) {

    suspend fun login(id: String, pass: String): Student? = studentDao.login(id, pass)

    fun getUnitsOnOffer(): LiveData<List<CourseUnit>> = studentDao.getUnitsOnOffer()

    fun getResults(studentId: String): LiveData<List<AcademicResult>> = studentDao.getResults(studentId)

    fun getFeeTransactions(studentId: String): LiveData<List<FeeTransaction>> = studentDao.getFeeTransactions(studentId)

    fun getTimetable(): LiveData<List<TimetableEntry>> = studentDao.getTimetable()

    fun getNotifications(): LiveData<List<Notification>> = studentDao.getNotifications()

    suspend fun getRegistrations(studentId: String): List<Registration> = studentDao.getRegistrations(studentId)

    suspend fun registerUnits(registrations: List<Registration>) = studentDao.registerUnits(registrations)

    suspend fun clearRegistrations(studentId: String) = studentDao.clearRegistrations(studentId)

    fun getRegisteredUnits(studentId: String): LiveData<List<CourseUnit>> = studentDao.getRegisteredUnits(studentId)
}
