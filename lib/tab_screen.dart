import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Jumlah tab yang diperbarui menjadi 4
      child: Scaffold(
        appBar: AppBar(
          title: Text('DKI JAKARTA "OPEN DATA'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Welcome'),
              Tab(icon: Icon(Icons.place), text: 'Pariwisata'),
              Tab(icon: Icon(Icons.local_hospital), text: 'Kesehatan'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WelcomeTab(),
            PariwisataTab(),
            KesehatanTab(),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}

class WelcomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Selamat Datang'),
    );
  }
}

class PariwisataTab extends StatelessWidget {
 Future<List<User>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://ws.jakarta.go.id/gateway/DataPortalSatuDataJakarta/1.0/satudata?kategori=dataset&tipe=detail&url=indeks-kepuasan-layanan-penunjang-urusan-pemerintahan-daerah-pada-dinas-pariwisata-dan-ekonomi-kreatif'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: FutureBuilder<List<User>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.periode_data),
                subtitle: Text(user.triwulan),
              );
            },
          );
        },
      ),
    );
  }
}


class KesehatanTab extends StatelessWidget {
  Future<List<Hospital>> fetchKesehatanData() async {
    final response = await http.get(Uri.parse(
        'https://ws.jakarta.go.id/gateway/DataPortalSatuDataJakarta/1.0/satudata?kategori=dataset&tipe=detail&url=perempuan-dan-anak-korban-kekerasan-yang-mendapatkan-layanan-kesehatan-oleh-tenaga-kesehatan-terlatih-di-puskesmas-mampu-tatalaksana-kekerasan-terhadap-perempuananak-ktpa-dan-pusat-pelayanan-terpadupusat-krisis-terpadu-pptpkt-di-rumah-sakit'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((hospital) => Hospital.fromJson(hospital)).toList();
    } else {
      throw Exception('Failed to load kesehatan data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hospital>>(
      future: fetchKesehatanData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final hospitals = snapshot.data!;
        return ListView.builder(
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return ListTile(
              title: Text(hospital.firstName),
              subtitle: Text(hospital.email),
            );
          },
        );
      },
    );
  }
}

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Information'),
    );
  }
}

class User {
  final String periode_data;
  final String triwulan;
  User({required this.periode_data, required this.triwulan});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      periode_data: json['periode_data'],
      triwulan: json['triwulan'],
    );
  }
}


class Hospital {
  final String firstName;
  final String email;
  Hospital({required this.firstName, required this.email});
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      firstName: json['wilayah'],
      email: json['lokasi'],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TabScreen(),
  ));
}
