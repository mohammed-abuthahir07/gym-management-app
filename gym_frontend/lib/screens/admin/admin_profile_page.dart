import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _admin;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchProfile();
      }
    });
  }

  // ============================================================
  // FETCH ADMIN PROFILE
  // ============================================================

  Future<void> _fetchProfile() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final auth = context.read<AuthController>();

    try {
      final response = await api.get(
        '/api/admin/auth/profile',
      );

      if (!mounted) return;

      if (response is Map) {
        final res = Map<String, dynamic>.from(response);

        if (res['admin'] is Map) {
          _admin = Map<String, dynamic>.from(
            res['admin'] as Map,
          );
        } else {
          _admin = auth.user;
        }
      } else {
        _admin = auth.user;
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      _admin = auth.user;
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // EDIT ADMIN PROFILE
  // ============================================================

  Future<void> _openEditProfileDialog() async {
    if (!mounted) return;

    if (_admin == null) {
      _showMessage(
        'Admin profile is not available.',
        error: true,
      );
      return;
    }

    final nameController = TextEditingController(
      text: asString(_admin?['name']),
    );

    final emailController = TextEditingController(
      text: asString(_admin?['email']),
    );

    final phoneController = TextEditingController(
      text: asString(_admin?['phone']),
    );

    final formKey = GlobalKey<FormState>();

    bool saving = false;
    bool updatedSuccessfully = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Edit Admin Profile',
                    ),
                  ),
                ],
              ),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ------------------------------------------------
                        // NAME
                        // ------------------------------------------------

                        TextFormField(
                          controller: nameController,
                          enabled: !saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Name *',
                            prefixIcon: Icon(
                              Icons.person_outline,
                            ),
                          ),
                          validator: (value) {
                            final name =
                                value?.trim() ?? '';

                            if (name.isEmpty) {
                              return 'Name is required';
                            }

                            if (name.length < 2) {
                              return 'Name must contain at least 2 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------------
                        // EMAIL
                        // ------------------------------------------------

                        TextFormField(
                          controller: emailController,
                          enabled: !saving,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText: 'Email *',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                          ),
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Email is required';
                            }

                            final emailRegex = RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            );

                            if (!emailRegex
                                .hasMatch(email)) {
                              return 'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------------
                        // PHONE
                        // ------------------------------------------------

                        TextFormField(
                          controller: phoneController,
                          enabled: !saving,
                          keyboardType:
                              TextInputType.phone,
                          textInputAction:
                              TextInputAction.done,
                          decoration:
                              const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                            ),
                          ),
                          validator: (value) {
                            final phone =
                                value?.trim() ?? '';

                            if (phone.isEmpty) {
                              return null;
                            }

                            final phoneRegex = RegExp(
                              r'^[0-9+\-\s()]{7,20}$',
                            );

                            if (!phoneRegex
                                .hasMatch(phone)) {
                              return 'Enter a valid phone number';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actionsPadding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16,
              ),

              actions: [
                // ------------------------------------------------------
                // CANCEL
                // ------------------------------------------------------

                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          if (dialogContext.mounted) {
                            Navigator.of(
                              dialogContext,
                            ).pop();
                          }
                        },
                  child: const Text('Cancel'),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------------
                // SAVE
                // ------------------------------------------------------

                AppButton(
                  label: 'Save Changes',
                  icon: Icons.save_outlined,
                  loading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          final name =
                              nameController.text.trim();

                          final email =
                              emailController.text.trim();

                          final phone =
                              phoneController.text.trim();

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final api =
                                context.read<ApiService>();

                            final response =
                                await api.put(
                              '/api/admin/profile',
                              body: {
                                'name': name,
                                'email': email,
                                'phone': phone.isEmpty
                                    ? null
                                    : phone,
                              },
                            );

                            // ------------------------------------------
                            // UPDATE LOCAL PROFILE FROM API RESPONSE
                            // ------------------------------------------

                            if (response is Map) {
                              final res =
                                  Map<String, dynamic>.from(
                                response,
                              );

                              if (res['admin'] is Map) {
                                _admin =
                                    Map<String, dynamic>.from(
                                  res['admin'] as Map,
                                );
                              }
                            }

                            updatedSuccessfully = true;

                            // ------------------------------------------
                            // CLOSE DIALOG
                            // ------------------------------------------

                            if (dialogContext.mounted) {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            }
                          } on ApiException catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            _showDialogError(
                              context,
                              e.message,
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            _showDialogError(
                              context,
                              'Failed to update admin profile.',
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

    // ================================================================
    // DISPOSE CONTROLLERS
    // ================================================================

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    // ================================================================
    // REFRESH PROFILE AFTER SUCCESS
    //
    // IMPORTANT:
    // Do NOT show a snackbar here using the old page context.
    // That was causing:
    //
    // "Looking up a deactivated widget's ancestor is unsafe"
    // ================================================================

    if (updatedSuccessfully && mounted) {
      await _fetchProfile();
    }
  }

  // ============================================================
  // DIALOG ERROR
  // ============================================================

  void _showDialogError(
    BuildContext dialogContext,
    String message,
  ) {
    if (!dialogContext.mounted) return;

    final messenger =
        ScaffoldMessenger.maybeOf(dialogContext);

    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  // ============================================================
  // NORMAL MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final messenger =
          ScaffoldMessenger.maybeOf(context);

      if (messenger == null) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                error ? Colors.red : null,
          ),
        );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding =
        Responsive.pagePadding(context);

    final name = asString(
      _admin?['name'],
      'System Administrator',
    );

    final email = asString(
      _admin?['email'],
    );

    final phone = asString(
      _admin?['phone'],
    );

    final status = asString(
      _admin?['status'],
      'ACTIVE',
    );

    final createdAt = asString(
      _admin?['created_at'],
    );

    final joined = createdAt.isNotEmpty
        ? createdAt.split('T').first
        : '';

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchProfile,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 850,
              ),
              child: Card(
                clipBehavior:
                    Clip.antiAlias,
                child: Padding(
                  padding:
                      const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // PROFILE HEADER
                      // ==================================================

                      LayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          if (constraints.maxWidth <
                              550) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor:
                                          scheme.primary,
                                      child:
                                          const Icon(
                                        Icons
                                            .admin_panel_settings,
                                        color:
                                            Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines:
                                                2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style: theme
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            'Head Administrator / Owner',
                                            style: theme
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          StatusBadge(
                                            label:
                                                status,
                                            positive:
                                                status ==
                                                    'ACTIVE',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                SizedBox(
                                  width:
                                      double.infinity,
                                  child: AppButton(
                                    label:
                                        'Edit Profile',
                                    icon: Icons
                                        .edit_outlined,
                                    onPressed:
                                        _openEditProfileDialog,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor:
                                    scheme.primary,
                                child:
                                    const Icon(
                                  Icons
                                      .admin_panel_settings,
                                  color:
                                      Colors.white,
                                  size: 36,
                                ),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style: theme
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      'Head Administrator / Owner',
                                      style: theme
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    StatusBadge(
                                      label:
                                          status,
                                      positive:
                                          status ==
                                              'ACTIVE',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              SizedBox(
                                width: 150,
                                child: AppButton(
                                  label:
                                      'Edit Profile',
                                  icon: Icons
                                      .edit_outlined,
                                  onPressed:
                                      _openEditProfileDialog,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      const Divider(),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // ACCOUNT DETAILS
                      // ==================================================

                      Text(
                        'Administrative Account Details',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _ProfileTile(
                        icon:
                            Icons.person_outline,
                        label:
                            'Administrator Name',
                        value: name,
                      ),

                      _ProfileTile(
                        icon:
                            Icons.email_outlined,
                        label:
                            'Administrator Email',
                        value: email.isNotEmpty
                            ? email
                            : 'Not available',
                      ),

                      _ProfileTile(
                        icon:
                            Icons.phone_outlined,
                        label:
                            'Phone Number',
                        value: phone.isNotEmpty
                            ? phone
                            : 'Not provided',
                      ),

                     

                      if (joined.isNotEmpty)
                        _ProfileTile(
                          icon: Icons
                              .date_range_outlined,
                          label:
                              'Account Created',
                          value: joined,
                        ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ==================================================
                      // EDIT BUTTON
                      // ==================================================

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              _openEditProfileDialog,
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                          label: const Text(
                            'Edit Profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// PROFILE TILE
// ======================================================================

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: scheme.primary,
          ),

          const SizedBox(
            width: 14,
          ),

          SizedBox(
            width: 180,
            child: Text(
              label,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              value,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}