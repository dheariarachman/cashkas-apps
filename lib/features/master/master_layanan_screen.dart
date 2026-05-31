import 'package:flutter/material.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shapes.dart';
import '../../core/design/app_typography.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/service_model.dart';

class MasterLayananScreen extends StatefulWidget {
  const MasterLayananScreen({super.key});

  @override
  State<MasterLayananScreen> createState() => _MasterLayananScreenState();
}

class _MasterLayananScreenState extends State<MasterLayananScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _dbHelper.getAllServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showServiceForm([ServiceModel? service]) {
    final nameController = TextEditingController(text: service?.name ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              service == null ? 'Tambah Layanan' : 'Edit Layanan',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('NAMA LAYANAN', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Transfer, Pulsa, dll',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.borderRadiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  
                  if (service == null) {
                    await _dbHelper.insertService(ServiceModel(name: nameController.text));
                  } else {
                    await _dbHelper.updateService(ServiceModel(id: service.id, name: nameController.text));
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadServices();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
                ),
                child: const Text('Simpan Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            if (service != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () async {
                    await _dbHelper.deleteService(service.id!);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadServices();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
                  ),
                  child: const Text('Hapus Layanan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Master Layanan'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('Belum ada layanan'))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.gridMargin),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppShapes.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceContainerLow,
                          child: Icon(Icons.category_outlined, color: AppColors.primary),
                        ),
                        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showServiceForm(service),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
