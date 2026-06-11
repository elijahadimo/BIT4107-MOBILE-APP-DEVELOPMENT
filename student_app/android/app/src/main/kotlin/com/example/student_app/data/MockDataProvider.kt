package com.example.student_app.data

import com.example.student_app.data.entities.AcademicResult
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.data.entities.FeeTransaction
import com.example.student_app.data.entities.Notification
import com.example.student_app.data.entities.Registration
import com.example.student_app.data.entities.Student
import com.example.student_app.data.entities.TimetableEntry

object MockDataProvider {

    private const val TEST_STUDENT_ID = "BIT/2024/34555"

    val student = Student(
        studentId = TEST_STUDENT_ID,
        name = "John Doe",
        password = "password",
        email = "john.doe@university.com"
    )

    val unitsOnOffer = listOf(
        CourseUnit("BIT4101", "Mobile App Development", 3, 1, "2024/2025"),
        CourseUnit("BIT3204", "Human Computer interaction", 3, 1, "2024/2025"),
        CourseUnit("BIT2102", "Internet Programming", 3, 1, "2024/2025"),
        CourseUnit("BIT3302", "Data Communication & Networks", 3, 1, "2024/2025"),
        CourseUnit("BMA2122", "Probability and Statistics II", 3, 1, "2024/2025")
    )

    val pastResults = listOf(
        AcademicResult(studentId = TEST_STUDENT_ID, unitCode = "BIT1101", marks = 75, grade = "B+", semester = 1, academicYear = "2023/2024"),
        AcademicResult(studentId = TEST_STUDENT_ID, unitCode = "BIT1102", marks = 82, grade = "A", semester = 1, academicYear = "2023/2024")
    )

    val feeTransactions = listOf(
        FeeTransaction(studentId = TEST_STUDENT_ID, description = "Semester 1 Tuition", amount = 1200.0, date = 1725148800000L, type = "DEBIT"),
        FeeTransaction(studentId = TEST_STUDENT_ID, description = "Registration Fee", amount = 100.0, date = 1725235200000L, type = "DEBIT"),
        FeeTransaction(studentId = TEST_STUDENT_ID, description = "Online Payment", amount = 1300.0, date = 1725321600000L, type = "CREDIT")
    )

    val timetable = listOf(
        TimetableEntry(unitCode = "BIT4101", unitName = "Mobile App Development", dayOfWeek = "Monday", startTime = "08:00 AM", endTime = "11:00 AM", room = "Lab 1"),
        TimetableEntry(unitCode = "BIT3204", unitName = "Human Computer interaction", dayOfWeek = "Tuesday", startTime = "02:00 PM", endTime = "05:00 PM", room = "Room 4B"),
        TimetableEntry(unitCode = "BIT2102", unitName = "Internet Programming", dayOfWeek = "Wednesday", startTime = "09:00 AM", endTime = "12:00 PM", room = "Lab 2"),
        TimetableEntry(unitCode = "BIT3302", unitName = "Data Communication & Networks", dayOfWeek = "Thursday", startTime = "11:00 AM", endTime = "01:00 PM", room = "Room 2C"),
        TimetableEntry(unitCode = "BMA2122", unitName = "Probability and Statistics II", dayOfWeek = "Friday", startTime = "08:00 AM", endTime = "10:00 AM", room = "Room 1A")
    )

    val notifications = listOf(
        Notification(title = "Semester Registration Open", message = "Please register your units for the new semester by Friday.", timestamp = System.currentTimeMillis() - 86400000),
        Notification(title = "Fee Payment Reminder", message = "Kindly clear any outstanding balances to avoid penalties.", timestamp = System.currentTimeMillis() - 172800000)
    )

    suspend fun populateData(db: AppDatabase) {
        val dao = db.studentDao()
        // Use a background thread or check if data exists to avoid re-populating on every launch
        // For simplicity in this mock, we just insert. Room's REPLACE handles conflicts.
        dao.insertStudent(student)
        dao.insertUnits(unitsOnOffer)
        dao.insertResults(pastResults)
        dao.insertTransactions(feeTransactions)
        dao.insertTimetable(timetable)
        dao.insertNotifications(notifications)
    }
}
