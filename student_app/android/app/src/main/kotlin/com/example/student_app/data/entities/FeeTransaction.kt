package com.example.student_app.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "fee_transactions")
data class FeeTransaction(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val studentId: String,
    val description: String,
    val amount: Double,
    val date: Long,
    val type: String // "DEBIT" or "CREDIT"
)
