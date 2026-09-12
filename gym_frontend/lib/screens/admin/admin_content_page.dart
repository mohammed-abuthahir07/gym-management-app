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

  // ======================================================
  // FETCH ALL CONTENT
  // ======================================================

  Future<void> _fetchContent() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      final res = await api.get('/api/admin/content');

      List<dynamic> list = [];

      if (res is Map && res['data'] is List) {
        list = res['data'] as List;
      } else if (res is Map && res['content'] is List) {
        list = res['content'] as List;
      } else if (res is List) {
        list = res;
      }

      if (!mounted) return;

      setState(() {
        _items = asMapList(list);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load gallery content.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ======================================================
  // PICK IMAGE
  // ======================================================

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
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select the image.'),
        ),
      );

      return null;
    }
  }

  // ======================================================
  // CREATE / EDIT CONTENT DIALOG
  // ======================================================

  Future<void> _openDialog([
    Map<String, dynamic>? item,
  ]) async {
    final bool isEditing = item != null;

    final titleCtrl = TextEditingController(
      text: isEditing ? asString(item['title']) : '',
    );

    final descCtrl = TextEditingController(
      text: isEditing ? asString(item['description']) : '',
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
            final existingImage = isEditing
                ? asString(item['image'])
                : '';

            final existingImageUrl =
                existingImage.isNotEmpty
                    ? ApiConfig.fileUrl(existingImage)
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
                        // ------------------------------------
                        // TITLE
                        // ------------------------------------

                        TextFormField(
                          controller: titleCtrl,
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
                          validator: (value) =>
                              Validators.requiredField(
                            value,
                            label: 'Title',
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ------------------------------------
                        // DESCRIPTION
                        // ------------------------------------

                        TextFormField(
                          controller: descCtrl,
                          enabled: !saving,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText: 'Description *',
                            hintText:
                                'Enter content description',
                            isDense: true,
                          ),
                          validator: (value) =>
                              Validators.requiredField(
                            value,
                            label: 'Description',
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------
                        // EXISTING IMAGE
                        // ------------------------------------

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
                                BorderRadius.circular(10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 160,
                              child: NetworkImageSafe(
                                url: existingImageUrl,
                                width: double.infinity,
                                height: 160,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],

                        // ------------------------------------
                        // PICK IMAGE
                        // ------------------------------------

                        OutlinedButton.icon(
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
                          onPressed: saving
                              ? null
                              : () async {
                                  final file =
                                      await _pickImage();

                                  if (file == null) {
                                    return;
                                  }

                                  if (!dialogCtx.mounted) {
                                    return;
                                  }

                                  setDialogState(() {
                                    selectedFile =
                                        file;
                                    selectedFileName =
                                        file.path
                                            .split(
                                              Platform
                                                  .pathSeparator,
                                            )
                                            .last;
                                  });
                                },
                        ),

                        const SizedBox(height: 8),

                        // ------------------------------------
                        // SELECTED FILE NAME
                        // ------------------------------------

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
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
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

              actions: [
                // ------------------------------------------
                // CANCEL
                // ------------------------------------------

                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(
                            dialogCtx,
                          ).pop(false);
                        },
                  child: const Text('Cancel'),
                ),

                // ------------------------------------------
                // SAVE
                // ------------------------------------------

                AppButton(
                  loading: saving,
                  label: isEditing
                      ? 'Save Changes'
                      : 'Upload Content',
                  onPressed: () async {
                    // -------------------------------
                    // VALIDATE FORM
                    // -------------------------------

                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    // -------------------------------
                    // IMAGE REQUIRED FOR CREATE
                    // -------------------------------

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

                    // -------------------------------
                    // START SAVING
                    // -------------------------------

                    setDialogState(() {
                      saving = true;
                    });

                    try {
                      final api =
                          context.read<ApiService>();

                      final fields =
                          <String, String>{
                        'title':
                            titleCtrl.text.trim(),
                        'description':
                            descCtrl.text.trim(),
                      };

                      // -----------------------------
                      // EDIT
                      // -----------------------------

                      if (isEditing) {
                        await api.putMultipart(
                          '/api/admin/content/${item['id']}',
                          fields: fields,
                          file: selectedFile,
                        );
                      }

                      // -----------------------------
                      // CREATE
                      // -----------------------------

                      else {
                        await api.postMultipart(
                          '/api/admin/content',
                          fields: fields,
                          file: selectedFile,
                        );
                      }

                      // IMPORTANT:
                      //
                      // Do NOT call setDialogState here.
                      //
                      // First close the dialog.
                      // Then refresh outside the dialog.

                      if (!dialogCtx.mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogCtx,
                      ).pop(true);
                    } on ApiException catch (e) {
                      // API failed.
                      //
                      // Dialog is still open,
                      // so it is safe to change dialog state.

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
                          content: Text(e.message),
                        ),
                      );
                    } catch (e) {
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

    // ====================================================
    // VERY IMPORTANT
    //
    // Dialog is completely closed here.
    // Now refresh the page.
    // ====================================================

    if (saved == true && mounted) {
      await _fetchContent();
    }

    // ====================================================
    // DISPOSE CONTROLLERS AFTER DIALOG COMPLETES
    // ====================================================

    titleCtrl.dispose();
    descCtrl.dispose();
  }

  // ======================================================
  // DELETE CONTENT
  // ======================================================

  Future<void> _deleteContent(num id) async {
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
              child: const Text('Cancel'),
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
              child: const Text('Delete'),
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
          content: Text(e.message),
        ),
      );
    } catch (e) {
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

  // ======================================================
  // CONTENT CARD
  // ======================================================

  Widget _buildContentCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final theme = Theme.of(context);

    final id = asNum(item['id']);

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool small =
                constraints.maxWidth < 600;

            // ==================================================
            // MOBILE / SMALL WIDTH
            // ==================================================

            if (small) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: NetworkImageSafe(
                          url: imageUrl,
                          width: double.infinity,
                          height: 180,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    maxLines: 3,
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

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        onPressed: () =>
                            _openDialog(item),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _deleteContent(id),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ==================================================
            // DESKTOP / LARGE WIDTH
            // ==================================================

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                // ----------------------------------------------
                // IMAGE
                // ----------------------------------------------

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: imageUrl.isNotEmpty
                        ? NetworkImageSafe(
                            url: imageUrl,
                            width: 100,
                            height: 100,
                          )
                        : Container(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(
                              Icons
                                  .image_not_supported_outlined,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // ----------------------------------------------
                // TEXT
                // ----------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        description,
                        maxLines: 3,
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

                // ----------------------------------------------
                // EDIT
                // ----------------------------------------------

                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: () =>
                      _openDialog(item),
                ),

                // ----------------------------------------------
                // DELETE
                // ----------------------------------------------

                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () =>
                      _deleteContent(id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final padding =
        Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchContent,
      isEmpty: _items.isEmpty,
      emptyMessage:
          'No gallery content published yet.',
      child: SingleChildScrollView(
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
                // ==================================================
                // HEADER
                // ==================================================

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

                          const SizedBox(height: 5),

                          const Text(
                            'Upload photos and posts displayed on the landing page gallery.',
                          ),

                          const SizedBox(height: 14),

                          AppButton(
                            label: 'Upload Post',
                            icon: Icons
                                .add_photo_alternate_outlined,
                            onPressed:
                                () => _openDialog(),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center,
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
                                      FontWeight
                                          .bold,
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

                        const SizedBox(width: 16),

                        AppButton(
                          label: 'Upload Post',
                          icon: Icons
                              .add_photo_alternate_outlined,
                          onPressed:
                              () => _openDialog(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // CONTENT LIST
                // ==================================================

                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (
                    _,
                    __,
                  ) =>
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
      ),
    );
  }
}