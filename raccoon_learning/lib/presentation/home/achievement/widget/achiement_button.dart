import 'package:flutter/material.dart';
import 'package:raccoon_learning/constants/theme/app_colors.dart';

class AchiementButton extends StatefulWidget {
  final ImageProvider image;
  final String text;
  AchiementButton({super.key, required this.image, required this.text});

  @override
  State<AchiementButton> createState() => _AchiementButtonState();
}

class _AchiementButtonState extends State<AchiementButton> {
    bool _isClaimed = false;

  void _claimReward() {
    setState(() {
      _isClaimed = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        constraints: BoxConstraints(
          minHeight: screenHeight / 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.brown_light
        ),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                 showFullImage(context, widget.image);
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30,
                backgroundImage: widget.image,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.black
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isClaimed
                  ? null // Disable the button if reward is already claimed
                  : _claimReward, // Call the claim function when pressed
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Colors.white,
                backgroundColor:
                    _isClaimed ? Colors.grey : Colors.greenAccent.shade400,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                child: Text(
                  _isClaimed ? "Claimed" : "Claim", // Change the text dynamically
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> showFullImage(BuildContext context, ImageProvider  image) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Full-screen image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(image: image),
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
