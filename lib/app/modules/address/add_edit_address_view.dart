import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'address_controller.dart';
import '../../data/models/address_model.dart';

class AddEditAddressView extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressView({super.key, this.address});

  @override
  State<AddEditAddressView> createState() => _AddEditAddressViewState();
}

class _AddEditAddressViewState extends State<AddEditAddressView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _line1Ctrl;
  late TextEditingController _line2Ctrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _postalCtrl;

  String _addressType = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameCtrl = TextEditingController(text: addr?.name ?? '');
    _phoneCtrl = TextEditingController(text: addr?.phone ?? '');
    _line1Ctrl = TextEditingController(text: addr?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: addr?.addressLine2 ?? '');
    _cityCtrl = TextEditingController(text: addr?.city ?? '');
    _stateCtrl = TextEditingController(text: addr?.state ?? '');
    _postalCtrl = TextEditingController(text: addr?.postalCode ?? '');
    _addressType = addr?.addressType ?? 'Home';
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<AddressController>();
    final newOrUpdated = AddressModel(
      id: widget.address?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
      country: widget.address?.country ?? 'India',
      addressType: _addressType,
      isDefault: _isDefault,
    );

    if (widget.address != null) {
      controller.updateAddress(widget.address!.id, newOrUpdated);
    } else {
      controller.addAddress(newOrUpdated);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          isEdit ? 'Edit Address' : 'Add Address',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section Header
            Text(
              'CONTACT DETAILS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Name
            _buildTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Enter receiver name',
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),

            // Phone
            _buildTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: 'Enter 10-digit phone number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.trim().length < 10
                  ? 'Enter a valid 10-digit number'
                  : null,
              prefixIcon: Icons.phone_android,
            ),
            const SizedBox(height: 24),

            // Address Header
            Text(
              'ADDRESS DETAILS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Address Line 1
            _buildTextField(
              controller: _line1Ctrl,
              label: 'Flat, House No., Building, Apartment',
              hint: 'e.g. Flat 402, Sunshine Residency',
              validator: (v) =>
                  v!.trim().isEmpty ? 'This field is required' : null,
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 12),

            // Address Line 2
            _buildTextField(
              controller: _line2Ctrl,
              label: 'Area, Street, Sector, Village',
              hint: 'e.g. 12th Main, HSR Layout Sector 4',
              validator: (v) =>
                  v!.trim().isEmpty ? 'This field is required' : null,
              prefixIcon: Icons.map_outlined,
            ),
            const SizedBox(height: 12),

            // Grid: City, State, Postal Code
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityCtrl,
                    label: 'City',
                    hint: 'e.g. Bengaluru',
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _postalCtrl,
                    label: 'Pincode',
                    hint: '6 Digits',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.trim().length != 6 ? '6 Digits' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _stateCtrl,
              label: 'State',
              hint: 'e.g. Karnataka',
              validator: (v) => v!.trim().isEmpty ? 'State is required' : null,
              prefixIcon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 24),

            // Address Type Selection
            Text(
              'SAVE ADDRESS AS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Home', 'Work', 'Other'].map((type) {
                final isSel = _addressType == type;
                IconData icon;
                if (type == 'Home') {
                  icon = Icons.home;
                } else if (type == 'Work') {
                  icon = Icons.work;
                } else {
                  icon = Icons.location_on;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    avatar: Icon(icon,
                        size: 16,
                        color: isSel ? Colors.white : Colors.grey[700]),
                    label: Text(type),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      color: isSel ? Colors.white : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _addressType = type;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Set default switch
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: Text(
                'Set as Default Delivery Address',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222222),
                ),
              ),
              subtitle: Text(
                'This address will be selected automatically during checkout.',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
              value: _isDefault,
              onChanged: (val) {
                setState(() {
                  _isDefault = val;
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF1F1F1)),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: Colors.grey[600])
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
