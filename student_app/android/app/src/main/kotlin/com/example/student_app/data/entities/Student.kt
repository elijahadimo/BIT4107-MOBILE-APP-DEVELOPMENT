package com.example.student_app.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "students")
data class Student(
    @PrimaryKey val studentId: String,
    val name: String,
    val password: String,
    val email: String
)
