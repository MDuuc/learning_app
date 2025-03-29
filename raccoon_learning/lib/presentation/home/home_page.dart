import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/home/achievement/tab_controler_achive.dart';
import 'package:raccoon_learning/presentation/home/learning/choose_grade_page.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/dialog/competive_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 ImageProvider ?currentAvatar; 

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Consumer<UserNotifier>(builder: (context, user, child){
        currentAvatar = NetworkImage(user.avatarPath);
        return Column(
        children: [
          Container(
            height: screenHeight / 4,
            decoration: const BoxDecoration(
              color: AppColors.black,
              borderRadius:  BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                const SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        backgroundImage: currentAvatar,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome,",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        user.username.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        :Text(
                          "${user.username}!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 35,
                      child: Image.asset(
                        AppImages.fire,
                      ),
                    ),
                    const SizedBox(width: 10),
                     Padding(
                      padding:  const EdgeInsets.only(top: 8),
                      child: Text(
                       user.streakCount.toString(),
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 20), 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth / 3,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2), 
                        child: const Text(
                          "Unstoppable",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100,),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    _menuHome(context, AppImages.raccoon_playing, "Competitive", (){
                      _showDialog(context);
                     }),

                  _menuHome(context, AppImages.raccoon_learning, "Learning", (){Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const ChooseGradePage()
                      )
                    ); }),
                ],
              ),
            ),

              Expanded(
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                
                children: [
                  _menuHome(context, AppImages.raccoon_achievement, "Achievement", (){ 
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (BuildContext context) => const TabControlerAchive())
                      );
                  }),
                  _menuHome(context, AppImages.raccoon_custom, "Custom", (){    
                    }),
                ],
                            ),
              ),
          ],
        );
      })
    );
  }
  Widget _menuHome (BuildContext context, String image, String tilte, VoidCallback onTap){
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
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover
                )
            ),
          ),
          Text(
            tilte,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          )
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const CompetiveDialog(); 
    },
  );
}
}