import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cms_provider.dart';

class CmsEditScreen extends StatelessWidget {
  const CmsEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();
    final titleController = TextEditingController(text: cms.content.title);
    final subtitleController = TextEditingController(text: cms.content.subtitle);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Landing Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Subtitle')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<CmsProvider>().updateContent(titleController.text, subtitleController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content updated')));
              },
              child: const Text('UPDATE HEADERS'),
            ),
            const Divider(height: 64),
            const Text('Manage Notices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cms.content.notices.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(cms.content.notices[index], style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => context.read<CmsProvider>().removeNotice(index),
                ),
              ),
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Add new notice...'),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  context.read<CmsProvider>().addNotice(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
