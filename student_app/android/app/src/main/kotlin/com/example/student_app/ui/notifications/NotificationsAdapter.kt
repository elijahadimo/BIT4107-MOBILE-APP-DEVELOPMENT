package com.example.student_app.ui.notifications

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.student_app.data.entities.Notification
import com.example.student_app.databinding.ItemNotificationBinding
import java.text.SimpleDateFormat
import java.util.*

class NotificationsAdapter(private val notifications: List<Notification>) :
    RecyclerView.Adapter<NotificationsAdapter.ViewHolder>() {

    private val dateFormat = SimpleDateFormat("MMM dd, hh:mm a", Locale.getDefault())

    inner class ViewHolder(private val binding: ItemNotificationBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(notification: Notification) {
            binding.tvTitle.text = notification.title
            binding.tvMessage.text = notification.message
            binding.tvTime.text = dateFormat.format(Date(notification.timestamp))
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemNotificationBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(notifications[position])
    }

    override fun getItemCount() = notifications.size
}
