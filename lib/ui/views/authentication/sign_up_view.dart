import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/utils/form_validator.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/input/app_input.dart';
import 'package:ballot_access_pro/shared/widgets/app_rich_text.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ballot_access_pro/shared/widgets/app_back_button.dart';
import 'package:ballot_access_pro/ui/views/authentication/email_verification_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/sign_up_bloc.dart';
import 'bloc/sign_up_event.dart';
import 'bloc/sign_up_state.dart';
import 'package:ballot_access_pro/shared/widgets/app_toast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isPhoneValid = false;
  bool isFormValid = false;
  String? selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    addressController.addListener(_validateForm);
    genderController.addListener(_validateForm);
    countryController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
                   emailController.text.isNotEmpty &&
                   passwordController.text.isNotEmpty &&
                   confirmPasswordController.text.isNotEmpty &&
                   addressController.text.isNotEmpty &&
                   genderController.text.isNotEmpty &&
                   countryController.text.isNotEmpty &&
                   phoneController.text.isNotEmpty &&
                   FormValidators.isNameValid(nameController.text) == null &&
                   FormValidators.validateEmail(emailController.text) == null &&
                   FormValidators.validatePassword(passwordController.text) == null &&
                   FormValidators.checkIfPasswordSame(
                     confirmPasswordController.text,
                     passwordController.text,
                   ) == null &&
                   FormValidators.validateAddress(addressController.text) == null &&
                   FormValidators.validateGender(genderController.text) == null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    genderController.dispose();
    countryController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String get displayGender {
    if (genderController.text.isEmpty) return '';
    return genderController.text[0].toUpperCase() + genderController.text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.status == SignUpStatus.loading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state.status == SignUpStatus.failure) {
          AppToast.showErrorToast(state.errorMessage ?? 'Sign up failed');
        }

        if (state.status == SignUpStatus.success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationView(
                email: emailController.text,
                userId: state.user!.id,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.v12(),
                    const AppBackButton(),
                    AppSpacing.v16(),
                    Text(
                      'Create an account to get started',
                      style: AppTextStyle.bold24,
                    ),
                    AppSpacing.v20(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Full Name',
                      controller: nameController,
                      validator: FormValidators.isNameValid,
                      inputColor: Colors.white,
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Email',
                      controller: emailController,
                      validator: FormValidators.validateEmail,
                      inputColor: Colors.white,
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Password',
                      controller: passwordController,
                      obscureText: true,
                      validator: FormValidators.validatePassword,
                      inputColor: Colors.white,
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Confirm Password',
                      controller: confirmPasswordController,
                      obscureText: true,
                      validator: (value) => FormValidators.checkIfPasswordSame(
                        value,
                        passwordController.text,
                      ),
                      inputColor: Colors.white,
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Address',
                      controller: addressController,
                      validator: FormValidators.validateAddress,
                      inputColor: Colors.white,
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: genderController.text.isEmpty ? 'Select Gender' : 'Gender',
                      controller: TextEditingController(text: displayGender),
                      validator: FormValidators.validateGender,
                      inputColor: Colors.white,
                      readOnly: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            title: Text(
                              'Select Gender',
                              style: AppTextStyle.bold20,
                              textAlign: TextAlign.center,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width - 44.w, // Match app padding (22.w from each side)
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Male',
                                      style: AppTextStyle.regular16,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        genderController.text = 'male';
                                      });
                                      Navigator.pop(context);
                                    },
                                    contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Female',
                                      style: AppTextStyle.regular16,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        genderController.text = 'female';
                                      });
                                      Navigator.pop(context);
                                    },
                                    contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      suffix: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ),
                    AppSpacing.v8(),
                    AppInput(
                      autoValidate: true,
                      labelText: 'Country',
                      controller: countryController,
                      inputColor: Colors.white,
                      readOnly: true,
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight: 400.h,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country.name;
                              countryController.text = country.name;
                            });
                          },
                        );
                      },
                    ),
                    AppSpacing.v8(),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Phone Number',
                        labelStyle: AppTextStyle.regular16.copyWith(
                          color: AppColors.grey300,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      initialCountryCode: 'US',
                      onChanged: (phone) {
                        phoneController.text = phone.completeNumber;
                      },
                      validator: (phone) {
                        if (phone == null || !phone.isValidNumber()) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.v16(),
                    AppButton(
                      text: 'Sign up',
                      loading: _isLoading,
                      textColor: Colors.white,
                      style: AppTextStyle.semibold16.copyWith(color: Colors.white),
                      onPressed: isFormValid
                          ? () {
                              if (formKey.currentState!.validate()) {
                                final nameParts = nameController.text.trim().split(' ');
                                context.read<SignUpBloc>().add(
                                      SignUpSubmitted(
                                        firstName: nameParts[0],
                                        lastName: nameParts[1],
                                        email: emailController.text,
                                        password: passwordController.text,
                                        phone: phoneController.text,
                                        address: addressController.text,
                                        gender: genderController.text,
                                        country: countryController.text,
                                      ),
                                    );
                              }
                            }
                          : null,
                    ),
                    AppSpacing.v24(),
                    Center(
                      child: AppRichText(
                        title: "Already have an account? ",
                        subTitle: "Sign in",
                        titleStyle: AppTextStyle.regular14,
                        subTitleStyle: AppTextStyle.semibold14.copyWith(
                          color: AppColors.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            NavigationService.pushReplacementNamed('/sign-in');
                          },
                      ),
                    ),
                    AppSpacing.v16(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 