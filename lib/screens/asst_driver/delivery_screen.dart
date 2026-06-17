import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../models/shipment.dart';
import '../../providers/branch_provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'dart:io' as io;

class DeliveryScreen extends StatefulWidget {
  final Shipment shipment;

  const DeliveryScreen({super.key, required this.shipment});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isLocationVerified = false;
  bool _isLoading = false;
  XFile? _receiverPhoto;
  XFile? _idPhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _verifyLocation();
  }

  Future<void> _pickImage(bool isId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        if (isId) {
          _idPhoto = image;
        } else {
          _receiverPhoto = image;
        }
      });
    }
  }

  Future<void> _verifyLocation() async {
    setState(() => _isLoading = true);
    try {
      final branch = context.read<BranchProvider>().getBranchById(widget.shipment.destinationBranchId);
      if (branch == null) return;

      final position = await Geolocator.getCurrentPosition();
      
      // Haversine formula
      double distance = _calculateDistance(
        position.latitude, position.longitude,
        branch.latitude, branch.longitude
      );

      if (distance <= 0.5) { // 500 meters
        setState(() => _isLocationVerified = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are too far from the branch (${distance.toStringAsFixed(2)} km). Must be within 500m.'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not verify location. Please enable GPS.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deliver ${widget.shipment.trackingNumber}')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerificationStatus(),
                const SizedBox(height: 24),
                _buildPhotoSection(),
                const SizedBox(height: 24),
                const Text('Receiver Signature:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                  child: Signature(
                    controller: _controller,
                    height: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _controller.clear(),
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  label: const Text('Clear Signature', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLocationVerified ? _completeDelivery : null,
                    child: const Text('COMPLETE DELIVERY'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isLocationVerified ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _isLocationVerified ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(
            _isLocationVerified ? Icons.location_on : Icons.location_off,
            color: _isLocationVerified ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isLocationVerified 
                ? "Location Verified: You are within 500m of the branch." 
                : "Location Not Verified: You must be within 500m of the branch to deliver.",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: _isLocationVerified ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPhotoBox(
                label: 'Receiver Photo',
                file: _receiverPhoto,
                onTap: () => _pickImage(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPhotoBox(
                label: 'ID / Document',
                file: _idPhoto,
                onTap: () => _pickImage(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoBox({required String label, XFile? file, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb 
                        ? Image.network(file.path, fit: BoxFit.cover)
                        : Image.file(io.File(file.path), fit: BoxFit.cover),
                  )
                : const Icon(Icons.camera_alt, color: Colors.white70, size: 40),
          ),
        ),
      ],
    );
  }

  void _completeDelivery() async {
    if (_receiverPhoto == null || _idPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take both receiver and ID photos')),
      );
      return;
    }

    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signature is required')));
      return;
    }

    final shipmentProvider = context.read<ShipmentProvider>();
    final authProvider = context.read<AuthProvider>();

    // Check for COD
    if (widget.shipment.paymentMethod == PaymentMethod.cod || widget.shipment.paymentMethod == PaymentMethod.partialCod) {
      _showAsstDriverCodDialog(shipmentProvider, authProvider.user?.name ?? 'Asst Driver');
    } else {
      await shipmentProvider.updateShipmentStatus(
        widget.shipment.id, 
        ShipmentStatus.delivered,
        deliveredBy: authProvider.user?.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery successful!')));
        context.pop();
      }
    }
  }

  void _showAsstDriverCodDialog(ShipmentProvider provider, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Collect COD Payment'),
        content: Text('Amount to collect: ${widget.shipment.shippingCost} ${widget.shipment.currency}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await provider.updateShipmentStatus(
                widget.shipment.id, 
                ShipmentStatus.delivered,
                deliveredBy: name,
                amountCollected: widget.shipment.shippingCost,
              );
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment collected and delivery completed.')));
                context.pop();
              }
            },
            child: const Text('CONFIRM PAYMENT'),
          ),
        ],
      ),
    );
  }
}
