class StoreModle {
  final String image;
  final int price;
  final bool purchase;
  
  StoreModle(this.image, this.price, this.purchase);
  
  factory StoreModle.fromMap(Map<String, dynamic> data) {
    return StoreModle(
      data['image'] ?? '',          
      data['price'] ?? 0,           
      data['purchase'] ?? false,    
    );
  }

    Map<String, dynamic> toMap() {
    return {
      'image': image,
      'price': price,
      'purchase': purchase,
    };
  }
}