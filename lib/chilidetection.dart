import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

class ChiliDetectionScreen extends StatefulWidget {
  const ChiliDetectionScreen({super.key});

  @override
  State<ChiliDetectionScreen> createState() => _ChiliDetectionScreenState();
}

class _ChiliDetectionScreenState extends State<ChiliDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  String _result = '';
  bool _isProcessing = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    if (_modelLoaded) {
      Tflite.close();
    }
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/models/chili_disease_model.tflite',
        labels: 'assets/models/labels.txt', // You'll need to create this file
      );
      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _result = '';
        _isProcessing = true;
      });

      await _processImage(_image!);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _processImage(File image) async {
    if (!_modelLoaded) {
      setState(() {
        _result = 'Error: Model not loaded';
        _isProcessing = false;
      });
      return;
    }

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 5,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions == null || recognitions.isEmpty) {
        setState(() {
          _result = 'No predictions found';
          _isProcessing = false;
        });
        return;
      }

      var prediction = recognitions[0];
      String disease = prediction['label'];
      double confidence = prediction['confidence'];
      String advice = _getAdvice(disease);

      setState(() {
        _result = 'Condition: $disease\n'
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n\n'
            'Recommendations:\n$advice';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error processing image: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  String _getAdvice(String disease) {
    switch (disease) {
      case 'Healthy':
        return '• Continue regular watering\n• Maintain good sunlight\n• Regular fertilization';
      case 'Leaf Curl':
        return '• Remove affected leaves\n• Apply fungicide\n• Improve air circulation';
      case 'Leaf Spot':
        return '• Apply copper fungicide\n• Remove infected leaves\n• Avoid overhead watering';
      case 'Whitefly':
        return '• Use insecticidal soap\n• Install yellow sticky traps\n• Monitor regularly';
      case 'Yellowish':
        return '• Check soil nutrients\n• Adjust watering\n• Apply balanced fertilizer';
      default:
        return '• Consult a plant expert for specific advice';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F4C3A),
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPreviewArea(),
                      if (_result.isNotEmpty) _buildResultsCard(),
                      _buildActionButtons(),
                      _buildInformationCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Chili Disease Detection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_image != null)
              Image.file(_image!, fit: BoxFit.cover)
            else
              Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Detection Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _result,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            onTap: _isProcessing ? null : () => _getImage(ImageSource.camera),
          ),
          _buildActionButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: _isProcessing ? null : () => _getImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(onTap == null ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(onTap == null ? 0.5 : 1.0),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(onTap == null ? 0.5 : 1.0),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to use:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          _buildInstructionItem(
            '1. Take a clear photo of the chili plant leaf',
            Icons.camera_alt,
          ),
          _buildInstructionItem(
            '2. Ensure good lighting conditions',
            Icons.wb_sunny,
          ),
          _buildInstructionItem(
            '3. Keep the leaf in focus',
            Icons.center_focus_strong,
          ),
          _buildInstructionItem(
            '4. Wait for the analysis result',
            Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
