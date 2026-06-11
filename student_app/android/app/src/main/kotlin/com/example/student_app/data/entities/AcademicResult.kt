package com.example.student_app.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "results")
data class AcademicResult(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val studentId: String,
    val unitCode: String,
    val marks: Int,
    val grade: String,
    val semester: Int,
    val academicYear: String
)
