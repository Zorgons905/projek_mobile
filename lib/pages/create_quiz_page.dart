import 'package:flutter/material.dart';
import 'package:test123/models/classroom.dart';
import 'create_question_page.dart';
import '../services/classroom_service.dart';

class CreateQuizPage extends StatefulWidget {
  final String lecturerId;
  const CreateQuizPage({Key? key, required this.lecturerId}) : super(key: key);

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _classroomService = ClassroomService();
  String? _selectedClassroomId;
  final _titleController = TextEditingController();

  final _questionCountController = TextEditingController();
  final _answerCountController = TextEditingController();

  bool _isRandomizeQuestion = false;
  bool _isRandomizeAnswer = false;

  List<Classroom> _classrooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassrooms();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _questionCountController.dispose();
    _answerCountController.dispose();
    super.dispose();
  }

  Future<void> _fetchClassrooms() async {
    final classrooms = await _classroomService.getClassroomsByLecturer(
      widget.lecturerId,
    );
    setState(() {
      _classrooms = classrooms;
      _loading = false;
    });
  }

  void _submit() async {
    if (_selectedClassroomId == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select classroom and enter quiz title')),
      );
      return;
    }

    int? questionCount = int.tryParse(_questionCountController.text);
    int? answerCount = int.tryParse(_answerCountController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => CreateQuestionPage(
              initialQuestionCount: questionCount,
              initialAnswerCount: answerCount,
              classroomId: _selectedClassroomId!,
              title: _titleController.text,
              isRandomizeQuestion: _isRandomizeQuestion,
              isRandomizeAnswer: _isRandomizeAnswer,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Quiz')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Classroom',
                      ),
                      items:
                          _classrooms
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      value: _selectedClassroomId,
                      onChanged:
                          (val) => setState(() => _selectedClassroomId = val),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Quiz Title'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _questionCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Initial Question Count (optional)',
                        hintText: 'Number of questions to create automatically',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _answerCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            'Initial Answer Count per Question (optional)',
                        hintText: 'Number of answers per question',
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Randomize Questions'),
                      value: _isRandomizeQuestion,
                      onChanged:
                          (val) => setState(() => _isRandomizeQuestion = val),
                    ),
                    SwitchListTile(
                      title: Text('Randomize Answers'),
                      value: _isRandomizeAnswer,
                      onChanged:
                          (val) => setState(() => _isRandomizeAnswer = val),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Next: Add Questions'),
                    ),
                  ],
                ),
              ),
    );
  }
}
