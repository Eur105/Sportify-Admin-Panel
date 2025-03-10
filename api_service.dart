import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl =
      "YOUR_BACKEND_URL_HERE"; // Replace with actual backend URL

  static Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    final url = Uri.parse(
      "$baseUrl/admin/login",
    ); // Replace with actual endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful login
      } else {
        return {"error": "Invalid email or password"};
      }
    } catch (e) {
      return {"error": "Something went wrong. Please try again later."};
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardData(String adminId) async {
    final url = Uri.parse(
      "$baseUrl/admin/dashboard/$adminId",
    ); // Replace with actual backend URL

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Successful response
      } else {
        return {"error": "Failed to fetch dashboard data"};
      }
    } catch (e) {
      return {"error": "Something went wrong. Please try again later."};
    }
  }

  // Fetch all pending bookings (Approvals screen)
  static Future<List<Map<String, dynamic>>> fetchPendingBookings() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pending-bookings"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (booking) => {
                'id': booking['id'],
                'userName': booking['user_name'],
                'venue': booking['venue'],
                'bookingTime': booking['time'],
                'duration': booking['duration'],
                'price': booking['price'],
                'date': booking['date'],
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load pending bookings');
      }
    } catch (e) {
      print("Error fetching pending bookings: $e");
      return [];
    }
  }

  // Approve or Reject Booking
  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/approve-reject-booking"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'booking_id': bookingId, 'status': status}),
      );

      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      print("Error updating booking status: $e");
      return false;
    }
  }

  // Fetch all bookings (Bookings screen)
  static Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/bookings"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (booking) => {
                'id': booking['id'],
                'userName': booking['user_name'],
                'venue': booking['venue'],
                'bookingTime': booking['time'],
                'duration': booking['duration'],
                'price': booking['price'],
                'date': booking['date'],
                'status': booking['status'],
                'paymentStatus': booking['payment_status'],
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print("Error fetching all bookings: $e");
      return [];
    }
  }

  // Fetch Admin Profile
  static Future<Map<String, dynamic>?> fetchAdminProfile() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/profile"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Update Admin Profile
  static Future<bool> updateAdminProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage, // ✅ Fix: Now `File` is recognized
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/admin/update-profile"),
      );

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profileImage", profileImage.path),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }
}
