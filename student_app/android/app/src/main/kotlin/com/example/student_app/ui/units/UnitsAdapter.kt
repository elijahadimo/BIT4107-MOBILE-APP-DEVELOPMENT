package com.example.student_app.ui.units

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.databinding.ItemUnitBinding

class UnitsAdapter(private val units: List<CourseUnit>) :
    RecyclerView.Adapter<UnitsAdapter.ViewHolder>() {

    inner class ViewHolder(private val binding: ItemUnitBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(unit: CourseUnit) {
            binding.tvUnitCode.text = unit.unitCode
            binding.tvUnitName.text = unit.unitName
            binding.tvCreditHours.text = "Credits: ${unit.creditHours}"
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemUnitBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(units[position])
    }

    override fun getItemCount() = units.size
}
