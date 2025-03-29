import 'package:cloud_firestore/cloud_firestore.dart';

class StoreDefaultModle {
  final String avatarurl;
  final int price;

  StoreDefaultModle(this.avatarurl,  this.price);

    Map<String, dynamic> toMap() {
    return {
      'avatarurl': avatarurl,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }

    factory StoreDefaultModle.fromMap(Map<String, dynamic> data) {
      return StoreDefaultModle(
        data['avatarurl'] ?? '',          
        data['price'] ?? '',          
      );
  }
}