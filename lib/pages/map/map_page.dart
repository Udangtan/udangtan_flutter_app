import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';
import 'package:udangtan_flutter_app/shared/widgets/common_app_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  final int currentNavIndex;
  final Function(int) onNavTap;

  @override
  State<MapPage> createState() => _MapPageState();
}

class UserData {
  UserData({
    required this.userId,
    required this.name,
    required this.gender,
    required this.age,
    required this.profileImageUrl,
    required this.profileMessage,
  });
  final String userId;
  final String name;
  final String gender;
  final int age;
  final String profileImageUrl;
  final String profileMessage;
}

class _MapPageState extends State<MapPage> {
  List<CustomOverlay> customOverlays = [];
  KakaoMapController? mapController;
  LatLng mapCenter = LatLng(37.49877286215097, 126.95220910952861);

  static const String markerImageUrl =
      'https://velog.velcdn.com/images/vewevteen/post/40b5e857-5c31-4717-8955-8cfb6cb57918/image.png';

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: '1',
        latLng: LatLng(37.494403809142675, 126.95430389533207),
        markerImageSrc: markerImageUrl,
        height: 32,
      ),
      Marker(
        markerId: '2',
        latLng: LatLng(37.495466763596, 126.95370390897536),
        markerImageSrc: markerImageUrl,
        height: 32,
      ),
      Marker(
        markerId: '3',
        latLng: LatLng(37.49515200825655, 126.95525333080086),
        markerImageSrc: markerImageUrl,
        height: 32,
      ),
      Marker(
        markerId: '4',
        latLng: LatLng(37.49709773083798, 126.95407608342305),
        markerImageSrc: markerImageUrl,
        height: 32,
      ),
      Marker(
        markerId: '5',
        latLng: LatLng(37.496286294351506, 126.9527308805763),
        markerImageSrc: markerImageUrl,
        height: 32,
      ),
    };

    Set<UserData> users = {
      UserData(
        userId: '1',
        name: '팡팡',
        age: 4,
        gender: '수컷',
        profileImageUrl:
            'https://velog.velcdn.com/images/vewevteen/post/723cd5f4-96df-4aaa-b52b-3a6d59b64c5c/image.png',
        profileMessage: '안녕하세요, 팡팡이예요! 저녁 시간에 주로 산책합니다!',
      ),
      UserData(
        userId: '2',
        name: '캉캉',
        age: 6,
        gender: '암컷',
        profileImageUrl:
            'https://velog.velcdn.com/images/vewevteen/post/f30bf90f-cdc8-46f3-b01e-a29ea0b6c761/image.png',
        profileMessage: '밥먹을때 캉캉캉캉!! 밥 달라!',
      ),
      UserData(
        userId: '3',
        name: '몰랑',
        age: 1,
        gender: '중성화',
        profileImageUrl:
            'https://velog.velcdn.com/images/vewevteen/post/1d49a163-cee6-4515-8fa2-4ccb92d06ca8/image.png',
        profileMessage: '하위~ 나는 몰랑 몰랑~ 먹는걸 좋아해 ㅎ',
      ),
      UserData(
        userId: '4',
        name: '푸푸',
        age: 8,
        gender: '중성화',
        profileImageUrl:
            'https://velog.velcdn.com/images/vewevteen/post/05d29b0f-fc49-432a-8c2c-45c359527d2b/image.png',
        profileMessage: '푸푸! 내 이름은 푸푸! 잠꾸러기지!',
      ),
      UserData(
        userId: '5',
        name: '팡팡',
        age: 2,
        gender: '수컷',
        profileImageUrl:
            'https://velog.velcdn.com/images/vewevteen/post/aaef5a70-6a90-4e97-b394-cf8526180010/image.png',
        profileMessage: '궁디 팡팡을 좋아하는 팡팡이',
      ),
    };

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CommonAppBar(
          title: '내 주변',
          automaticallyImplyLeading: false,
        ),
        body: KakaoMap(
          onMapCreated: (controller) async {
            mapController = controller;
            markers.add(
              Marker(
                markerId: UniqueKey().toString(),
                latLng: await controller.getCenter(),
              ),
            );
            setState(() {});
          },
          onMarkerTap: (markerId, latLng, zoomLevel) async {
            if (mapController != null) {
              await mapController!.setCenter(latLng);
            }
            setState(() {
              mapCenter = latLng;
              customOverlays.clear();
              customOverlays.add(
                CustomOverlay(
                  customOverlayId: 'overlay_$markerId',
                  latLng: latLng,
                  content: () {
                    var user = users.firstWhere(
                      (user) => user.userId == markerId,
                      orElse:
                          () => UserData(
                            userId: '',
                            name: '이름',
                            age: 0,
                            gender: '비밀',
                            profileImageUrl: '',
                            profileMessage: '',
                          ),
                    );
                    return '<div style="background-color: white; padding: 8px; border-radius: 8px; display: flex; flex-direction: column; align-items: center; gap: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); font-family: "-apple-system", BlinkMacSystemFont, "Segoe UI", "Roboto", "Helvetica Neue", Arial, sans-serif;"><img src="${user.profileImageUrl}" style="width: 60px; height: 60px; border-radius: 50%" /><div style="font-weight: bold; font-size: 18px">${user.name}</div><div style="font-size: 13px">${user.age}살 / ${user.gender}</div><div style="font-size: 12px">${user.profileMessage}</div></div>';
                  }(),
                  xAnchor: 0.5,
                  yAnchor: 1,
                  zIndex: 10,
                ),
              );
            });
          },
          onMapTap: (latLng) {
            setState(() {
              customOverlays.clear();
            });
          },
          customOverlays: customOverlays,
          markers: markers.toList(),
          center: mapCenter,
        ),
      ),
    );
  }
}
