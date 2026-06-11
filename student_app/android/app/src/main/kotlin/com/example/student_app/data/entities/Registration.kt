package com.example.student_app.data.entities

import androidx.room.Entity

@Entity(tableName = "registrations", primaryKeys = ["studentId", "unitCode"])
data class Registration(
    val studentId: String,
    val unitCode: String
)
