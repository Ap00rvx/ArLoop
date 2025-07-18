import 'package:arloop/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../theme/colors.dart';
import '../../../models/vendor/auth_response.dart';
import '../../../models/vendor/store_owner.dart';
import 'location_selector_screen.dart';

class VendorAuthPage extends StatefulWidget {
  const VendorAuthPage({super.key});

  @override
  State<VendorAuthPage> createState() => _VendorAuthPageState();
}

class _VendorAuthPageState extends State<VendorAuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_LoginTab(), _RegisterTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
            onPressed: () => context.go("/vendor-onboarding"),
          ),
          const Expanded(
            child: Text(
              'Vendor Authentication',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.neutralGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.lightText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }
}

class _LoginTab extends StatefulWidget {
  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = StoreOwnerLoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      context.read<StoreOwnerBloc>().add(LoginStoreOwnerEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreOwnerBloc, StoreOwnerState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          final token = state.token;
          FlutterSecureStorage().write(key: "auth_token", value: token);

          context.goNamed(
            RouteNames.vendorHome,
          ); // Navigate to vendor dashboard
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Welcome text
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your vendor account',
                    style: TextStyle(fontSize: 16, color: AppColors.lightText),
                  ),

                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Iconsax.sms),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Iconsax.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Forgot password
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegisterTab extends StatefulWidget {
  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controllers for Step 1 - Personal Info
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers for Step 2 - Shop Info
  final _shopNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();

  // Controllers for Step 3 - Address & Location
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Working Hours Controllers
  final _openTimeController = TextEditingController(text: "09:00");
  final _closeTimeController = TextEditingController(text: "21:00");

  // Working Days Selection
  final List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  List<String> _selectedWorkingDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Location data
  LatLng? _selectedLocation;
  String _fullAddress = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _licenseNumberController.dispose();
    _gstNumberController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateShopInfo();
      case 2:
        return _validateAddressInfo();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    if (_ownerNameController.text.isEmpty) {
      _showSnackBar('Please enter owner name');
      return false;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar('Please enter a valid email');
      return false;
    }
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showSnackBar('Please enter a valid phone number');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateShopInfo() {
    if (_shopNameController.text.isEmpty) {
      _showSnackBar('Please enter shop name');
      return false;
    }
    if (_licenseNumberController.text.isEmpty) {
      _showSnackBar('Please enter license number');
      return false;
    }
    if (!_isValidTimeFormat(_openTimeController.text)) {
      _showSnackBar('Please enter valid opening time (HH:MM format)');
      return false;
    }
    if (!_isValidTimeFormat(_closeTimeController.text)) {
      _showSnackBar('Please enter valid closing time (HH:MM format)');
      return false;
    }
    if (_selectedWorkingDays.isEmpty) {
      _showSnackBar('Please select at least one working day');
      return false;
    }
    return true;
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  bool _validateAddressInfo() {
    if (_selectedLocation == null) {
      _showSnackBar('Please select location on map');
      return false;
    }
    if (_streetController.text.isEmpty) {
      _showSnackBar('Please enter street address');
      return false;
    }
    if (_cityController.text.isEmpty) {
      _showSnackBar('Please enter city');
      return false;
    }
    if (_stateController.text.isEmpty) {
      _showSnackBar('Please enter state');
      return false;
    }
    if (_pincodeController.text.isEmpty) {
      _showSnackBar('Please enter pincode');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _submitRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = StoreOwnerRegistrationRequest(
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        shopDetails: ShopDetails(
          shopName: _shopNameController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          gstNumber: _gstNumberController.text.trim().isEmpty
              ? null
              : _gstNumberController.text.trim(),
          shopAddress: ShopAddress(
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            pincode: _pincodeController.text.trim(),
          ),
          location: _selectedLocation != null
              ? Location(
                  latitude: _selectedLocation!.latitude,
                  longitude: _selectedLocation!.longitude,
                )
              : null,
          workingHours: WorkingHours(
            openTime: _openTimeController.text.trim(),
            closeTime: _closeTimeController.text.trim(),
            workingDays: _selectedWorkingDays,
          ),
        ),
        businessInfo: BusinessInfo(
          deliveryAvailable: true,
          description: 'Pharmacy and medical store',
        ),
      );

      context.read<StoreOwnerBloc>().add(RegisterStoreOwnerEvent(request));
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationSelectorScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = result['location'] as LatLng;

        _streetController.text = result['street'] as String;
        _cityController.text = result['city'] as String;
        _stateController.text = result['state'] as String;
        _pincodeController.text = result['pincode'] as String;
        _fullAddress =
            _streetController.text +
            ', ' +
            _cityController.text +
            ', ' +
            _stateController.text +
            ', ' +
            _pincodeController.text;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreOwnerBloc, StoreOwnerState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.go("/vendor/home"); // Navigate to vendor dashboard
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
        builder: (context, state) {
          return Column(
            children: [
              // Step indicator
              _buildStepIndicator(),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      _buildPersonalInfoStep(),
                      _buildShopInfoStep(),
                      _buildAddressStep(),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            _buildStepCircle(i),
            if (i < 2) _buildStepConnector(i),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step) {
    final isActive = step <= _currentStep;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.neutralGrey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? AppColors.textOnPrimary : AppColors.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = step < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : AppColors.neutralGrey,
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your personal details',
            style: TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          const SizedBox(height: 24),

          // Owner Name
          TextFormField(
            controller: _ownerNameController,
            decoration: InputDecoration(
              labelText: 'Owner Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Iconsax.user),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Iconsax.sms),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Iconsax.call),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your pharmacy details',
            style: TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          const SizedBox(height: 24),

          // Shop Name
          TextFormField(
            controller: _shopNameController,
            decoration: InputDecoration(
              labelText: 'Shop Name',
              hintText: 'Enter your pharmacy name',
              prefixIcon: const Icon(Iconsax.shop),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // License Number
          TextFormField(
            controller: _licenseNumberController,
            decoration: InputDecoration(
              labelText: 'License Number',
              hintText: 'Enter your pharmacy license number',
              prefixIcon: const Icon(Iconsax.document),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // GST Number (Optional)
          TextFormField(
            controller: _gstNumberController,
            decoration: InputDecoration(
              labelText: 'GST Number (Optional)',
              hintText: 'Enter your GST number',
              prefixIcon: const Icon(Iconsax.receipt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Working Hours Section
          const Text(
            'Working Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _openTimeController,
                  decoration: InputDecoration(
                    labelText: 'Opening Time',
                    hintText: 'HH:MM (24-hour format)',
                    prefixIcon: const Icon(Iconsax.clock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () => _selectTime(_openTimeController),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _closeTimeController,
                  decoration: InputDecoration(
                    labelText: 'Closing Time',
                    hintText: 'HH:MM (24-hour format)',
                    prefixIcon: const Icon(Iconsax.clock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () => _selectTime(_closeTimeController),
                  readOnly: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Working Days Section
          const Text(
            'Working Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutralGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _allDays.map((day) {
                return CheckboxListTile(
                  title: Text(day),
                  value: _selectedWorkingDays.contains(day),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedWorkingDays.add(day);
                      } else {
                        _selectedWorkingDays.remove(day);
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Required',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your pharmacy license will be verified by our team before approval.',
                        style: TextStyle(fontSize: 12, color: AppColors.info),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address & Location',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your shop location',
            style: TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          const SizedBox(height: 24),

          // Select Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectLocation,
              icon: const Icon(Iconsax.gps),
              label: const Text('Select Location on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Address Fields
          TextFormField(
            controller: _streetController,
            decoration: InputDecoration(
              labelText: 'Street Address',
              hintText: 'Enter street address',
              prefixIcon: const Icon(Iconsax.location),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city',
                    prefixIcon: const Icon(Iconsax.buildings),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    hintText: 'Enter state',
                    prefixIcon: const Icon(Iconsax.map),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Pincode',
              hintText: 'Enter pincode',
              prefixIcon: const Icon(Iconsax.location_tick),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Selected Location Display
          if (_selectedLocation != null) ...[
            const Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            if (_fullAddress.isNotEmpty)
              Text(
                'Address: $_fullAddress',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.lightText,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: AppColors.lightText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(StoreOwnerState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'Register' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
