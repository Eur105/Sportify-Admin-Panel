import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  String selectedFilter = 'Confirmed'; // Default tab
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookings(selectedFilter);
  }

  Future<void> fetchBookings(String status) async {
    setState(() {
      isLoading = true;
    });

    try {
      String url =
          "http://localhost:5000/api/booking/getbookingbystatus?status=$status";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bookings = List<Map<String, dynamic>>.from(data['Bookings']);
        });
      } else {
        print("Failed to load bookings");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Cancellation"),
          content: Text("Are you sure you want to cancel this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cancelBooking(index);
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void cancelBooking(int index) {
    setState(() {
      bookings[index]['status'] = 'Cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bookings")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Bookings...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterChip("Confirmed"),
                filterChip("Rejected"),
                filterChip("Pending"),
              ],
            ),
          ),
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading spinner
              : Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      BookingDetailsScreen(booking: booking),
                            ),
                          ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.grey[200],
                        elevation: 3,
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "User: ${booking['fullName']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Venue: ${booking['venueName']}"),
                              Text("Booking Time: ${booking['bookingTime']}"),
                              Text(
                                "Date: ${booking['bookingDate'].split('T')[0]}",
                              ),
                              Text("Price: ${booking['totalAmount']}"),
                              Row(children: [statusLabel(booking['status'])]),
                              if (booking['status'] != 'Confirmed')
                                ElevatedButton(
                                  onPressed:
                                      () => showConfirmationDialog(
                                        context,
                                        index,
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text(
                                    "Cancel Booking",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: Colors.black)),
        selected: selectedFilter == label,
        selectedColor: Colors.blue,
        onSelected: (bool selected) {
          setState(() {
            selectedFilter = label;
            fetchBookings(selectedFilter);
          });
        },
      ),
    );
  }

  Widget statusLabel(String status) {
    Color color =
        status == 'Confirmed'
            ? Colors.green
            : status == 'Cancelled'
            ? Colors.red
            : Colors.blue;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: Colors.white)),
    );
  }
}

// Booking Details Page
class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  const BookingDetailsScreen({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Name: ${booking['fullName']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Venue: ${booking['venueName']}",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Booking Time: ${booking['bookingTime']}",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Date: ${booking['bookingDate'].split('T')[0]}",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Price: ${booking['totalAmount']}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                _statusLabel(booking['status']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusLabel(String status) {
    Color color =
        status == 'Confirmed'
            ? Colors.green
            : status == 'Cancelled'
            ? Colors.red
            : Colors.blue;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: Colors.white)),
    );
  }
}
