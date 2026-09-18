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

  // ============================================================
  // GET ALL CONTENT
  // GET /api/admin/content
  // ============================================================

  Future<void> _fetchContent() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/content',
      );

      debugPrint(
        'GET ADMIN CONTENT RESPONSE: $response',
      );

      final items = _extractContentList(response);

      debugPrint(
        'EXTRACTED CONTENT COUNT: ${items.length}',
      );

      if (!mounted) return;

      setState(() {
        _items = items;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      debugPrint(
        'GET ADMIN CONTENT API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      debugPrint(
        'GET ADMIN CONTENT ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load gallery content.';
      });
    }
  }

  // ============================================================
  // ROBUST RESPONSE EXTRACTION
  // Supports:
  //
  // [ ... ]
  //
  // { data: [ ... ] }
  //
  // { content: [ ... ] }
  //
  // { items: [ ... ] }
  //
  // { data: { content: [ ... ] } }
  // ============================================================

  List<Map<String, dynamic>> _extractContentList(
    dynamic response,
  ) {
    if (response is List) {
      return asMapList(response);
    }

    if (response is! Map) {
      return [];
    }

    final map = Map<String, dynamic>.from(
      response,
    );

    // ------------------------------------------
    // { data: [ ... ] }
    // ------------------------------------------

    final data = map['data'];

    if (data is List) {
      return asMapList(data);
    }

    // ------------------------------------------
    // { content: [ ... ] }
    // ------------------------------------------

    final content = map['content'];

    if (content is List) {
      return asMapList(content);
    }

    // ------------------------------------------
    // { items: [ ... ] }
    // ------------------------------------------

    final items = map['items'];

    if (items is List) {
      return asMapList(items);
    }

    // ------------------------------------------
    // { data: { content: [ ... ] } }
    // ------------------------------------------

    if (data is Map) {
      final nestedData = Map<String, dynamic>.from(
        data,
      );

      final nestedContent = nestedData['content'];

      if (nestedContent is List) {
        return asMapList(nestedContent);
      }

      final nestedItems = nestedData['items'];

      if (nestedItems is List) {
        return asMapList(nestedItems);
      }
    }

    return [];
  }

  // ============================================================
  // GET SINGLE CONTENT
  // GET /api/admin/content/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getContentById(
    num id,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/content/$id',
      );

      debugPrint(
        'GET CONTENT $id RESPONSE: $response',
      );

      if (response is! Map) {
        return null;
      }

      final map = Map<String, dynamic>.from(
        response,
      );

      // { data: {...} }

      if (map['data'] is Map) {
        return Map<String, dynamic>.from(
          map['data'] as Map,
        );
      }

      // { content: {...} }

      if (map['content'] is Map) {
        return Map<String, dynamic>.from(
          map['content'] as Map,
        );
      }

      // Direct object

      if (map.containsKey('id')) {
        return map;
      }

      return null;
    } on ApiException catch (e) {
      debugPrint(
        'GET CONTENT API ERROR: ${e.message}',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

      return null;
    } catch (e) {
      debugPrint(
        'GET CONTENT ERROR: $e',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load content details.',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<File?> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null) {
        return null;
      }

      final path = result.files.single.path;

      if (path == null || path.trim().isEmpty) {
        return null;
      }

      return File(path);
    } catch (e) {
      debugPrint(
        'IMAGE PICKER ERROR: $e',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to select the image.',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // EXTRACT CREATED CONTENT FROM POST RESPONSE
  // ============================================================

  Map<String, dynamic>? _extractCreatedContent(
    dynamic response,
  ) {
    if (response is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(
      response,
    );

    // Backend:
    //
    // {
    //   success: true,
    //   message: "...",
    //   data: {
    //      id,
    //      title,
    //      image,
    //      description
    //   }
    // }

    final data = map['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(
        data,
      );
    }

    if (map['content'] is Map) {
      return Map<String, dynamic>.from(
        map['content'] as Map,
      );
    }

    if (map.containsKey('id')) {
      return map;
    }

    return null;
  }

  // ============================================================
  // CREATE / EDIT CONTENT
  // ============================================================

  Future<void> _openDialog([
    Map<String, dynamic>? item,
  ]) async {
    final isEditing = item != null;

    final titleController = TextEditingController(
      text: isEditing
          ? asString(item['title'])
          : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing
          ? asString(item['description'])
          : '',
    );

    File? selectedFile;
    String? selectedFileName;

    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
            dialogCtx,
            setDialogState,
          ) {
            final existingImage = isEditing
                ? asString(item['image'])
                : '';

            final existingImageUrl =
                existingImage.isNotEmpty
                    ? ApiConfig.fileUrl(
                        existingImage,
                      )
                    : null;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing
                        ? Icons.edit_outlined
                        : Icons
                            .add_photo_alternate_outlined,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Edit Gallery Content'
                          : 'Add Gallery Content',
                    ),
                  ),
                ],
              ),

              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // TITLE
                        // ==================================================

                        TextFormField(
                          controller: titleController,
                          enabled: !saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Title *',
                            hintText:
                                'Enter post title',
                            prefixIcon: Icon(
                              Icons.title,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            return Validators.requiredField(
                              value,
                              label: 'Title',
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================

                        TextFormField(
                          controller:
                              descriptionController,
                          enabled: !saving,
                          maxLines: 5,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Description *',
                            hintText:
                                'Enter post description',
                            prefixIcon: Icon(
                              Icons.description_outlined,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            return Validators.requiredField(
                              value,
                              label: 'Description',
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // EXISTING IMAGE
                        // ==================================================

                        if (isEditing &&
                            existingImageUrl != null) ...[
                          Text(
                            'Current Image',
                            style: Theme.of(
                              dialogCtx,
                            )
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                          ),

                          const SizedBox(height: 8),

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 180,
                              child: NetworkImageSafe(
                                url: existingImageUrl,
                                width: double.infinity,
                                height: 180,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],

                        // ==================================================
                        // IMAGE BUTTON
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: saving
                                ? null
                                : () async {
                                    final file =
                                        await _pickImage();

                                    if (file == null) {
                                      return;
                                    }

                                    if (!dialogCtx
                                        .mounted) {
                                      return;
                                    }

                                    final fileName =
                                        file.path
                                            .split(
                                              Platform
                                                  .pathSeparator,
                                            )
                                            .last;

                                    setDialogState(() {
                                      selectedFile =
                                          file;
                                      selectedFileName =
                                          fileName;
                                    });
                                  },
                            icon: Icon(
                              isEditing
                                  ? Icons
                                      .image_outlined
                                  : Icons
                                      .add_photo_alternate_outlined,
                            ),
                            label: Text(
                              isEditing
                                  ? 'Change Image'
                                  : 'Pick Image *',
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // SELECTED FILE
                        // ==================================================

                        if (selectedFile != null)
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(
                              10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                              color: Theme.of(
                                dialogCtx,
                              )
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .check_circle_outline,
                                  color: Theme.of(
                                    dialogCtx,
                                  )
                                      .colorScheme
                                      .primary,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    selectedFileName ??
                                        'Image selected',
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            isEditing
                                ? 'Leave the image unchanged or select a new image.'
                                : 'An image is required.',
                            style: Theme.of(
                              dialogCtx,
                            )
                                .textTheme
                                .bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                // ==========================================================
                // CANCEL
                // ==========================================================

                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(
                            dialogCtx,
                          ).pop(false);
                        },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                // ==========================================================
                // SAVE
                // ==========================================================

                AppButton(
                  label: isEditing
                      ? 'Save Changes'
                      : 'Upload Content',
                  icon: isEditing
                      ? Icons.save_outlined
                      : Icons
                          .cloud_upload_outlined,
                  loading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          // ------------------------------
                          // VALIDATE FORM
                          // ------------------------------

                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          // ------------------------------
                          // CREATE REQUIRES IMAGE
                          // ------------------------------

                          if (!isEditing &&
                              selectedFile == null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select an image.',
                                ),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final api =
                                context.read<ApiService>();

                            final fields =
                                <String, String>{
                              'title':
                                  titleController.text
                                      .trim(),
                              'description':
                                  descriptionController
                                      .text
                                      .trim(),
                            };

                            dynamic response;

                            // ==================================================
                            // CREATE
                            // POST /api/admin/content
                            // ==================================================

                            if (!isEditing) {
                              response =
                                  await api.postMultipart(
                                '/api/admin/content',
                                fields: fields,
                                file: selectedFile,
                              );

                              debugPrint(
                                'CREATE CONTENT RESPONSE: $response',
                              );

                              final created =
                                  _extractCreatedContent(
                                response,
                              );

                              // ==================================================
                              // IMPORTANT
                              //
                              // Immediately put newly-created
                              // item into Flutter list.
                              // ==================================================

                              if (created != null &&
                                  created['id'] != null) {
                                if (mounted) {
                                  setState(() {
                                    _items.insert(
                                      0,
                                      created,
                                    );
                                  });
                                }
                              }
                            }

                            // ==================================================
                            // UPDATE
                            // PUT /api/admin/content/:id
                            // ==================================================

                            else {
                              final id =
                                  asNum(item['id']);

                              response =
                                  await api.putMultipart(
                                '/api/admin/content/$id',
                                fields: fields,
                                file: selectedFile,
                              );

                              debugPrint(
                                'UPDATE CONTENT RESPONSE: $response',
                              );
                            }

                            // ==================================================
                            // CLOSE DIALOG
                            // ==================================================

                            if (!dialogCtx.mounted) {
                              return;
                            }

                            Navigator.of(
                              dialogCtx,
                            ).pop(true);
                          } on ApiException catch (e) {
                            debugPrint(
                              'CONTENT API ERROR: ${e.message}',
                            );

                            if (!dialogCtx.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content:
                                    Text(e.message),
                              ),
                            );
                          } catch (e) {
                            debugPrint(
                              'CONTENT ERROR: $e',
                            );

                            if (!dialogCtx.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to save gallery content.',
                                ),
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );

    // ============================================================
    // DIALOG CLOSED
    // ============================================================

    if (saved == true && mounted) {
      await _fetchContent();
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _editContent(
    Map<String, dynamic> item,
  ) async {
    final id = asNum(
      item['id'],
    );

    final content = await _getContentById(
      id,
    );

    if (!mounted || content == null) {
      return;
    }

    await _openDialog(
      content,
    );
  }

  // ============================================================
  // DELETE
  // DELETE /api/admin/content/:id
  // ============================================================

  Future<void> _deleteContent(
    num id,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Gallery Content',
          ),
          content: const Text(
            'Are you sure you want to permanently delete this content?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final api =
          context.read<ApiService>();

      await api.delete(
        '/api/admin/content/$id',
      );

      if (!mounted) return;

      // Remove immediately from UI.
      setState(() {
        _items.removeWhere(
          (item) =>
              _idString(item['id']) ==
              _idString(id),
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Gallery content deleted successfully.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      debugPrint(
        'DELETE CONTENT ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete gallery content.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAFE ID
  // ============================================================

  String _idString(
    dynamic value,
  ) {
    return value?.toString() ?? '';
  }

  // ============================================================
  // CONTENT CARD
  // ============================================================

  Widget _buildContentCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final id =
        asNum(item['id']);

    final title =
        asString(
      item['title'],
      'Untitled',
    );

    final description =
        asString(
      item['description'],
      'No description',
    );

    final rawImage =
        asString(
      item['image'],
    );

    final imageUrl =
        rawImage.isNotEmpty
            ? ApiConfig.fileUrl(
                rawImage,
              )
            : '';

    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final small =
                constraints.maxWidth < 600;

            // ==========================================================
            // MOBILE
            // ==========================================================

            if (small) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 190,
                      child: imageUrl.isNotEmpty
                          ? NetworkImageSafe(
                              url: imageUrl,
                              width: double.infinity,
                              height: 190,
                            )
                          : Container(
                              color: scheme
                                  .surfaceContainerHighest,
                              child: const Icon(
                                Icons
                                    .image_not_supported_outlined,
                                size: 45,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    description,
                    maxLines: 4,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () =>
                            _editContent(
                          item,
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () =>
                            _deleteContent(
                          id,
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ==========================================================
            // DESKTOP
            // ==========================================================

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: imageUrl.isNotEmpty
                        ? NetworkImageSafe(
                            url: imageUrl,
                            width: 120,
                            height: 120,
                          )
                        : Container(
                            color: scheme
                                .surfaceContainerHighest,
                            child: const Icon(
                              Icons
                                  .image_not_supported_outlined,
                              size: 40,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        description,
                        maxLines: 4,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                IconButton(
                  tooltip: 'Edit',
                  onPressed: () =>
                      _editContent(
                    item,
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: () =>
                      _deleteContent(
                    id,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 42,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons
                    .photo_library_outlined,
                size: 54,
                color: scheme.primary,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                'No gallery content published yet.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Create your first gallery post using the Upload Post button.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              AppButton(
                label:
                    'Upload First Post',
                icon: Icons
                    .add_photo_alternate_outlined,
                onPressed: () =>
                    _openDialog(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 44,
              color: Colors.red,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              _error ??
                  'Failed to load gallery content.',
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 14,
            ),

            OutlinedButton.icon(
              onPressed:
                  _fetchContent,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final padding =
        Responsive.pagePadding(
      context,
    );

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // HEADER
              // ==========================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final small =
                      constraints.maxWidth <
                          650;

                  if (small) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Public Gallery & Content',
                          style: theme
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        const Text(
                          'Upload photos and posts displayed on the landing page gallery.',
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        AppButton(
                          label:
                              'Upload Post',
                          icon: Icons
                              .add_photo_alternate_outlined,
                          onPressed: () =>
                              _openDialog(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Public Gallery & Content',
                              style: theme
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            const Text(
                              'Upload photos and posts displayed on the landing page gallery.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      AppButton(
                        label:
                            'Upload Post',
                        icon: Icons
                            .add_photo_alternate_outlined,
                        onPressed: () =>
                            _openDialog(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 24,
              ),

              // ==========================================================
              // CONTENT AREA ONLY
              //
              // IMPORTANT:
              // DO NOT WRAP THE WHOLE PAGE IN AsyncStateView.
              // ==========================================================

              if (_loading)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(40),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                _buildErrorState(
                  context,
                )
              else if (_items.isEmpty)
                _buildEmptyState(
                  context,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _items.length,
                  separatorBuilder:
                      (
                    _,
                    __,
                  ) =>
                          const SizedBox(
                    height: 14,
                  ),
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    return _buildContentCard(
                      context,
                      _items[index],
                    );
                  },
                ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}