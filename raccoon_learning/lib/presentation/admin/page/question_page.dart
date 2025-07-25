import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/admin/data/question/question_modle.dart';
import 'package:raccoon_learning/presentation/admin/data/question/question_repository.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String? _selectedGrade = 'Grade 1'; // Default grade for adding questions
  String? _selectedVariables = 'A'; // Default number of variables
  final TextEditingController _questionController = TextEditingController(); // Controller for question input
  final TextEditingController _answer = TextEditingController(); // Controller for answer input
  final QuestionRepository _questionRepository = QuestionRepository(); // Repository instance
  bool _isLoading = false; // Loading state for UI feedback
  List<QuestionModle> _questions = []; // List to store fetched questions
  String _displayGrade = 'Grade 1'; // Grade to filter displayed questions

  @override
  void initState() {
    super.initState();
    _loadQuestions(_displayGrade); // Load questions on initialization
  }

  @override
  void dispose() {
    _questionController.dispose(); // Clean up question controller
    _answer.dispose(); // Clean up answer controller
    super.dispose();
  }

  // Load questions for a specific grade
  Future<void> _loadQuestions(String grade) async {
    setState(() => _isLoading = true);
    try {
      final questions = await _questionRepository.getQuestionsByGrade(grade);
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Submit a new question to Firestore
  Future<void> _submitQuestion() async {
    if (_questionController.text.isEmpty || _answer.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final question = QuestionModle(
        '', // ID will be generated by Firestore
        _selectedGrade ?? 'Grade 1',
        _questionController.text,
        _answer.text,
      );

      await _questionRepository.uploadQuestionToFirebase(question);

      // Clear fields after successful submission
      _questionController.clear();
      _answer.clear();
      setState(() {
        _selectedGrade = 'Grade 1';
        _selectedVariables = 'A';
      });

      await _loadQuestions(_displayGrade); // Refresh question list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting question: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show a dialog to edit an existing question
  void _showEditDialog(QuestionModle question) {
    final questionController = TextEditingController(text: question.question);
    final answerController = TextEditingController(text: question.answer);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Edit Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedQuestion = QuestionModle(
                question.id,
                question.grade,
                questionController.text,
                answerController.text,
              );
              await _questionRepository.updateQuestion(updatedQuestion);
              await _loadQuestions(_displayGrade); // Refresh list
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Delete a question and refresh the list
  Future<void> _deleteQuestion(QuestionModle question) async {
    try {
      await _questionRepository.deleteQuestion(question);
      await _loadQuestions(_displayGrade); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting question: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for the page
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Question Section
                  const Text(
                    'Add Question',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grade Dropdown
                        const Text(
                          'Select Grade',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton2<String>(
                          value: _selectedGrade,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGrade = value;
                            });
                          },
                          items: ['Grade 1', 'Grade 2', 'Grade 3']
                              .map((grade) => DropdownMenuItem<String>(
                                    value: grade,
                                    child: Text(grade),
                                  ))
                              .toList(),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xFFF5F7FA),
                            ),
                            elevation: 8,
                            offset: const Offset(0, -5),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey),
                              color: const Color(0xFFF5F7FA),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            iconSize: 24,
                          ),
                          underline: const SizedBox(),
                        ),
                        const SizedBox(height: 20),
                        // Variables Dropdown
                        const Text(
                          'Select Number of Variables',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton2<String>(
                          value: _selectedVariables,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedVariables = value;
                            });
                          },
                          items: ['A', 'AB', 'ABC', 'ABCD']
                              .map((vars) => DropdownMenuItem<String>(
                                    value: vars,
                                    child: Text(vars),
                                  ))
                              .toList(),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xFFF5F7FA),
                            ),
                            elevation: 8,
                            offset: const Offset(0, -5),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey),
                              color: const Color(0xFFF5F7FA),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            iconSize: 24,
                          ),
                          underline: const SizedBox(),
                        ),
                        const SizedBox(height: 20),
                        // Question Text Field
                        const Text(
                          'Question',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _questionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Example: If Ann has A apples, but Ann eats B apples. How many apples does Ann have?',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Answer Text Field
                        const Text(
                          'Answer',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _answer,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Example: A-B',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Submit Button with loading state
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Question List Section
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Question List',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Dropdown to filter questions by grade
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: DropdownButton2<String>(
                                value: _displayGrade,
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFFF5F7FA),
                                  ),
                                  elevation: 8,
                                  offset: const Offset(0, -5),
                                ),
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFFF5F7FA),
                                  ),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  iconSize: 24,
                                ),
                                underline: const SizedBox(),
                                items: ['Grade 1', 'Grade 2', 'Grade 3']
                                    .map((grade) => DropdownMenuItem<String>(
                                          value: grade,
                                          child: Text(grade),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _displayGrade = value!);
                                  _loadQuestions(value!); // Reload questions when grade changes
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                            : _questions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No questions available for this grade.',
                                      style: TextStyle(color: Colors.grey, fontSize: 16),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _questions.length,
                                    itemBuilder: (context, index) {
                                      final question = _questions[index];
                                      return Card(
                                        color: AppColors.lightBackground,
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(10),
                                          title: SelectableText(
                                            question.question,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: SelectableText(
                                            'Answer: ${question.answer}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Edit button with consistent color
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                                                onPressed: () => _showEditDialog(question),
                                              ),
                                              // Delete button with red color for clarity
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _deleteQuestion(question),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}