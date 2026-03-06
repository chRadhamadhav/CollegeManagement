import 'package:college_management/Features/Student/Services/student_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shows all study materials for the student's department, fetched from the backend.
///
/// Materials are grouped by subject and filterable via category chips.
class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({super.key});

  @override
  State<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends State<StudyMaterialPage> {
  List<Map<String, dynamic>> _allMaterials = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await StudentService().fetchMaterials();
      if (mounted) {
        // Build dynamic category list from subject codes
        final codes =
            data
                .map((m) => m['subject_code'] as String?)
                .where((c) => c != null && c.isNotEmpty)
                .cast<String>()
                .toSet()
                .toList()
              ..sort();
        setState(() {
          _allMaterials = data;
          _categories = ['All', ...codes];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load materials.';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMaterials {
    if (_selectedCategory == 'All') return _allMaterials;
    return _allMaterials
        .where((m) => m['subject_code'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Study Materials',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F80ED)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMaterials,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredMaterials;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No materials found.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildMaterialItem(filtered[index]),
    );
  }

  Widget _buildMaterialItem(Map<String, dynamic> material) {
    final title = material['title'] as String? ?? 'Untitled';
    final subjectCode = material['subject_code'] as String? ?? '';
    final subjectName = material['subject_name'] as String? ?? '';
    final category = material['category'] as String? ?? 'general';
    final createdAt = material['created_at'] as String? ?? '';

    final IconData icon;
    final Color color;
    if (title.toLowerCase().endsWith('.pdf')) {
      icon = Icons.picture_as_pdf;
      color = Colors.redAccent;
    } else if (title.toLowerCase().endsWith('.docx') ||
        title.toLowerCase().endsWith('.doc')) {
      icon = Icons.description;
      color = Colors.blueAccent;
    } else if (title.toLowerCase().endsWith('.xlsx') ||
        title.toLowerCase().endsWith('.csv')) {
      icon = Icons.table_chart;
      color = Colors.green;
    } else if (category == 'video') {
      icon = Icons.play_circle_outline;
      color = Colors.purple;
    } else {
      icon = Icons.insert_drive_file_outlined;
      color = Colors.orange;
    }

    // Display a user-readable date
    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inDays == 0) {
          dateLabel = 'Today';
        } else if (diff.inDays == 1) {
          dateLabel = 'Yesterday';
        } else {
          dateLabel = '${dt.day}/${dt.month}/${dt.year}';
        }
      } catch (_) {
        dateLabel = createdAt;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (subjectCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subjectCode,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    if (subjectCode.isNotEmpty) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateLabel.isNotEmpty
                            ? '$subjectName • $dateLabel'
                            : subjectName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final apiUrl =
                  dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api/v1';
              final baseUrl = apiUrl.replaceAll('/api/v1', '');
              final fileUrl = material['file_url'] as String?;

              if (fileUrl != null && fileUrl.isNotEmpty) {
                final url = Uri.parse('$baseUrl$fileUrl');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open file')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File URL not found')),
                );
              }
            },
            icon: const Icon(Icons.download_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
