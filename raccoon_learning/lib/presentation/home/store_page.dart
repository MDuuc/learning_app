import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/main.dart';
import 'package:raccoon_learning/presentation/home/achievement/widget/achiement_button.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/User_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/appbar/app_bar.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final List<Map<String, dynamic>> storeItems = [
    {"image": AppImages.raccoon_notifi, "price": "80"},
    {"image": AppImages.raccoon_notifi, "price": "120"},
    {"image": AppImages.raccoon_notifi, "price": "100"},
    {"image": AppImages.raccoon_notifi, "price": "70"},
    {"image": AppImages.raccoon_notifi, "price": "80"},
    {"image": AppImages.raccoon_notifi, "price": "120"},
    {"image": AppImages.raccoon_notifi, "price": "100"},
    {"image": AppImages.raccoon_notifi, "price": "70"},
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Consumer<UserNotifier>(builder: (context, user, child) {
        return Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight / 4,
              decoration: const BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      "Store",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 45,
                            child: Image.asset(
                              AppImages.coin,
                            ),
                          ),
                          Text(
                            user.coin.toString(),
                            style: TextStyle(
                              color: AppColors.yellow_coin,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 100,
                            child: Image.asset(
                              AppImages.rac_3,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, 
                ),
                itemCount: storeItems.length,
                itemBuilder: (context, index) {
                  final item = storeItems[index];
                  return storeItem(
                    context,
                     item["image"],
                     item["price"],
                     () {
                      my_alert_dialog(context, 'Purchase', 'Are you sure to purchase this one', (){});
                      showDialog(context: context, builder: (BuildContext  context){
                        return my_alert_dialog(context, 'Purchase', 'Are you sure to purchase this', (){
                          Provider.of<UserNotifier>(context, listen: false).saveCoin(user.coin - int.parse(item["price"]));
                          print(user.coin - int.parse(item["price"]));
                          }
                        );
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}



  @override
  Widget storeItem (BuildContext context, String image,  String price,  VoidCallback onPress) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: (){showFullImage(context, AssetImage(image));},
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(image),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            child: ElevatedButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 30,
                    child: Image.asset(AppImages.coin),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
