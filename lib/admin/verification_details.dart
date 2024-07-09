import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationDetailPage extends StatelessWidget {
  final DocumentSnapshot verification;

  VerificationDetailPage({required this.verification});

  @override
  Widget build(BuildContext context) {
    String userId = verification['userId'];
    String firstName = verification['firstName'] ?? '';
    String lastName = verification['lastName'] ?? '';
    String registrationNumber = verification['registrationNumber'] ?? '';
    String idCardUrl = verification['idCardUrl'] ?? '';
    String vehicleCardUrl = verification['vehicleCardUrl'] ?? '';
    String vehicleImageUrl = verification['vehicleImageUrl'] ?? '';
    String insuranceImageUrl = verification['insuranceImageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la Vérification',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInfoCard('Nom', '$firstName'),
              SizedBox(height: 16.0),
              _buildInfoCard('Prénoms', '$lastName'),
              SizedBox(height: 16.0),
              _buildInfoCard('Matricule du véhicule', registrationNumber),
              SizedBox(height: 16.0),
              _buildImageWidget(idCardUrl, 'Carte d\'identité'),
              SizedBox(height: 16.0),
              _buildImageWidget(vehicleCardUrl, 'Carte grise du véhicule'),
              SizedBox(height: 16.0),
              _buildImageWidget(vehicleImageUrl, 'Image du véhicule'),
              SizedBox(height: 16.0),
              _buildImageWidget(insuranceImageUrl, 'Image de l\'assurance'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            content,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl, String title) {
    if (imageUrl.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Impossible de charger l\'image');
              },
            ),
          ),
        ),
      ],
    );
  }
}
