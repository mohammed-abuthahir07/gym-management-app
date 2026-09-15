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

      List<dynamic> list = [];

      if (response is Map) {
        // Possible backend response:
        // { "content": [...] }

        if (response['content'] is List) {
          list = response['content'];
        }

        // Possible backend response:
        // { "data": [...] }

        else if (response['data'] is List) {
          list = response['data'];
        }
      } else if (response is List) {
        list = response;
      }

      if (!mounted) return;

      setState(() {
        _items = asMapList(list);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load gallery content.';
        _loading = false;
      });
    }
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

      if (response is Map) {
        if (response['content'] is Map) {
          return Map<String, dynamic>.from(
            response['content'] as Map,
          );
        }

        if (response['data'] is Map) {
          return Map<String, dynamic>.from(
            response['data'] as Map,
          );
        }
      }

      return null;
    } on ApiException catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

      return null;
    } catch (_) {
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
    } catch (_) {
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
  // CREATE CONTENT
  // POST /api/admin/content
  //
  // EDIT CONTENT
  // PUT /api/admin/content/:id
  // ============================================================

  Future<void> _openDialog([
    Map<String, dynamic>? item,
  ]) async {
    final bool isEditing = item != null;

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

    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
            dialogCtx,
            setDialogState,
          ) {
            final String existingImage =
                isEditing
                    ? asString(item['image'])
                    : '';

            final String? existingImageUrl =
                existingImage.isNotEmpty
                    ? ApiConfig.fileUrl(
                        existingImage,
                      )
                    : null;

            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Gallery Content'
                    : 'Add Gallery Content',
              ),

              content: SizedBox(
                width: 460,
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
                                'e.g. Summer Fitness Tips',
                            isDense: true,
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
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText: 'Description *',
                            hintText:
                                'Enter content description',
                            isDense: true,
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
                            style: Theme.of(dialogCtx)
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
                              height: 170,
                              child: NetworkImageSafe(
                                url: existingImageUrl,
                                width: double.infinity,
                                height: 170,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],

                        // ==================================================
                        // PICK IMAGE
                        // ==================================================

                        OutlinedButton.icon(
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

                        const SizedBox(height: 8),

                        // ==================================================
                        // SELECTED FILE
                        // ==================================================

                        if (selectedFile != null)
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .check_circle_outline,
                                size: 18,
                                color: Theme.of(
                                  dialogCtx,
                                )
                                    .colorScheme
                                    .primary,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  selectedFileName ??
                                      selectedFile!
                                          .path
                                          .split(
                                            Platform
                                                .pathSeparator,
                                          )
                                          .last,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            isEditing
                                ? 'Existing image will be kept if you do not select a new image.'
                                : 'Please select an image.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                dialogCtx,
                              )
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ============================================================
              // ACTIONS
              // ============================================================

              actions: [
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

                AppButton(
                  loading: saving,
                  label: isEditing
                      ? 'Save Changes'
                      : 'Upload Content',
                  onPressed: () async {
                    // ======================================================
                    // FORM VALIDATION
                    // ======================================================

                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    // ======================================================
                    // IMAGE REQUIRED FOR CREATE
                    // ======================================================

                    if (!isEditing &&
                        selectedFile == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select an image file.',
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

                      // ====================================================
                      // UPDATE
                      // PUT /api/admin/content/:id
                      // ====================================================

                      if (isEditing) {
                        final id = asNum(
                          item['id'],
                        );

                        await api.putMultipart(
                          '/api/admin/content/$id',
                          fields: fields,
                          file: selectedFile,
                        );
                      }

                      // ====================================================
                      // CREATE
                      // POST /api/admin/content
                      // ====================================================

                      else {
                        await api.postMultipart(
                          '/api/admin/content',
                          fields: fields,
                          file: selectedFile,
                        );
                      }

                      // ====================================================
                      // CLOSE DIALOG FIRST
                      // ====================================================

                      if (!dialogCtx.mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogCtx,
                      ).pop(true);
                    } on ApiException catch (e) {
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
                          content: Text(
                            e.message,
                          ),
                        ),
                      );
                    } catch (_) {
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
    // DIALOG IS CLOSED
    // NOW REFRESH
    // ============================================================

    if (saved == true && mounted) {
      await _fetchContent();
    }

    // ============================================================
    // DISPOSE CONTROLLERS
    // ============================================================

    titleController.dispose();
    descriptionController.dispose();
  }

  // ============================================================
  // EDIT CONTENT
  //
  // First call:
  // GET /api/admin/content/:id
  //
  // Then PUT:
  // PUT /api/admin/content/:id
  // ============================================================

  Future<void> _editContent(
    Map<String, dynamic> item,
  ) async {
    final id = asNum(item['id']);

    final content = await _getContentById(id);

    if (!mounted) return;

    if (content == null) {
      return;
    }

    await _openDialog(content);
  }

  // ============================================================
  // DELETE CONTENT
  // DELETE /api/admin/content/:id
  // ============================================================

  Future<void> _deleteContent(
    num id,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Gallery Content',
          ),
          content: const Text(
            'Are you sure you want to permanently delete this gallery content?\n\n'
            'This action cannot be undone.',
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
      final api = context.read<ApiService>();

      await api.delete(
        '/api/admin/content/$id',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gallery content deleted successfully.',
          ),
        ),
      );

      await _fetchContent();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete gallery content.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CONTENT CARD
  // ============================================================

  Widget _buildContentCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final id = asNum(
      item['id'],
    );

    final title = asString(
      item['title'],
      'Untitled',
    );

    final description = asString(
      item['description'],
      'No description',
    );

    final rawImage = asString(
      item['image'],
    );

    final imageUrl = rawImage.isNotEmpty
        ? ApiConfig.fileUrl(rawImage)
        : '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool small =
                constraints.maxWidth < 600;

            // ==========================================================
            // MOBILE
            // ==========================================================

            if (small) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // IMAGE

                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 190,
                        child: NetworkImageSafe(
                          url: imageUrl,
                          width: double.infinity,
                          height: 190,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 190,
                      decoration: BoxDecoration(
                        color: scheme
                            .surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .image_not_supported_outlined,
                        size: 40,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // TITLE

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // DESCRIPTION

                  Text(
                    description,
                    maxLines: 4,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme
                          .textTheme
                          .bodySmall
                          ?.color,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ACTIONS

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () =>
                            _editContent(item),
                        icon: const Icon(
                          Icons
                              .edit_outlined,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () =>
                            _deleteContent(id),
                        icon: const Icon(
                          Icons
                              .delete_outline,
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
                // IMAGE

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: imageUrl.isNotEmpty
                        ? NetworkImageSafe(
                            url: imageUrl,
                            width: 110,
                            height: 110,
                          )
                        : Container(
                            color: scheme
                                .surfaceContainerHighest,
                            child: const Icon(
                              Icons
                                  .image_not_supported_outlined,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // TEXT

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

                      const SizedBox(height: 6),

                      Text(
                        description,
                        maxLines: 4,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // EDIT

                IconButton(
                  tooltip: 'Edit',
                  onPressed: () =>
                      _editContent(item),
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                // DELETE

                IconButton(
                  tooltip: 'Delete',
                  onPressed: () =>
                      _deleteContent(id),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 40,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons
                    .photo_library_outlined,
                size: 52,
                color: scheme.primary,
              ),

              const SizedBox(height: 14),

              Text(
                'No gallery content published yet.',
                textAlign: TextAlign.center,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Click "Upload Post" above to create the first gallery content.',
                textAlign: TextAlign.center,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 18),

              AppButton(
                label: 'Upload First Post',
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
              color: Colors.red,
            ),

            const SizedBox(height: 10),

            Text(
              _error ??
                  'Failed to load content.',
              textAlign: TextAlign.center,
              style: theme
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: _fetchContent,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding =
        Responsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
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
              // ========================================================
              // HEADER
              // ========================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool small =
                      constraints.maxWidth < 650;

                  if (small) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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

                        const SizedBox(height: 5),

                        const Text(
                          'Upload photos and posts displayed on the landing page gallery.',
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // THIS BUTTON ALWAYS SHOWS
                        // EVEN WHEN DATABASE IS EMPTY
                        // ==================================================

                        AppButton(
                          label: 'Upload Post',
                          icon: Icons
                              .add_photo_alternate_outlined,
                          onPressed: () =>
                              _openDialog(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
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
                              height: 5,
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

                      // ==================================================
                      // CREATE BUTTON
                      // ==================================================

                      AppButton(
                        label: 'Upload Post',
                        icon: Icons
                            .add_photo_alternate_outlined,
                        onPressed: () =>
                            _openDialog(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==========================================================
              // LOADING
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

              // ==========================================================
              // ERROR
              // ==========================================================

              else if (_error != null)
                _buildErrorState(
                  context,
                )

              // ==========================================================
              // DATABASE EMPTY
              //
              // IMPORTANT:
              // HEADER + UPLOAD BUTTON ARE STILL VISIBLE
              // ==========================================================

              else if (_items.isEmpty)
                _buildEmptyState(
                  context,
                )

              // ==========================================================
              // CONTENT EXISTS
              // ==========================================================

              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _items.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(
                    height: 14,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _buildContentCard(
                      context,
                      _items[index],
                    );
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}