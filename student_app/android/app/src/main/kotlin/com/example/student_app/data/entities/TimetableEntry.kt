package com.example.student_app.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "timetable")
data class TimetableEntry(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val unitCode: String,
    val unitName: String,
    val dayOfWeek: String, // Monday, Tuesday, etc.
    val startTime: String, // e.g., "08:00 AM"
    val endTime: String,   // e.g., "10:00 AM"
    val room: String
)
