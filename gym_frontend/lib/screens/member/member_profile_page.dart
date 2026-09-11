import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  // ============================================================
  // STATE
  // ============================================================

  bool _loading = true;
  bool _saving = false;

  String? _error;

  bool _hasExistingProfile = false;

  String _email = '';

  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  final _medicalController = TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _fetchProfile();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _medicalController.dispose();

    super.dispose();
  }

  // ============================================================
  // FETCH PROFILE
  // GET /api/member/profile
  // ============================================================

  Future<void> _fetchProfile() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final api = context.read<ApiService>();
    final auth = context.read<AuthController>();

    try {
      Map<String, dynamic> profile = {};

      // ----------------------------------------------------------
      // FIRST: GET MEMBER PROFILE
      // ----------------------------------------------------------

      try {
        final response =
            await api.get('/api/member/profile');

        profile = _extractProfile(response);

        if (profile.isNotEmpty) {
          _hasExistingProfile = true;
        }
      } on ApiException catch (e) {
        /*
         * If the profile doesn't exist yet, we want the page
         * to remain usable so the member can create one.
         *
         * We only treat common "not found" cases as
         * "profile does not exist".
         *
         * For other API errors, show the actual error.
         */
        if (_isNotFoundError(e)) {
          profile = {};
          _hasExistingProfile = false;
        } else {
          rethrow;
        }
      }

      // ----------------------------------------------------------
      // AUTH PROFILE
      //
      // Used mainly for email/name/phone/fitness_goal fallback.
      // ----------------------------------------------------------

      Map<String, dynamic> authMember = {};

      try {
        final authResponse =
            await api.get('/api/member/auth/profile');

        authMember =
            _extractMember(authResponse);
      } catch (_) {
        // Auth profile is only fallback data.
      }

      // ----------------------------------------------------------
      // FALLBACK TO AuthController USER
      // ----------------------------------------------------------

      final authUser =
          auth.user ?? <String, dynamic>{};

      // ----------------------------------------------------------
      // POPULATE FORM
      // ----------------------------------------------------------

      _nameController.text = asString(
        profile['name'],
        asString(
          authMember['name'],
          asString(
            authUser['name'],
          ),
        ),
      );

      _phoneController.text = asString(
        profile['phone'],
        asString(
          authMember['phone'],
          asString(
            authUser['phone'],
          ),
        ),
      );

      _ageController.text = _numberToText(
        profile['age'],
      );

      _heightController.text = _numberToText(
        profile['height'],
      );

      _weightController.text = _numberToText(
        profile['weight'],
      );

      _goalController.text = asString(
        profile['fitness_goal'],
        asString(
          authMember['fitness_goal'],
          asString(
            authUser['fitness_goal'],
          ),
        ),
      );

      _medicalController.text = asString(
        profile['medical_notes'],
      );

      _email = asString(
        profile['email'],
        asString(
          authMember['email'],
          asString(
            authUser['email'],
          ),
        ),
      );

      if (!mounted) return;

      setState(() {
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
        _error = 'Failed to load member profile.';
        _loading = false;
      });
    }
  }

  // ============================================================
  // SAVE PROFILE
  //
  // CREATE:
  // POST /api/member/profile
  //
  // UPDATE:
  // PUT /api/member/profile
  // ============================================================

  Future<void> _saveProfile() async {
    // ----------------------------------------------------------
    // VALIDATE FORM
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final api = context.read<ApiService>();

    // ----------------------------------------------------------
    // REQUEST BODY
    // ----------------------------------------------------------

    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'age': _parseNullableInt(
        _ageController.text,
      ),
      'height': _parseNullableDouble(
        _heightController.text,
      ),
      'weight': _parseNullableDouble(
        _weightController.text,
      ),
      'fitness_goal': _goalController.text.trim(),
      'medical_notes': _medicalController.text.trim(),
    };

    try {
      // --------------------------------------------------------
      // CREATE PROFILE
      // --------------------------------------------------------

      if (!_hasExistingProfile) {
        await api.post(
          '/api/member/profile',
          body: body,
        );

        _hasExistingProfile = true;
      }

      // --------------------------------------------------------
      // UPDATE PROFILE
      // --------------------------------------------------------

      else {
        await api.put(
          '/api/member/profile',
          body: body,
        );
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS MESSAGE
      // --------------------------------------------------------

      final scheme =
          Theme.of(context).colorScheme;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profile saved successfully.',
          ),
          backgroundColor: scheme.primary,
        ),
      );

      // --------------------------------------------------------
      // REFRESH PROFILE
      // --------------------------------------------------------

      await _fetchProfile();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save member profile.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // EXTRACT PROFILE
  //
  // Supports:
  //
  // {
  //   "success": true,
  //   "profile": {...}
  // }
  //
  // or
  //
  // {
  //   "success": true,
  //   "data": {...}
  // }
  // ============================================================

  Map<String, dynamic> _extractProfile(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      if (response['profile'] is Map) {
        return Map<String, dynamic>.from(
          response['profile'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }

      // Some APIs may return the profile object directly.
      if (_looksLikeProfile(response)) {
        return Map<String, dynamic>.from(
          response,
        );
      }
    }

    if (response is Map) {
      if (response['profile'] is Map) {
        return Map<String, dynamic>.from(
          response['profile'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }

      if (_looksLikeProfile(response)) {
        return Map<String, dynamic>.from(
          response,
        );
      }
    }

    return {};
  }

  // ============================================================
  // EXTRACT MEMBER FROM AUTH PROFILE
  // ============================================================

  Map<String, dynamic> _extractMember(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      if (response['member'] is Map) {
        return Map<String, dynamic>.from(
          response['member'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }
    }

    if (response is Map) {
      if (response['member'] is Map) {
        return Map<String, dynamic>.from(
          response['member'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }
    }

    return {};
  }

  // ============================================================
  // CHECK PROFILE OBJECT
  // ============================================================

  bool _looksLikeProfile(
    Map<dynamic, dynamic> map,
  ) {
    return map.containsKey('name') ||
        map.containsKey('phone') ||
        map.containsKey('age') ||
        map.containsKey('height') ||
        map.containsKey('weight') ||
        map.containsKey('fitness_goal') ||
        map.containsKey('medical_notes');
  }

  // ============================================================
  // NOT FOUND ERROR CHECK
  // ============================================================

  bool _isNotFoundError(
    ApiException error,
  ) {
    final message =
        error.message.toLowerCase();

    return message.contains('not found') ||
        message.contains('profile does not exist') ||
        message.contains('profile not found') ||
        message.contains('no profile');
  }

  // ============================================================
  // NUMBER TO TEXT
  // ============================================================

  String _numberToText(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    final text =
        value.toString().trim();

    if (text.isEmpty ||
        text == 'null') {
      return '';
    }

    return text;
  }

  // ============================================================
  // PARSE INT
  // ============================================================

  int? _parseNullableInt(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return int.tryParse(text);
  }

  // ============================================================
  // PARSE DOUBLE
  // ============================================================

  double? _parseNullableDouble(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final padding =
        Responsive.pagePadding(
      context,
    );

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
          padding:
              EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 850,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // PROFILE HEADER
                        // ==================================================

                        _buildProfileHeader(
                          context,
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        const Divider(),

                        const SizedBox(
                          height: 24,
                        ),

                        // ==================================================
                        // PERSONAL INFORMATION
                        // ==================================================

                        Text(
                          'Personal & Contact Information',
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

                        // NAME
                        TextFormField(
                          controller:
                              _nameController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Full Name *',
                            prefixIcon:
                                Icon(
                              Icons
                                  .badge_outlined,
                            ),
                          ),
                          validator: (value) =>
                              Validators
                                  .requiredField(
                            value,
                            label:
                                'Name',
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // PHONE
                        TextFormField(
                          controller:
                              _phoneController,
                          keyboardType:
                              TextInputType.phone,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Phone Number *',
                            prefixIcon:
                                Icon(
                              Icons
                                  .phone_outlined,
                            ),
                          ),
                          validator: (value) =>
                              Validators
                                  .requiredField(
                            value,
                            label:
                                'Phone',
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // EMAIL - READ ONLY
                        TextFormField(
                          initialValue:
                              _email,
                          readOnly: true,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Email',
                            prefixIcon:
                                const Icon(
                              Icons
                                  .email_outlined,
                            ),
                            filled: true,
                            fillColor: scheme
                                .surfaceContainerHighest,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // PHYSICAL STATS
                        // ==================================================

                        Text(
                          'Physical Stats & Fitness Goals',
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

                        LayoutBuilder(
                          builder:
                              (
                                context,
                                constraints,
                              ) {
                            final isMobile =
                                constraints.maxWidth <
                                    600;

                            if (isMobile) {
                              return Column(
                                children: [
                                  _buildAgeField(),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  _buildHeightField(),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  _buildWeightField(),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildAgeField(),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child:
                                      _buildHeightField(),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child:
                                      _buildWeightField(),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // FITNESS GOAL
                        TextFormField(
                          controller:
                              _goalController,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Fitness Goal / Purpose',
                            prefixIcon:
                                Icon(
                              Icons
                                  .flag_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // MEDICAL NOTES
                        TextFormField(
                          controller:
                              _medicalController,
                          maxLines: 4,
                          keyboardType:
                              TextInputType.multiline,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Medical Notes / Physical Limitations',
                            alignLabelWithHint:
                                true,
                            prefixIcon:
                                Icon(
                              Icons
                                  .health_and_safety_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // SAVE BUTTON
                        // ==================================================

                        AppButton(
                          label:
                              _hasExistingProfile
                                  ? 'Update Profile'
                                  : 'Create Profile',
                          loading:
                              _saving,
                          onPressed:
                              _saveProfile,
                          expanded: true,
                          icon:
                              Icons
                                  .save_outlined,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // PROFILE STATE
                        // ==================================================

                        Center(
                          child: Text(
                            _hasExistingProfile
                                ? 'Your profile is saved.'
                                : 'Complete your profile and save your details.',
                            textAlign:
                                TextAlign.center,
                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: scheme
                                  .onSurfaceVariant,
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
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor:
              scheme.primary,
          child: Icon(
            Icons.person,
            color:
                scheme.onPrimary,
            size: 32,
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
                _nameController
                        .text
                        .trim()
                        .isNotEmpty
                    ? _nameController
                        .text
                        .trim()
                    : 'Member Profile',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              if (_email.isNotEmpty) ...[
                const SizedBox(
                  height: 4,
                ),
                Text(
                  _email,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: scheme
                        .onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(
                height: 8,
              ),

              StatusBadge(
                label:
                    'MEMBER ROLE',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AGE FIELD
  // ============================================================

  Widget _buildAgeField() {
    return TextFormField(
      controller:
          _ageController,
      keyboardType:
          TextInputType.number,
      textInputAction:
          TextInputAction.next,
      decoration:
          const InputDecoration(
        labelText:
            'Age (Years)',
        prefixIcon:
            Icon(
          Icons.cake_outlined,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return null;
        }

        final age =
            int.tryParse(text);

        if (age == null) {
          return 'Enter a valid age';
        }

        if (age <= 0 ||
            age > 120) {
          return 'Enter a valid age';
        }

        return null;
      },
    );
  }

  // ============================================================
  // HEIGHT FIELD
  // ============================================================

  Widget _buildHeightField() {
    return TextFormField(
      controller:
          _heightController,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      textInputAction:
          TextInputAction.next,
      decoration:
          const InputDecoration(
        labelText:
            'Height (cm)',
        prefixIcon:
            Icon(
          Icons.height_outlined,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return null;
        }

        final height =
            double.tryParse(text);

        if (height == null) {
          return 'Enter a valid height';
        }

        if (height <= 0 ||
            height > 300) {
          return 'Enter a valid height';
        }

        return null;
      },
    );
  }

  // ============================================================
  // WEIGHT FIELD
  // ============================================================

  Widget _buildWeightField() {
    return TextFormField(
      controller:
          _weightController,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      textInputAction:
          TextInputAction.next,
      decoration:
          const InputDecoration(
        labelText:
            'Weight (kg)',
        prefixIcon:
            Icon(
          Icons.scale_outlined,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return null;
        }

        final weight =
            double.tryParse(text);

        if (weight == null) {
          return 'Enter a valid weight';
        }

        if (weight <= 0 ||
            weight > 500) {
          return 'Enter a valid weight';
        }

        return null;
      },
    );
  }
}