import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class SnapshotScreen extends StatelessWidget {
  const SnapshotScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final milestones = _mockMilestones();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Snapshot'),
        actions: [
          IconButton(onPressed: () => _exportPdf(context, milestones), icon: const Icon(Icons.picture_as_pdf)),
          IconButton(
            onPressed: () async {
              final data = await _buildPdfBytes(milestones);
              await Printing.sharePdf(bytes: data, filename: 'snapshot.pdf');
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: milestones.length,
        itemBuilder: (final context, final i) {
          final m = milestones[i];
          return ListTile(
            leading: Icon(
              m.status == 'Done' ? Icons.check_circle : Icons.radio_button_unchecked,
              color: m.status == 'Done' ? Colors.green : null,
            ),
            title: Text(m.title),
            subtitle: Text(m.date),
          );
        },
      ),
    );
  }

  Future<void> _exportPdf(final BuildContext context, final List<_Milestone> m) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (final context) => pw.Column(
          children: [
            pw.Text('NDIS Plan Snapshot', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 12),
            for (final x in m)
              pw.Row(
                children: [
                  pw.Text(x.status == 'Done' ? '✓' : '•'),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: pw.Text(x.title)),
                  pw.Text(x.date),
                ],
              ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (final format) async => doc.save());
  }

  Future<Uint8List> _buildPdfBytes(final List<_Milestone> m) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (final context) => pw.Column(
          children: [
            pw.Text('NDIS Plan Snapshot', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 12),
            for (final x in m)
              pw.Row(
                children: [
                  pw.Text(x.status == 'Done' ? '✓' : '•'),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: pw.Text(x.title)),
                  pw.Text(x.date),
                ],
              ),
          ],
        ),
      ),
    );
    return Uint8List.fromList(await doc.save());
  }
}

class _Milestone {
  _Milestone(this.title, this.status, this.date);
  final String title;
  final String status;
  final String date;
}

List<_Milestone> _mockMilestones() => [
      _Milestone('Set 3 SMART goals', 'Done', 'Feb 05'),
      _Milestone('Book OT assessment', 'In Progress', 'Mar 11'),
      _Milestone('Review plan with coordinator', 'Todo', 'Apr 20'),
    ];

