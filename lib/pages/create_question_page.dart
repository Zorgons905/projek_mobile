import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test123/services/answer_service.dart';
import 'package:test123/services/question_service.dart';
import 'package:test123/services/quiz_service.dart';
import 'package:test123/services/storage_service.dart';

class CreateQuestionPage extends StatefulWidget {
  final int? initialQuestionCount;
  final int? initialAnswerCount;
  final String classroomId;
  final String title;
  final bool isRandomizeQuestion;
  final bool isRandomizeAnswer;

  const CreateQuestionPage({
    Key? key,

    required this.classroomId,
    required this.title,
    required this.isRandomizeQuestion,
    required this.isRandomizeAnswer,
    this.initialQuestionCount,
    this.initialAnswerCount,
  }) : super(key: key);

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final QuestionService questionService = QuestionService();
  final AnswerService answerService = AnswerService();
  final StorageService storageService = StorageService();
  final _quizService = QuizService();

  List<QuestionInput> questions = [];

  @override
  void initState() {
    super.initState();

    final qCount = widget.initialQuestionCount ?? 1;
    final aCount = widget.initialAnswerCount ?? 4;

    questions = List.generate(qCount, (_) => QuestionInput());

    for (final q in questions) {
      q.answers = List.generate(aCount, (_) => AnswerInput());
    }
  }

  Future<void> _pickAndUploadImage(int questionIndex, String questionId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();

      final path =
          'quiz-pictures/$questionId-${DateTime.now().millisecondsSinceEpoch}.png';

      final imageUrl = await storageService.uploadBytes(
        bytes: bytes,
        bucket: 'quiz-pictures',
        path: path,
      );

      if (imageUrl != null) {
        await questionService.updateQuestion(
          id: questionId,
          pictureUrl: imageUrl,
        );
        setState(() {
          questions[questionIndex].pictureUrl = imageUrl;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload gambar gagal')));
      }
    }
  }

  Future<void> _saveQuiz() async {
    // Validasi isi quiz
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];

      if (q.contentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pertanyaan #${i + 1} tidak boleh kosong')),
        );
        return;
      }

      if (q.answers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pertanyaan #${i + 1} harus memiliki jawaban'),
          ),
        );
        return;
      }

      for (int j = 0; j < q.answers.length; j++) {
        if (q.answers[j].contentController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Jawaban ${String.fromCharCode(65 + j)} di Pertanyaan #${i + 1} tidak boleh kosong',
              ),
            ),
          );
          return;
        }
      }

      // Opsional: Pastikan minimal satu jawaban benar
      if (!q.answers.any((a) => a.isCorrect)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pertanyaan #${i + 1} harus memiliki minimal satu jawaban benar',
            ),
          ),
        );
        return;
      }
    }

    try {
      final quiz = await _quizService.createQuiz(
        classroomId: widget.classroomId,
        title: widget.title,
        isRandomizeQuestion: widget.isRandomizeQuestion,
        isRandomizeAnswer: widget.isRandomizeAnswer,
      );

      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        final createdQuestion = await questionService.createQuestion(
          quizId: quiz.id,
          content: q.contentController.text.trim(),
          orderNumber: i + 1,
        );

        q.questionId = createdQuestion.id;

        if (q.pendingImageFile != null) {
          final bytes = await q.pendingImageFile!.readAsBytes();
          final path =
              'quiz-pictures/${createdQuestion.id}-${DateTime.now().millisecondsSinceEpoch}.png';

          final imageUrl = await storageService.uploadBytes(
            bytes: bytes,
            bucket: 'quiz-pictures',
            path: path,
          );

          if (imageUrl != null) {
            await questionService.updateQuestion(
              id: createdQuestion.id,
              pictureUrl: imageUrl,
            );
            q.pictureUrl = imageUrl;
          }
        }

        for (final answer in q.answers) {
          await answerService.createAnswer(
            questionId: createdQuestion.id,
            content: answer.contentController.text.trim(),
            isCorrect: answer.isCorrect,
          );
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quiz berhasil dibuat')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildAnswerInput(AnswerInput answer, int index, int questionIndex) {
    final label = String.fromCharCode(65 + index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label. ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: answer.contentController,
              decoration: InputDecoration(hintText: 'Jawaban $label'),
            ),
          ),
          Checkbox(
            value: answer.isCorrect,
            onChanged: (val) {
              setState(() {
                // Jika mau hanya 1 jawaban benar, bisa implementasi di sini
                // Untuk sekarang biarkan multiple benar
                answer.isCorrect = val ?? false;
              });
            },
          ),
          Text('Benar'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Quiz Questions')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: question.contentController,
                    decoration: InputDecoration(
                      labelText: 'Pertanyaan #${index + 1}',
                    ),
                  ),
                  SizedBox(height: 8),
                  if (question.pictureUrl != null)
                    question.pictureUrl!.startsWith('http')
                        ? Image.network(question.pictureUrl!, height: 150)
                        : Image.file(File(question.pictureUrl!), height: 150),
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text('Upload Gambar'),
                    onPressed: () async {
                      if (question.questionId != null) {
                        await _pickAndUploadImage(index, question.questionId!);
                      } else {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            question.pendingImageFile = File(pickedFile.path);
                            question.pictureUrl = pickedFile.path;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 12),

                  Text(
                    'Jawaban:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(
                    question.answers.length,
                    (answerIndex) => _buildAnswerInput(
                      question.answers[answerIndex],
                      answerIndex,
                      index,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (question.answers.length > 1)
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              question.answers.removeLast();
                            });
                          },
                          tooltip: 'Kurangi jawaban',
                        ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            question.answers.add(AnswerInput());
                          });
                        },
                        tooltip: 'Tambah jawaban',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (questions.length > 1)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              questions.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.delete),
                          label: Text('Hapus Pertanyaan'),
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            questions.add(QuestionInput());
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text('Tambah Pertanyaan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveQuiz,
      ),
    );
  }
}

class QuestionInput {
  String? questionId;
  TextEditingController contentController = TextEditingController();
  List<AnswerInput> answers = [
    AnswerInput(),
    AnswerInput(),
    AnswerInput(),
    AnswerInput(),
  ];
  File? pendingImageFile;
  String? pictureUrl;

  QuestionInput();
}

class AnswerInput {
  TextEditingController contentController = TextEditingController();
  bool isCorrect = false;

  AnswerInput();
}
