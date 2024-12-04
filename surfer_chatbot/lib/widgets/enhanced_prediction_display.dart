import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EnhancedPredictionDisplay extends ConsumerStatefulWidget {
  final LocationData? location;
  final String? spotName;

  const EnhancedPredictionDisplay({
    super.key,
    required this.location,
    this.spotName,
  });

  @override
  ConsumerState<EnhancedPredictionDisplay> createState() =>
      _EnhancedPredictionDisplayState();
}

class _EnhancedPredictionDisplayState
    extends ConsumerState<EnhancedPredictionDisplay> {
  bool isLoading = false;
  String? error;
  double rating = 0.0;
  double confidence = 0.0;
  List<Map<String, dynamic>> features = [];

  @override
  void didUpdateWidget(EnhancedPredictionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spotName != null && widget.location != null) {
      _fetchPrediction();
    }
  }

  Future<void> _fetchPrediction() async {
    if (widget.spotName == null || widget.location == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/enhanced_prediction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'spot_name': widget.spotName,
          'latitude': widget.location?.latitude,
          'longitude': widget.location?.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rating = data['current_conditions']['rating'].toDouble();
          confidence = data['current_conditions']['confidence'].toDouble();
          features =
              List<Map<String, dynamic>>.from(data['feature_contributions']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch prediction';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(child: Text(error!))
            else
              _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Surf Quality Rating',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${rating.toStringAsFixed(1)} / 4.0',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Confidence'),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Contributing Factors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(feature['name']),
                      Text(
                          '${(feature['importance'] * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: feature['importance'],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                  ),
                  if (feature['description'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      feature['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            )),
      ],
    );
  }
}
