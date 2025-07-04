import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raccoon_learning/constants/assets/app_images.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';
import 'package:raccoon_learning/presentation/user/notify_provider/gameplay_notifier.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Future<void> _refreshStore(BuildContext context) async {
    final gameplay = Provider.of<GameplayNotifier>(context, listen: false);
    await gameplay.refreshStoreData();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Consumer<GameplayNotifier>(builder: (context, gameplay, child) {
        final sortedItems = gameplay.storeItems;
        final coin = gameplay.coin;
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
                    const Text(
                      "Store",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 45,
                            child: Image.asset(AppImages.coin),
                          ),
                          Text(
                            coin.toString(),
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
              child: RefreshIndicator(
                  onRefresh: () => _refreshStore(context),
                  color: AppColors.yellow_coin,
                  backgroundColor: AppColors.black,
                  strokeWidth: 3.0,
                  displacement: 20.0,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: sortedItems.length,
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    bool isPurchased = item.purchase;
                    return storeItem(
                      context,
                      item.image,
                      item.price,
                      isPurchased
                          ? null
                          : () async {
                              my_alert_dialog(
                                  context,
                                  'Purchase',
                                  'Are you sure to purchase this',
                                  () async {
                                    if (coin >= item.price) {
                                      await gameplay.purchaseAvatar(item.image, item.price);
                                      await gameplay.purchaseItem(item);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Avatar purchased successfully!')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Not enough coins!')),
                                      );
                                    }
                                  });
                            },
                      isPurchased,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget storeItem(BuildContext context, String image, int price, VoidCallback? onPress, bool isPurchased) {
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
            onTap: () {
              showFullImage(context, NetworkImage(image));
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(image),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPurchased ? Colors.grey : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isPurchased
                ? const Text("Purchased", style: TextStyle(color: Colors.white, fontSize: 18))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$price',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(height: 30, child: Image.asset(AppImages.coin)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}