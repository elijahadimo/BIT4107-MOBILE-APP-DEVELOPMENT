package com.example.student_app.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.student_app.data.dao.StudentDao
import com.example.student_app.data.entities.AcademicResult
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.data.entities.FeeTransaction
import com.example.student_app.data.entities.Student
import com.example.student_app.data.entities.TimetableEntry

import com.example.student_app.data.entities.Registration
import com.example.student_app.data.entities.Notification

@Database(
    entities = [
        Student::class,
        CourseUnit::class,
        AcademicResult::class,
        FeeTransaction::class,
        TimetableEntry::class,
        Registration::class,
        Notification::class
    ],
    version = 3,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun studentDao(): StudentDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "student_portal_db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
