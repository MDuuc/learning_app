import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/Avatar_notifier.dart';

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({super.key});

  @override
  State<ChangeAvatar> createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {
  int selectedIndex =0; 

  @override
  Widget build(BuildContext context) {
    final List<String> avatars = [
      AppImages.raccoon_notifi,
      AppImages.raccoon_grade_1,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,
      AppImages.raccoon_notifi,

    ];

    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 10, 
                    mainAxisSpacing: 10, 
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedIndex = index; 
                        });
                      },
                      child: CircleAvatar(
                        radius: 40, 
                        backgroundImage: AssetImage(avatars[index]) ,
                        child: selectedIndex == index 
                            ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary, 
                                    width: 3,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // selected avatar
          if (selectedIndex != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.brown_light),
                  foregroundColor: MaterialStateProperty.all(AppColors.black),
                ),
                onPressed: () {
                  // confirm dialig
                  showDialog(
                    context: context,
                    builder: (context) {
                      //alert diaglog to check twice confirm
                      return AlertDialog(
                        title: const Text("Confirm avatar"),
                        content: const Text("Do you want to choose this avatar?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancle', style: TextStyle(color: AppColors.black),),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<AvatarNotifier>(context, listen: false).saveAvatar(avatars[selectedIndex]);  //save image 
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(

                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                color: AppColors.primary
                              ),
                              ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Confirm"),
              ),
            ),
        ],
      ),
    );
  }
}

Future<dynamic> showAvatarDialog(BuildContext context) async {
  return showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (BuildContext context){
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ChangeAvatar(),
      );
    }
  );
}
