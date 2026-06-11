package com.example.student_app.ui.timetable

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.TimetableEntry
import com.example.student_app.databinding.ItemTimetableBinding

class TimetableAdapter(private val entries: List<TimetableEntry>) :
    RecyclerView.Adapter<TimetableAdapter.ViewHolder>() {

    inner class ViewHolder(private val binding: ItemTimetableBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(entry: TimetableEntry) {
            binding.tvDay.text = entry.dayOfWeek
            binding.tvTime.text = "${entry.startTime} - ${entry.endTime}"
            binding.tvUnitName.text = entry.unitName
            binding.tvRoom.text = entry.room
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemTimetableBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(entries[position])
    }

    override fun getItemCount() = entries.size
}
