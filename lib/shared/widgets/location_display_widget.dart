import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/user_location.dart';
import 'package:udangtan_flutter_app/services/auth_service.dart';
import 'package:udangtan_flutter_app/services/location_service.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

class LocationDisplayWidget extends StatefulWidget {
  const LocationDisplayWidget({
    super.key,
    this.showManageButton = false,
    this.onManageTap,
    this.padding,
    this.showIcon = true,
  });

  final bool showManageButton;
  final VoidCallback? onManageTap;
  final EdgeInsets? padding;
  final bool showIcon;

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  _LocationDisplayWidgetState();

  UserLocation? _defaultAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  // 외부에서 호출할 수 있는 새로고침 메서드
  void refreshLocation() {
    if (mounted) {
      _loadDefaultAddress();
    }
  }

  // 외부에서 주소 새로고침할 수 있도록
  void refresh() {
    if (mounted) {
      _loadDefaultAddress();
    }
  }

  Future<void> _loadDefaultAddress() async {
    try {
      var userId = AuthService.getCurrentUserId();
      if (userId != null) {
        var address = await LocationService.getDefaultAddress(userId);
        if (mounted) {
          setState(() {
            _defaultAddress = address;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getDisplayAddress() {
    if (_defaultAddress == null) return '주소를 등록해주세요';

    String address = _defaultAddress!.address;
    // 긴 주소를 줄여서 표시
    List<String> parts = address.split(' ');
    if (parts.length >= 3) {
      return '${parts[0]} ${parts[1]} ${parts[2]}';
    } else if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (widget.showIcon) ...[
              Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 6),
            ],
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onManageTap,
      child: Container(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (widget.showIcon) ...[
              Icon(
                Icons.location_on,
                size: 16,
                color:
                    _defaultAddress != null
                        ? AppColors.primary
                        : Colors.grey[400],
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                _getDisplayAddress(),
                style: TextStyle(
                  fontSize: 14,
                  color:
                      _defaultAddress != null
                          ? AppColors.textPrimary
                          : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.showManageButton) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '관리',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
