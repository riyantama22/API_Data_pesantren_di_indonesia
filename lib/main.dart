import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesantren di Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PesantrenListScreen(),
    );
  }
}

class PesantrenListScreen extends StatefulWidget {
  @override
  _PesantrenListScreenState createState() => _PesantrenListScreenState();
}

class _PesantrenListScreenState extends State<PesantrenListScreen> {
  List<Pesantren> pesantrenList = [];
  List<Pesantren> filteredPesantrenList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api-pesantren-indonesia.vercel.app/pesantren/3206.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Pesantren> tempList = [];
      for (var pesantrenData in data) {
        Pesantren pesantren = Pesantren.fromJson(pesantrenData);
        tempList.add(pesantren);
      }

      setState(() {
        pesantrenList = tempList;
        filteredPesantrenList = tempList;
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  void filterPesantrenList(String query) {
    List<Pesantren> tempList = [];
    tempList.addAll(pesantrenList);
    if (query.isNotEmpty) {
      tempList.retainWhere((pesantren) {
        return pesantren.nama.toLowerCase().contains(query.toLowerCase());
      });
    }

    setState(() {
      filteredPesantrenList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesantren di Indonesia'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterPesantrenList(value);
              },
              decoration: InputDecoration(
                labelText: 'Cari Pesantren',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPesantrenList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(filteredPesantrenList[index].nama),
                  subtitle: Text(filteredPesantrenList[index].alamat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Pesantren {
  final String id;
  final String nama;
  final String nspp;
  final String alamat;
  final String kyai;
  final KabKota kabKota;
  final Provinsi provinsi;

  Pesantren({
    required this.id,
    required this.nama,
    required this.nspp,
    required this.alamat,
    required this.kyai,
    required this.kabKota,
    required this.provinsi,
  });

  factory Pesantren.fromJson(Map<String, dynamic> json) {
    return Pesantren(
      id: json['id'],
      nama: json['nama'],
      nspp: json['nspp'],
      alamat: json['alamat'],
      kyai: json['kyai'],
      kabKota: KabKota.fromJson(json['kab_kota']),
      provinsi: Provinsi.fromJson(json['provinsi']),
    );
  }
}

class KabKota {
  final String id;
  final String nama;

  KabKota({
    required this.id,
    required this.nama,
  });

  factory KabKota.fromJson(Map<String, dynamic> json) {
    return KabKota(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class Provinsi {
  final String id;
  final String nama;

  Provinsi({
    required this.id,
    required this.nama,
  });

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      id: json['id'],
      nama: json['nama'],
    );
  }
}
