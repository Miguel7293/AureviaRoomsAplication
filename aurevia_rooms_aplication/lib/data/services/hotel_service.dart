// lib/data/services/hotel_service.dart
import 'package:aureviarooms/data/models/hotel.dart';

class HotelService {
  Future<List<Hotel>> getFeaturedHotels() async {
    return [
      Hotel(
        id: '1',
        name: 'Grand Plaza Hotel',
        location: 'New York City, USA',
        pricePerNight: 299,
        imageUrl: 'https://media-cdn.tripadvisor.com/media/photo-s/2e/16/1b/4b/hotel-exterior.jpg',
        description: 'Luxury hotel in the heart of NYC',
        rating: 4.8,
      ),
      Hotel(
        id: '2',
        name: 'Beachfront Resort',
        location: 'Miami, USA',
        pricePerNight: 349,
        imageUrl: 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/540911103.webp?k=06b87930aacddac7f8b296a9c92c3b8679de7c056d1bc759c61ef11a7b5defeb&o=',
        description: 'Beautiful resort with ocean view',
        rating: 4.7,
      ),
      Hotel(
        id: '3',
        name: 'Mountain Lodge',
        location: 'Denver, USA',
        pricePerNight: 199,
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSl1vc8x7yxfS16sVzO6P1DzuE20BmK2o9Pug&s',
        description: 'Cozy lodge in the mountains',
        rating: 4.5,
      ),
    ];
  }
}