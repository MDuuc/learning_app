import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/data/firebase/question/question_modle.dart';
import 'package:raccoon_learning/data/firebase/question/question_repository.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String? _selectedGrade = 'Grade 1';
  String? _selectedVariables = 'X';
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answer = TextEditingController();
  final QuestionRepository _questionRepository = QuestionRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answer.dispose();
    super.dispose();
  }

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
        _selectedVariables = 'X';
      });
      
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        items: ['Grade 1', 'Grade 2', 'Grade 3']
                            .map((grade) => DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedGrade = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Variables Dropdown
                      const Text(
                        'Select Number of Variables',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedVariables,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        items: ['X', 'XY', 'XYZ', 'XYZH']
                            .map((vars) => DropdownMenuItem(
                                  value: vars,
                                  child: Text(vars),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedVariables = value);
                        },
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
                          hintText: 'Example: If Ann has X apples, but Ann eats Y apples. How many apples Ann have?',
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
                          hintText: 'Example: X-Y',
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  // _buildHeader remains unchanged
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundImage: AssetImage(AppImages.user),
            radius: 15,
          ),
          const SizedBox(width: 5),
          const Text('Moni Roy', style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}