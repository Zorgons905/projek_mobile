import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../services/classroom_service.dart';
import '../services/student_class_service.dart';

class ClassroomProvider extends ChangeNotifier {
  final ClassroomService _classroomService = ClassroomService();
  final StudentClassService _studentClassService = StudentClassService(); // Keep if you use it for student classes

  List<Classroom> _classrooms = [];
  bool _loading = false;
  String? _errorMessage;

  List<Classroom> get classrooms => _classrooms;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  /// Fetches classrooms based on the user's role (lecturer or student).
  ///
  /// For lecturers, it fetches classrooms created by them.
  /// For students, it fetches classrooms they are enrolled in.
  Future<void> fetchClassrooms(String userId, String role) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (role == 'lecturer') {
        _classrooms = await _classroomService.getClassroomsByLecturer(userId);
      } else {
        // For students, first get student_class relations
        final studentClasses = await _studentClassService.getStudentClasses(userId);

        // Then fetch classroom data for each relation
        final fetchedClassrooms = <Classroom>[];
        for (final sc in studentClasses) {
          final classroom = await _classroomService.getClassroom(sc.classroomId);
          if (classroom != null) {
            fetchedClassrooms.add(classroom);
          }
        }
        _classrooms = fetchedClassrooms;
      }
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to load classrooms: $e';
      print('Error fetching classrooms: $e\n$stacktrace'); // For debugging
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Creates a new classroom.
  ///
  /// Adds the new classroom to the local list and notifies listeners.
  Future<Classroom?> createClassroom({
    required String name,
    String? description,
    required String lecturerId,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newClassroom = await _classroomService.createClassroom(
        name: name,
        description: description,
        lecturerId: lecturerId,
      );
      // Only add to the list if the current user is the lecturer who created it
      if (lecturerId == lecturerId) { // This condition assumes `userId` is the current user's ID
        // A more robust check might be needed depending on context
        _classrooms.add(newClassroom);
      }
      return newClassroom;
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to create classroom: $e';
      print('Error creating classroom: $e\n$stacktrace');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Updates an existing classroom.
  ///
  /// Updates the classroom in the local list and notifies listeners.
  Future<Classroom?> updateClassroom({
    required String id,
    String? name,
    String? description,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedClassroom = await _classroomService.updateClassroom(
        id: id,
        name: name,
        description: description,
      );
      // Find and replace the updated classroom in the local list
      final index = _classrooms.indexWhere((c) => c.id == id);
      if (index != -1) {
        _classrooms[index] = updatedClassroom;
      }
      return updatedClassroom;
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to update classroom: $e';
      print('Error updating classroom: $e\n$stacktrace');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Deletes a classroom.
  ///
  /// Removes the classroom from the local list and notifies listeners.
  Future<void> deleteClassroom(String id) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _classroomService.deleteClassroom(id);
      // Remove the classroom from the local list
      _classrooms.removeWhere((c) => c.id == id);
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to delete classroom: $e';
      print('Error deleting classroom: $e\n$stacktrace');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Gets a single classroom by its ID.
  Future<Classroom?> getClassroom(String id) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners(); // Notify to show loading state if desired

    try {
      return await _classroomService.getClassroom(id);
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to get classroom: $e';
      print('Error getting classroom: $e\n$stacktrace');
      return null;
    } finally {
      _loading = false;
      notifyListeners(); // Notify to clear loading state
    }
  }

  /// Gets a single classroom by its code.
  Future<Classroom?> getClassroomByCode(String code) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners(); // Notify to show loading state if desired

    try {
      return await _classroomService.getClassroomByCode(code);
    } catch (e, stacktrace) {
      _errorMessage = 'Failed to get classroom by code: $e';
      print('Error getting classroom by code: $e\n$stacktrace');
      return null;
    } finally {
      _loading = false;
      notifyListeners(); // Notify to clear loading state
    }
  }

// --- No need to expose these directly from the provider for the UI, as fetchClassrooms covers them ---
// If you need direct access to all classrooms or by lecturer for specific UI elements,
// you can consider adding them, but often fetchClassrooms is sufficient for the primary display.

// Future<List<Classroom>> getClassroomsByLecturer(String lecturerId) async {
//   // This logic is already inside fetchClassrooms
//   return await _classroomService.getClassroomsByLecturer(lecturerId);
// }

// Future<List<Classroom>> getAllClassrooms() async {
//   // You might use this if you have an admin view that shows all classrooms
//   // _loading = true;
//   // notifyListeners();
//   // try {
//   //   _classrooms = await _classroomService.getAllClassrooms();
//   //   return _classrooms;
//   // } catch (e) {
//   //   _errorMessage = 'Failed to load all classrooms: $e';
//   //   return [];
//   // } finally {
//   //   _loading = false;
//   //   notifyListeners();
//   // }
//   return await _classroomService.getAllClassrooms();
// }
}