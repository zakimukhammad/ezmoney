import 'package:flutter/material.dart';
import '../../../data/services/data_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DataService dataService = DataService();

    return SafeArea(
      child: ListView(
        children: [
          const ListTile(
            title: Text(
              "Data Management",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Export to Excel"),
            subtitle: const Text("Save transactions to Downloads folder"),
            onTap: () {
              dataService.exportToExcel();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text("Import from Excel"),
            subtitle: const Text("Restore data from Excel file"),
            onTap: () {
              dataService.importFromExcel();
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("EzMoney v1.0.0"),
          ),
        ],
      ),
    );
  }
}
