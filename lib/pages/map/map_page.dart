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

class _MapPageState extends State<MapPage> {
  static const String markerImageUrl =
      'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png';

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: '1',
        latLng: LatLng(37.494403809142675, 126.95430389533207),
        markerImageSrc: markerImageUrl,
        height: 35,
      ),
      Marker(
        markerId: '2',
        latLng: LatLng(37.495466763596, 126.95370390897536),
        markerImageSrc: markerImageUrl,
        height: 35,
      ),
      Marker(
        markerId: '3',
        latLng: LatLng(37.49515200825655, 126.95525333080086),
        markerImageSrc: markerImageUrl,
        height: 35,
      ),
      Marker(
        markerId: '4',
        latLng: LatLng(37.49709773083798, 126.95407608342305),
        markerImageSrc: markerImageUrl,
        height: 35,
      ),
      Marker(
        markerId: '5',
        latLng: LatLng(37.496286294351506, 126.9527308805763),
        markerImageSrc: markerImageUrl,
        height: 35,
      ),
    };
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CommonAppBar(
          title: '지도',
          automaticallyImplyLeading: false,
        ),
        body: KakaoMap(
          onMapCreated: (controller) async {
            var mapController = controller;
            markers.add(
              Marker(
                markerId: UniqueKey().toString(),
                latLng: await mapController.getCenter(),
              ),
            );
            setState(() {});
          },
          markers: markers.toList(),
          center: LatLng(37.49580037809941, 126.95432566106915),
        ),
      ),
    );
  }
}
