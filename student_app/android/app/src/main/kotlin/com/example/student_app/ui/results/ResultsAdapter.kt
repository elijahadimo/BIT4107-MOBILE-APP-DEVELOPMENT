package com.example.student_app.ui.results

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.AcademicResult
import com.example.student_app.databinding.ItemResultBinding

class ResultsAdapter(private val results: List<AcademicResult>) :
    RecyclerView.Adapter<ResultsAdapter.ViewHolder>() {

    inner class ViewHolder(private val binding: ItemResultBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(result: AcademicResult) {
            binding.tvUnitCode.text = result.unitCode
            binding.tvMarks.text = "Marks: ${result.marks}"
            binding.tvGrade.text = "Grade: ${result.grade}"
            binding.tvSemester.text = "Sem ${result.semester}, ${result.academicYear}"
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemResultBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(results[position])
    }

    override fun getItemCount() = results.size
}
