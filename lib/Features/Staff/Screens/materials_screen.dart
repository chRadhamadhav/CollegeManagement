import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vidhya_sethu/Features/Staff/Models/material_category.dart';
import 'package:vidhya_sethu/core/logger/app_logger.dart';
import '../Services/materials_service.dart';
import '../Services/attendance_service.dart';
import '../Models/subject.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final MaterialsService _materialsService = MaterialsService();
  final AttendanceService _attendanceService = AttendanceService();
  String? _selectedCategoryId;
  String? _selectedSubjectId;
  List<Subject> _subjects = [];
  List<MaterialCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final subjects = await _attendanceService.getSubjects();
    if (mounted) {
      setState(() {
        _subjects = subjects;
        if (subjects.isNotEmpty) {
          _selectedSubjectId = subjects.first.id;
        }
      });
      if (_selectedSubjectId != null) {
        await _loadCategories();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategories() async {
    if (_selectedSubjectId == null) return;
    AppLogger.debug('Loading categories for subject: $_selectedSubjectId');
    setState(() => _isLoading = true);
    final cats = await _materialsService.getCategories(_selectedSubjectId!);
    if (mounted) {
      setState(() {
        _categories = cats;
        _isLoading = false;

        AppLogger.debug('Categories loaded: ${cats.length}');
        for (var c in cats) {
          AppLogger.debug('Category: ${c.name} (ID: ${c.id})');
        }

        // Keep existing selection if it still exists, otherwise pick first
        if (cats.isNotEmpty) {
          bool exists = cats.any((c) => c.id == _selectedCategoryId);
          if (!exists) {
            _selectedCategoryId = cats.first.id;
            AppLogger.debug('Selected first category: $_selectedCategoryId');
          } else {
            AppLogger.debug('Keeping existing category: $_selectedCategoryId');
          }
        } else {
          _selectedCategoryId = null;
          AppLogger.debug('No categories available, setting selection to null');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materials')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_subjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: _subjects.map((Subject subject) {
                        return DropdownMenuItem<String>(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != _selectedSubjectId) {
                          setState(() {
                            _selectedSubjectId = newValue;
                          });
                          _loadCategories();
                        }
                      },
                    ),
                  ),

                if (_categories.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No categories yet. Create one to get started!',
                      ),
                    ),
                  )
                else ...[
                  // Categories List
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category.id == _selectedCategoryId;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  // Materials List
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (_selectedCategoryId == null)
                          return const SizedBox();

                        final selectedCat = _categories.firstWhere(
                          (c) => c.id == _selectedCategoryId,
                          orElse: () => _categories.first,
                        );

                        final materials = selectedCat.materials;

                        if (materials.isEmpty) {
                          return const Center(
                            child: Text('No materials in this category.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: materials.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final material = materials[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.description,
                                  size: 32,
                                ),
                                title: Text(material.fileName),
                                subtitle: Text(
                                  'Added on ${material.dateAdded.toString().split(' ')[0]}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final success = await _materialsService
                                        .deleteMaterial(material.id);
                                    if (success) {
                                      _loadCategories();
                                    }
                                  },
                                ),
                                onTap: () async {
                                  final apiUrl =
                                      dotenv.env['API_BASE_URL'] ??
                                      'http://127.0.0.1:8000/api/v1';
                                  final baseUrl = apiUrl.replaceAll(
                                    '/api/v1',
                                    '',
                                  );
                                  final url = Uri.parse(
                                    '$baseUrl${material.fileUrl}',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Could not open file'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_category',
            onPressed: _selectedSubjectId != null
                ? _showAddCategoryDialog
                : null,
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_material',
            onPressed: () {
              if (_selectedCategoryId != null) {
                _uploadMaterial();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select or create a category first'),
                  ),
                );
              }
            },
            child: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Category Name (e.g. Maths)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && _selectedSubjectId != null) {
                final success = await _materialsService.addCategory(
                  controller.text,
                  _selectedSubjectId!,
                );
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    _loadCategories();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create category. Check logs.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadMaterial() async {
    AppLogger.debug('FAB Upload pressed. Category ID: $_selectedCategoryId');
    if (_selectedCategoryId == null) {
      AppLogger.warn('Cannot upload: No category selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or create a category first'),
        ),
      );
      return;
    }

    try {
      AppLogger.debug('Opening FilePicker...');
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        AppLogger.debug('File picked: ${result.files.single.name}');
        final success = await _materialsService.addMaterial(
          filePath: result.files.single.path!,
          fileName: result.files.single.name,
          categoryId: _selectedCategoryId!,
        );
        if (success) {
          AppLogger.info('Material upload successful');
          _loadCategories();
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Upload successful')));
          }
        } else {
          AppLogger.error('Material upload failed (service returned false)');
        }
      } else {
        AppLogger.debug('FilePicker cancelled or null path');
      }
    } catch (e) {
      AppLogger.error('Error in _uploadMaterial', e);
    }
  }
}
