package com.example.student_app.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "units")
data class CourseUnit(
    @PrimaryKey val unitCode: String,
    val unitName: String,
    val creditHours: Int,
    val semester: Int, // 1 or 2
    val academicYear: String, // e.g., "2023/2024"
    val isOnOffer: Boolean = true
)
