import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Import the profile screen

class DeductionsScreen extends StatelessWidget {
  const DeductionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F2), // Matches background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator
                .pushReplacement( // Use pushReplacement to prevent going back
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        title: const Text(
          'Deductions',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // "This week" Section
            const Text(
              'This week',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            DeductionItem(
              title: 'Vehicle rental',
              date: 'Dec 12, 2023',
              amount: '₹20,750',
            ),
            DeductionItem(
              title: 'Insurance',
              date: 'Dec 12, 2023',
              amount: '₹8,300',
            ),
            DeductionItem(
              title: 'Service fee',
              date: 'Dec 12, 2023',
              amount: '₹4,150',
            ),
            DeductionItem(
              title: 'Late login',
              date: 'Dec 12, 2023',
              amount: '₹12,660',
            ),
            const SizedBox(height: 20),
            // Total for This week
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0), // Adjust padding if needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '-₹45,860',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // From image
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Spacing between sections

            // "Last week" Section
            const Text(
              'Last week',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            DeductionItem(
              title: 'Vehicle rental',
              date: 'Dec 5, 2023',
              amount: '₹20,750',
            ),
            DeductionItem(
              title: 'Insurance',
              date: 'Dec 5, 2023',
              amount: '₹8,300',
            ),
            DeductionItem(
              title: 'Service fee',
              date: 'Dec 5, 2023',
              amount: '₹4,150',
            ),
            const SizedBox(height: 40), // Spacing before the summary card

            // Total Deductions Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAE8), // Matches card background from other screens
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F4F2), // Icon background color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.currency_rupee, // Rupee icon
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '-₹79,060',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Total Deductions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// Custom Widget for a single Deduction Item row
class DeductionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;

  const DeductionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            '-$amount', // Deductions are negative
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Negative amount is black in image
            ),
          ),
        ],
      ),
    );
  }
}
