package com.example.student_app.ui.registration

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.student_app.data.StudentRepository
import com.example.student_app.data.entities.CourseUnit
import com.example.student_app.data.entities.Registration
import kotlinx.coroutines.launch

class RegisterUnitsViewModel(private val repository: StudentRepository) : ViewModel() {

    val availableUnits: LiveData<List<CourseUnit>> = repository.getUnitsOnOffer()
    
    private val _registrationSuccess = MutableLiveData<Boolean>()
    val registrationSuccess: LiveData<Boolean> = _registrationSuccess

    private val selectedUnitCodes = mutableSetOf<String>()

    fun loadCurrentRegistrations(studentId: String) {
        viewModelScope.launch {
            val current = repository.getRegistrations(studentId)
            selectedUnitCodes.clear()
            selectedUnitCodes.addAll(current.map { it.unitCode })
        }
    }

    fun toggleSelection(unitCode: String, isSelected: Boolean) {
        if (isSelected) selectedUnitCodes.add(unitCode)
        else selectedUnitCodes.remove(unitCode)
    }

    fun submitRegistration(studentId: String) {
        viewModelScope.launch {
            repository.clearRegistrations(studentId)
            val registrations = selectedUnitCodes.map { Registration(studentId, it) }
            repository.registerUnits(registrations)
            _registrationSuccess.postValue(true)
        }
    }

    fun getCurrentSelection(): Set<String> = selectedUnitCodes
}
