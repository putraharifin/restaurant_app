import 'package:restaurant_app/data/models/customer_review.dart';

class Menus {
  const Menus({required this.foods, required this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: _names(json['foods']),
      drinks: _names(json['drinks']),
    );
  }

  static List<String> _names(Object? items) {
    return (items as List<dynamic>)
        .map((item) => (item as Map<String, dynamic>)['name'] as String)
        .toList();
  }

  final List<String> foods;
  final List<String> drinks;
}

class RestaurantDetail {
  const RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.categories,
    required this.menus,
    required this.rating,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      pictureId: json['pictureId'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((item) => (item as Map<String, dynamic>)['name'] as String)
          .toList(),
      menus: Menus.fromJson(json['menus'] as Map<String, dynamic>),
      rating: (json['rating'] as num).toDouble(),
      customerReviews: (json['customerReviews'] as List<dynamic>)
          .map((item) => CustomerReview.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final List<String> categories;
  final Menus menus;
  final double rating;
  final List<CustomerReview> customerReviews;

  RestaurantDetail copyWith({List<CustomerReview>? customerReviews}) {
    return RestaurantDetail(
      id: id,
      name: name,
      description: description,
      city: city,
      address: address,
      pictureId: pictureId,
      categories: categories,
      menus: menus,
      rating: rating,
      customerReviews: customerReviews ?? this.customerReviews,
    );
  }
}
