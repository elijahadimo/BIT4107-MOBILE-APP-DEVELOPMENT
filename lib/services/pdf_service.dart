import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shipment.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generateReceipt(Shipment shipment) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(shipment.createdAt);

    // Page 1: Sender Copy
    pdf.addPage(_buildReceiptPage(shipment, dateStr, "Sender"));
    // Page 2: Receiver Copy
    pdf.addPage(_buildReceiptPage(shipment, dateStr, "Receiver"));

    return pdf.save();
  }

  static pw.Page _buildReceiptPage(Shipment shipment, String dateStr, String copyType) {
    return pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('KAPOETA LOGISTICS',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text('Official Receipt ($copyType Copy)')),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tracking No:'),
                  pw.Text(shipment.trackingNumber, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:'),
                  pw.Text(dateStr),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Item: ${shipment.itemDescription}'),
              pw.Text('Weight: ${shipment.weight} kg'),
              pw.Text('Value: ${shipment.goodsValue} ${shipment.currency}'),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sender:'),
                  pw.Text(shipment.senderName),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receiver:'),
                  pw.Text(shipment.receiverName),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL PAID:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${shipment.shippingCost} ${shipment.currency}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text('Payment Method: ${shipment.paymentMethod.name.toUpperCase()}'),
              pw.Spacer(),
              pw.Center(child: pw.Text('Thank you for choosing Kapoeta Logistics!', style: const pw.TextStyle(fontSize: 10))),
            ],
          ),
        );
      },
    );
  }

  static Future<Uint8List> generateWaybill(Shipment shipment) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(shipment.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('KAPOETA LOGISTICS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('WAYBILL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Text(shipment.trackingNumber),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SENDER', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Divider(),
                          pw.Text('Name: ${shipment.senderName}'),
                          pw.Text('Phone: ${shipment.senderPhone}'),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 40),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('RECEIVER', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Divider(),
                          pw.Text('Name: ${shipment.receiverName}'),
                          pw.Text('Phone: ${shipment.receiverPhone}'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('SHIPMENT INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Item Description:'),
                    pw.Text(shipment.itemDescription),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Weight:'),
                    pw.Text('${shipment.weight} kg'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Declared Value:'),
                    pw.Text('${shipment.goodsValue} ${shipment.currency}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Origin Branch:'),
                    pw.Text(shipment.originBranchId),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Destination Branch:'),
                    pw.Text(shipment.destinationBranchId),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  height: 100,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Center(child: pw.Text('OFFICE USE ONLY / STAMP')),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 150, border: const pw.Border(bottom: pw.BorderSide())),
                        pw.Text('Agent Signature'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 150, border: const pw.Border(bottom: pw.BorderSide())),
                        pw.Text('Driver Signature'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> saveAndShare(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Document from Kapoeta Logistics');
  }

  static Future<void> printDoc(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<Uint8List> generateQrLabel(Shipment shipment) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(5 * PdfPageFormat.cm, 5 * PdfPageFormat.cm),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('KAPOETA', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: shipment.trackingNumber,
                  width: 80,
                  height: 80,
                ),
                pw.Text(shipment.trackingNumber, style: const pw.TextStyle(fontSize: 6)),
                pw.Text('To: ${shipment.destinationBranchId}', style: const pw.TextStyle(fontSize: 6)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
