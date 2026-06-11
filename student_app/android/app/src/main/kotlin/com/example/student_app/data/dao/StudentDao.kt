package com.example.student_app.data.dao

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.student_app.data.entities.*

@Dao
interface StudentDao {
    @Query("SELECT * FROM students WHERE studentId = :id AND password = :pass LIMIT 1")
    suspend fun login(id: String, pass: String): Student?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertStudent(student: Student)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUnits(units: List<CourseUnit>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertResults(results: List<AcademicResult>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTransactions(transactions: List<FeeTransaction>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTimetable(timetable: List<TimetableEntry>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNotifications(notifications: List<Notification>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun registerUnits(registrations: List<Registration>)

    @Query("DELETE FROM registrations WHERE studentId = :studentId")
    suspend fun clearRegistrations(studentId: String)

    @Query("SELECT * FROM units WHERE isOnOffer = 1")
    fun getUnitsOnOffer(): LiveData<List<CourseUnit>>

    @Query("SELECT units.* FROM units INNER JOIN registrations ON units.unitCode = registrations.unitCode WHERE registrations.studentId = :studentId")
    fun getRegisteredUnits(studentId: String): LiveData<List<CourseUnit>>

    @Query("SELECT * FROM registrations WHERE studentId = :studentId")
    suspend fun getRegistrations(studentId: String): List<Registration>

    @Query("SELECT * FROM results WHERE studentId = :studentId")
    fun getResults(studentId: String): LiveData<List<AcademicResult>>

    @Query("SELECT * FROM fee_transactions WHERE studentId = :studentId ORDER BY date DESC")
    fun getFeeTransactions(studentId: String): LiveData<List<FeeTransaction>>

    @Query("SELECT * FROM timetable ORDER BY CASE WHEN dayOfWeek = 'Monday' THEN 1 WHEN dayOfWeek = 'Tuesday' THEN 2 WHEN dayOfWeek = 'Wednesday' THEN 3 WHEN dayOfWeek = 'Thursday' THEN 4 WHEN dayOfWeek = 'Friday' THEN 5 ELSE 6 END, startTime")
    fun getTimetable(): LiveData<List<TimetableEntry>>

    @Query("SELECT * FROM notifications ORDER BY timestamp DESC")
    fun getNotifications(): LiveData<List<Notification>>
}
