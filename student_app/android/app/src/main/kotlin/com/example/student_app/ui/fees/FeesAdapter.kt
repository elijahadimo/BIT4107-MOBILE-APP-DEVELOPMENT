package com.example.student_app.ui.fees

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.FeeTransaction
import com.example.student_app.databinding.ItemTransactionBinding
import java.text.SimpleDateFormat
import java.util.*

class FeesAdapter(private val transactions: List<FeeTransaction>) :
    RecyclerView.Adapter<FeesAdapter.ViewHolder>() {

    private val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())

    inner class ViewHolder(private val binding: ItemTransactionBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(tx: FeeTransaction) {
            binding.tvDescription.text = tx.description
            binding.tvDate.text = dateFormat.format(Date(tx.date))
            
            if (tx.type == "DEBIT") {
                binding.tvAmount.text = "-$${String.format("%.2f", tx.amount)}"
                binding.tvAmount.setTextColor(Color.RED)
            } else {
                binding.tvAmount.text = "+$${String.format("%.2f", tx.amount)}"
                binding.tvAmount.setTextColor(Color.parseColor("#4CAF50"))
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemTransactionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(transactions[position])
    }

    override fun getItemCount() = transactions.size
}
