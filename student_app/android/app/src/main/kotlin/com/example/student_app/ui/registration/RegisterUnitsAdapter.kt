package com.example.student_app.ui.registration

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.databinding.ItemRegisterUnitBinding

class RegisterUnitsAdapter(
    private val units: List<CourseUnit>,
    private val initialSelected: Set<String>,
    private val onSelectionChanged: (String, Boolean) -> Unit
) : RecyclerView.Adapter<RegisterUnitsAdapter.ViewHolder>() {

    private val selectedUnits = initialSelected.toMutableSet()

    inner class ViewHolder(private val binding: ItemRegisterUnitBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(unit: CourseUnit) {
            binding.tvUnitCode.text = unit.unitCode
            binding.tvUnitName.text = unit.unitName
            binding.cbRegister.setOnCheckedChangeListener(null)
            binding.cbRegister.isChecked = selectedUnits.contains(unit.unitCode)
            
            binding.cbRegister.setOnCheckedChangeListener { _, isChecked ->
                if (isChecked) selectedUnits.add(unit.unitCode)
                else selectedUnits.remove(unit.unitCode)
                onSelectionChanged(unit.unitCode, isChecked)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemRegisterUnitBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(units[position])
    }

    override fun getItemCount() = units.size
}
