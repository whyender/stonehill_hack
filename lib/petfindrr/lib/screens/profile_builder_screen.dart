import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'swipe_screen.dart';

class ProfileBuilderScreen extends StatefulWidget {
  const ProfileBuilderScreen({super.key});

  @override
  State<ProfileBuilderScreen> createState() => _ProfileBuilderScreenState();
}

class _ProfileBuilderScreenState extends State<ProfileBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _authService = AuthService();
  
  String _homeSize = 'medium';
  String _activityLevel = 'medium';
  final List<String> _preferredSizes = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_preferredSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select atleast one preferred pet size'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = _authService.currentUser!.uid;
      await _authService.updateProfile(uid, {
        'name': _nameController.text.trim(),
        'budget': double.parse(_budgetController.text),
        'homeSize': _homeSize,
        'activityLevel': _activityLevel,
        'preferredSizes': _preferredSizes,
        'location': [_locationController.text.trim()],
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SwipeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Build Your Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us a bit about yourself!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us find placeHOLDERe',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Your Name',
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Budget (\$)',
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'BUDGETTt';
                    if (double.tryParse(v) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Location ([citYy and statee]',
                  controller: _locationController,
                  validator: (v) => v!.isEmpty ? 'Please enter location' : null,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'HSIZE OF YOUR HOUSEE',
                  ['Small', 'Medium', 'Large'],
                  _homeSize,
                  (value) => setState(() => _homeSize = value.toLowerCase()),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'ACTIIVTYYY',
                  ['Low', 'Medium', 'High'],
                  _activityLevel,
                  (value) => setState(() => _activityLevel = value.toLowerCase()),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SIZEEE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: ['small', 'medium', 'large'].map((size) {
                    final isSelected = _preferredSizes.contains(size);
                    return FilterChip(
                      label: Text(size[0].toUpperCase() + size.substring(1)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _preferredSizes.add(size);
                          } else {
                            _preferredSizes.remove(size);
                          }
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'swipe',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: options.map((option) {
            final value = option.toLowerCase();
            final isSelected = currentValue == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}