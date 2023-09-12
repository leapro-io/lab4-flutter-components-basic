import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Activity",
                style: TextStyle(
                  color: Colors.black, // Title color
                ),
              ),
              backgroundColor: Colors.white10,
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No data available.');
                } else {
                  final groupedData = groupDataByDate(snapshot.data ?? []);

                  return Center(
                    child: ListView.builder(
                      itemCount: groupedData.length,
                      itemBuilder: (context, index) {
                        final date = groupedData.keys.elementAt(index);
                        final formattedDate = formatDate(date);
                        final items = groupedData.values.elementAt(index);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...items.map((item) {
                              final description = item['description'];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item == items.first)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4.0,
                                        right: 16.0,
                                        top: 8.0,
                                        bottom: 16.0,
                                      ),
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    height: 60.0,
                                    margin: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: Text(
                                          description,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
    ),
  );
}

Future<List<Map<String, dynamic>>> fetchData(BuildContext context) async {
  final response =
      await DefaultAssetBundle.of(context).loadString('assets/data.json');
  final jsonData = json.decode(response);

  List<Map<String, dynamic>> items = [];
  for (var item in jsonData) {
    items.add(Map<String, dynamic>.from(item));
  }

  return items;
}

Map<String, List<Map<String, dynamic>>> groupDataByDate(
    List<Map<String, dynamic>> data) {
  final groupedData = <String, List<Map<String, dynamic>>>{};

  for (var item in data) {
    final date = item['date'] as String;
    if (!groupedData.containsKey(date)) {
      groupedData[date] = [];
    }
    groupedData[date]!.add(item);
  }

  return groupedData;
}

String formatDate(String date) {
  final now = DateTime.now();
  final parsedDate = DateTime.parse(date);

  if (now.year == parsedDate.year &&
      now.month == parsedDate.month &&
      now.day == parsedDate.day) {
    return 'Today';
  } else if (now.year == parsedDate.year &&
      now.month == parsedDate.month &&
      now.day == parsedDate.day + 1) {
    return 'Yesterday';
  } else {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(parsedDate);
  }
}
