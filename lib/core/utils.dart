import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:sorun_takip_sistemi/model/issue_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sorun_takip_sistemi/model/project_model.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 5),
      ),
    );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

Future<FilePickerResult?> pickFiles() async {
  final files = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    allowedExtensions: [
      'jpg',
      'pdf',
      'doc',
      'xml',
      'png',
      'xls',
      'xlsx',
      'docx',
      'txt'
    ],
    type: FileType.custom,
  );

  return files;
}

Future<void> createPDFforIssue(
    {required IssueModel issue, required BuildContext context}) async {
  try {
    final font = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Text(
                      issue.title,
                      style: pw.TextStyle(font: font, fontSize: 24),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Text(
                      issue.description,
                      style: pw.TextStyle(font: font, fontSize: 14),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Önem Derecesi : ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                        pw.Text("${issue.priority} ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Durum : ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                        pw.Text("${issue.status} ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Oluşturulma Tarihi : ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                        pw.Text(
                            "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.created)} ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Son Tarih : ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                        pw.Text(
                            "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.due)} ",
                            style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (issue.completed != null) ...[
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text("Tamamlanma Tarihi : ",
                              style: pw.TextStyle(font: font, fontSize: 14)),
                          pw.Text(
                              "${DateFormat('dd-MM-yyyy HH:mm a', 'tr').format(issue.completed!)} ",
                              style: pw.TextStyle(font: font, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ); // Center
          }),
    );
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/${issue.title}_${issue.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
    print(tempDir.path);
  } catch (e) {
    showSnackBar(
      context,
      e.toString(),
    );
  }
}

Future<void> createPDFforProject(
    {required ProjectModel project, required BuildContext context}) async {
  try {
    final font = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();

    final netImage = await networkImage(project.projectPic);

    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: pw.Image(netImage)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Text(
                      project.title,
                      style: pw.TextStyle(font: font, fontSize: 24),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: pw.Text(
                      project.description,
                      style: pw.TextStyle(font: font, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ); // Center
          }),
    );
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/${project.title}_${project.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
    print(tempDir.path);
  } catch (e) {
    showSnackBar(
      context,
      e.toString(),
    );
  }
}
