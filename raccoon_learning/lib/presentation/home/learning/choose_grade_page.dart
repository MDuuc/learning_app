import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/operation_dialog.dart';

class ChooseGradePage extends StatelessWidget {
  const ChooseGradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Text(
                "MATH",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50,),
              const Text(
                "Learn while others sleep, work while others are lazy, prepare while others play, and dream while others only wish",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey
                ),
              ),
              const SizedBox(height: 100,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuGrade(context, AppImages.raccoon_grade_1, "Grade 1", (){
                    _showDialog(context, 'grade_1');
                  }),
                  _menuGrade(context, AppImages.raccoon_grade_2, "Grade 2", (){
                    _showDialog(context, 'grade_2');
                  })
                ],
              ),
              const SizedBox(height: 50,),
        
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuGrade(context, AppImages.raccoon_grade_3, "Grade 3", (){
                    _showDialog(context, 'grade_3');
                  }),
                ],
              ),              
            ],
          ),
        ),
      ),
    );
  }

    Widget _menuGrade (BuildContext context, String image, String tilte, VoidCallback onTap){
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenWidth / 3;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover
                )
            ),
          ),
          Text(
            tilte,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );
  }

void _showDialog(BuildContext context, String grade) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return OperationDialog(grade: grade); 
    },
  );
}
}