class ParkingArea {
  final String name;
  final double rating;
  final String workingTime;
  final int availabilityTwoWheelers;
  final int availabilityFourWheelers;
  final double feePerHourTwoWheelers;
  final double feePerHourFourWheelers;
  final String address;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final int space_id;
  final String imageUrl; // Add imageUrl field

  ParkingArea({
    required this.name,
    required this.rating,
    required this.workingTime,
    required this.availabilityTwoWheelers,
    required this.availabilityFourWheelers,
    required this.feePerHourTwoWheelers,
    required this.feePerHourFourWheelers,
    required this.address,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.space_id,
    required this.imageUrl, // Add this line to initialize imageUrl
  });
}
