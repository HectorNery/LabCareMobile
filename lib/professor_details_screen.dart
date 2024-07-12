import 'package:flutter/material.dart';

class ProfessorDetailsScreen extends StatelessWidget {
  final String idNumber;
  final String fullName;

  const ProfessorDetailsScreen({
    Key? key,
    required this.idNumber,
    required this.fullName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professor Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Number: $idNumber', style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
              Text('Full Name: $fullName', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
