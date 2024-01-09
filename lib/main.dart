import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedImage;

  Future _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = pickedImage.path;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Take a picture'),
                            onTap: () {
                              _getImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo),
                            title: Text('Choose from gallery'),
                            onTap: () {
                              _getImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.add_a_photo),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedImage != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadingScreen(
                            image: _selectedImage!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text('Search Product'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final String image;

  const LoadingScreen({super.key, required this.image});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String result = 'Default Product Name';

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  Future<void> fakeProcessing() async {
    print("fake-processing");
    loadModel();
    var recognitions = await Tflite.runModelOnImage(
      path: widget.image,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      threshold: 0.1,
    );
    print(recognitions![0]['label']);
    result = recognitions![0]['label'];

    setState(() {
      result;
    });
  }

  @override
  void initState() {
    super.initState();
    // Simulate processing when the screen initializes
    fakeProcessing().then((_) {
      // After processing is done, navigate to the ProductPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductPage(productName: result),
        ),
      );
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(widget.image)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final String productName;

  ProductPage({required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/product_image.png', // Replace with your product image
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              '$productName',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add to cart functionality
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
