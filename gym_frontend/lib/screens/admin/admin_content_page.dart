import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/content');
      List<dynamic> list = [];
      if (res is Map && res['data'] is List) {
        list = res['data'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _items = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load gallery content.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final titleCtrl = TextEditingController(text: isEditing ? asString(item['title']) : '');
    final descCtrl = TextEditingController(text: isEditing ? asString(item['description']) : '');
    File? selectedFile;
    String? selectedFileName;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Gallery Post' : 'Add Gallery Content'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(labelText: 'Title *'),
                          validator: (v) => Validators.requiredField(v, label: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Description *'),
                          validator: (v) => Validators.requiredField(v, label: 'Description'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.attach_file),
                              label: Text(isEditing ? 'Change Image' : 'Pick Image *'),
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                                if (result != null && result.files.single.path != null) {
                                  setDialogState(() {
                                    selectedFile = File(result.files.single.path!);
                                    selectedFileName = result.files.single.name;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedFileName ?? (isEditing ? 'Keeping existing photo' : 'No photo picked'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: saving,
                  label: isEditing ? 'Save Changes' : 'Upload Content',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    if (!isEditing && selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an image file to upload.')),
                      );
                      return;
                    }

                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final fields = {
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                      };

                      if (isEditing) {
                        await api.putMultipart(
                          '/api/admin/content/${item['id']}',
                          fields: fields,
                          file: selectedFile,
                        );
                      } else {
                        await api.postMultipart(
                          '/api/admin/content',
                          fields: fields,
                          file: selectedFile,
                        );
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchContent();
                    } on ApiException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    } finally {
                      if (dialogCtx.mounted) setDialogState(() => saving = false);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteContent(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to remove this gallery post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final api = context.read<ApiService>();
      await api.delete('/api/admin/content/$id');
      _fetchContent();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchContent,
      isEmpty: _items.isEmpty,
      emptyMessage: 'No gallery content published yet.',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Public Gallery & Content', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Upload photos and posts displayed on the landing page gallery.'),
                      ],
                    ),
                    AppButton(
                      label: 'Upload Post',
                      icon: Icons.add_photo_alternate_outlined,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, idx) {
                    final item = _items[idx];
                    final id = asNum(item['id']);
                    final title = asString(item['title']);
                    final desc = asString(item['description']);
                    final rawImg = asString(item['image']);
                    final imgUrl = ApiConfig.fileUrl(rawImg);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: NetworkImageSafe(url: imgUrl, height: 80, width: 80),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteContent(id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
