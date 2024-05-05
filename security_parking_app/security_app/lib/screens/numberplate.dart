import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';

class BoxDetailsPage extends StatefulWidget {
  final int boxIndex;
  final int capacity;
  final Map<int, bool> confirmedBoxes;
  final String spaceId;
  final Function(int, Timestamp) updateBoxTimestamp;
  final Map<int, String> imageUrl;

  BoxDetailsPage({
    required this.spaceId,
    required this.boxIndex,
    required this.capacity,
    required this.confirmedBoxes,
    required this.updateBoxTimestamp,
    required this.imageUrl,
  });

  @override
  _BoxDetailsPageState createState() => _BoxDetailsPageState();
}

class _BoxDetailsPageState extends State<BoxDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  File? _capturedImage;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle entry details'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Enter vehicle number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey),
                    ),
                child: _capturedImage != null
                    ? Image.file(_capturedImage!)
                    : Center(child: Text('No image captured')),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Capture an image from the camera
                      XFile? image = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      // if (image != null) {
                      //   // Send the captured image to the server

                      // } else {
                      //   print('No image selected');
                      // }
                      if (image != null) {
                        setState(() {
                          _capturedImage = File(image.path);
                        });
                        await sendImageToServer(File(image.path));
                        await sendImageToFirebase(File(image.path));
                      } else {
                        print('No image selected');
                      }
                    },
                    child: Text('Capture Image'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF6F61EF),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      widget.imageUrl[widget.boxIndex] = _imageUrl!;
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          widget.confirmedBoxes[widget.boxIndex] = true;
                        });
                        final vehicleData = {
                          'vehicle_number': _contentController.text,
                          'entry_time': Timestamp.now(),
                          'space_id': widget.spaceId,
                          'image_url':
                              _imageUrl, // Add image URL to vehicle data
                        };

                        await FirebaseFirestore.instance
                            .collection('VEHICLES')
                            .add(vehicleData);
                        widget.updateBoxTimestamp(
                            widget.boxIndex, Timestamp.now());
                        Navigator.pop(context, {
                          'confirmed': true,
                          'content': _contentController.text,
                        });
                      }
                    },
                    child: Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF6F61EF),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendImageToFirebase(File imageFile) async {
    try {
      // Upload image to Firebase Storage
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('vehicle_images/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(imageFile);

      // Get the download URL for the image
      _imageUrl = await snapshot.ref.getDownloadURL();

      // Once uploaded, you can use _imageUrl to display the image or save it to Firestore.
      print('Image uploaded to Firebase: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> sendImageToServer(File imageFile) async {
    // Server URL
    var url = Uri.parse('http://192.168.91.189:5000/perform_ocr');

    try {
      // Create a multipart request
      var request = await createMultipartRequest(url, imageFile);

      // Send the request
      var response = await sendRequest(request);

      // Check the status code of the response
      if (response.statusCode == 200) {
        // If successful, print the OCR result
        var responseBody = await response.stream.transform(utf8.decoder).join();
        print('OCR Result: $responseBody');
      } else {
        // If unsuccessful, print the error message
        print('Error: ${response.reasonPhrase}');
      }
    } on IOException catch (e) {
      // Print any IO exceptions that occur during the process
      print('IO Exception: $e');
    } on HttpException catch (e) {
      // Print any HTTP exceptions that occur during the process
      print('HTTP Exception: $e');
    } catch (e) {
      // Print any other exceptions that occur during the process
      print('Exception: $e');
    }
  }

  Future<http.MultipartRequest> createMultipartRequest(
      Uri url, File imageFile) async {
    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    return request;
  }

  Future<http.StreamedResponse> sendRequest(
      http.MultipartRequest request) async {
    // Send the request
    var response = await request.send();

    // Create a new StreamedResponse object from the response
    var streamedResponse = http.StreamedResponse(
      response.stream,
      response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
    );

    return streamedResponse;
  }
}

class NumberPlateReader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Plate Reader'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Capture an image from the camera
            XFile? image =
                await ImagePicker().pickImage(source: ImageSource.camera);
            if (image != null) {
              // Send the captured image to the server
              await sendImageToServer(File(image.path));
            } else {
              print('No image selected');
            }
          },
          child: Text('Capture Image'),
        ),
      ),
    );
  }

  Future<void> sendImageToServer(File imageFile) async {
    // Server URL
    var url = Uri.parse('http://192.168.91.189:5000/perform_ocr');

    try {
      // Create a multipart request
      var request = await createMultipartRequest(url, imageFile);

      // Send the request
      var response = await sendRequest(request);

      // Check the status code of the response
      if (response.statusCode == 200) {
        // If successful, print the OCR result
        var responseBody = await response.stream.transform(utf8.decoder).join();
        print('OCR Result: $responseBody');
      } else {
        // If unsuccessful, print the error message
        print('Error: ${response.reasonPhrase}');
      }
    } on IOException catch (e) {
      // Print any IO exceptions that occur during the process
      print('IO Exception: $e');
    } on HttpException catch (e) {
      // Print any HTTP exceptions that occur during the process
      print('HTTP Exception: $e');
    } catch (e) {
      // Print any other exceptions that occur during the process
      print('Exception: $e');
    }
  }

  Future<http.MultipartRequest> createMultipartRequest(
      Uri url, File imageFile) async {
    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    return request;
  }

  Future<http.StreamedResponse> sendRequest(
      http.MultipartRequest request) async {
    // Send the request
    var response = await request.send();

    // Create a new StreamedResponse object from the response
    var streamedResponse = http.StreamedResponse(
      response.stream,
      response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
    );

    return streamedResponse;
  }
}
