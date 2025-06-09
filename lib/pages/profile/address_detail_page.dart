import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/user_location.dart';
import 'package:udangtan_flutter_app/services/location_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class AddressDetailPage extends StatefulWidget {
  const AddressDetailPage({
    super.key,
    required this.userId,
    this.selectedAddress,
    this.selectedPlace,
    this.editingAddress,
  });

  final String userId;
  final KakaoAddressResult? selectedAddress;
  final KakaoPlaceResult? selectedPlace;
  final UserLocation? editingAddress;

  @override
  State<AddressDetailPage> createState() => _AddressDetailPageState();
}

class _AddressDetailPageState extends State<AddressDetailPage> {
  _AddressDetailPageState();

  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingAddress != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    var address = widget.editingAddress!;
    _addressNameController.text = address.name;
    _detailAddressController.text = address.detailAddress ?? '';
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _detailAddressController.dispose();
    _buildingNameController.dispose();
    super.dispose();
  }

  String get _selectedAddressText {
    if (widget.selectedAddress != null) {
      return widget.selectedAddress!.roadAddress ??
          widget.selectedAddress!.address;
    }
    if (widget.selectedPlace != null) {
      return widget.selectedPlace!.roadAddress ?? widget.selectedPlace!.address;
    }
    if (widget.editingAddress != null) {
      return widget.editingAddress!.roadAddress ??
          widget.editingAddress!.address;
    }
    return '';
  }

  Future<void> _saveAddress() async {
    if (_addressNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주소 이름을 입력해주세요'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserLocation newAddress;

      if (widget.editingAddress != null) {
        // 수정 모드
        newAddress = widget.editingAddress!.copyWith(
          name: _addressNameController.text.trim(),
          detailAddress:
              _detailAddressController.text.trim().isEmpty
                  ? null
                  : _detailAddressController.text.trim(),
          isDefault: _isDefault,
        );
        var savedAddress = await LocationService.updateAddress(newAddress);
        if (mounted) {
          Navigator.pop(context, savedAddress);
        }
      } else {
        // 추가 모드
        if (widget.selectedAddress != null) {
          newAddress = LocationService.createUserLocationFromKakao(
            userId: widget.userId,
            addressName: _addressNameController.text.trim(),
            kakaoResult: widget.selectedAddress!,
            detailAddress:
                _detailAddressController.text.trim().isEmpty
                    ? null
                    : _detailAddressController.text.trim(),
            isDefault: _isDefault,
          );
        } else if (widget.selectedPlace != null) {
          newAddress = LocationService.createUserLocationFromPlace(
            userId: widget.userId,
            addressName: _addressNameController.text.trim(),
            placeResult: widget.selectedPlace!,
            detailAddress:
                _detailAddressController.text.trim().isEmpty
                    ? null
                    : _detailAddressController.text.trim(),
            isDefault: _isDefault,
          );
        } else {
          throw Exception('선택된 주소가 없습니다');
        }

        var savedAddress = await LocationService.addAddress(newAddress);
        if (mounted) {
          Navigator.pop(context, savedAddress);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주소 저장 실패: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: widget.editingAddress != null ? '주소 수정' : '주소 추가',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택된 주소 표시
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '선택된 주소',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedAddressText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 주소 이름 입력
                    _buildInputField(
                      label: '주소 이름',
                      controller: _addressNameController,
                      hintText: '집, 회사, 카페 등',
                      required: true,
                      icon: Icons.home_outlined,
                    ),

                    const SizedBox(height: 24),

                    // 상세 주소 입력
                    _buildInputField(
                      label: '상세 주소',
                      controller: _detailAddressController,
                      hintText: '동, 호수, 건물명 등 (선택사항)',
                      required: false,
                      icon: Icons.apartment_outlined,
                    ),

                    const SizedBox(height: 32),

                    // 기본 주소 설정
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isDefault,
                              onChanged: (value) {
                                setState(() {
                                  _isDefault = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '기본 주소로 설정',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '내 주변 화면에서 기본으로 표시됩니다',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 저장 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            widget.editingAddress != null ? '수정 완료' : '저장하기',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool required,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
