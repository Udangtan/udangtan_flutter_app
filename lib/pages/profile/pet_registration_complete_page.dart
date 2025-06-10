import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/models/pet.dart';

class PetRegistrationCompletePage extends StatefulWidget {
  const PetRegistrationCompletePage({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetRegistrationCompletePage> createState() =>
      _PetRegistrationCompletePageState();
}

class _PetRegistrationCompletePageState
    extends State<PetRegistrationCompletePage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 애니메이션 성공 아이콘
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C5CE7), Color(0xFF9E4BDE)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 축하 메시지
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      const Text(
                        '🎉 등록 완료!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.pet.name}이(가) 우리 가족이 되었어요!\n이제 새로운 친구들을 만나보세요',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF636E72),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 펫 정보 카드
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 펫 아바타
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  widget.pet.species == '강아지'
                                      ? [
                                        Colors.orange.withValues(alpha: 0.2),
                                        Colors.deepOrange.withValues(
                                          alpha: 0.1,
                                        ),
                                      ]
                                      : [
                                        Colors.purple.withValues(alpha: 0.2),
                                        Colors.deepPurple.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  widget.pet.species == '강아지'
                                      ? Colors.orange.withValues(alpha: 0.3)
                                      : Colors.purple.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 50,
                            color:
                                widget.pet.species == '강아지'
                                    ? Colors.orange[600]
                                    : Colors.purple[600],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 펫 이름
                        Text(
                          widget.pet.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 펫 기본 정보
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.pet.breed} • ${widget.pet.gender} • ${widget.pet.age}살',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF636E72),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // 성격 태그들
                        if (widget.pet.personality.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 20,
                                color: Colors.pink[400],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '성격',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                widget.pet.personality.map((personality) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF6C5CE7,
                                          ).withValues(alpha: 0.1),
                                          const Color(
                                            0xFF9E4BDE,
                                          ).withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF6C5CE7,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      personality,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6C5CE7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],

                        // 추가 정보
                        if (widget.pet.isNeutered != null ||
                            widget.pet.vaccinationStatus != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (widget.pet.isNeutered != null)
                                  _buildStatusIcon(
                                    '중성화',
                                    widget.pet.isNeutered!,
                                    Icons.health_and_safety,
                                  ),
                                if (widget.pet.vaccinationStatus != null)
                                  _buildStatusIcon(
                                    '예방접종',
                                    widget.pet.vaccinationStatus!,
                                    Icons.vaccines,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 확인 버튼
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C5CE7), Color(0xFF9E4BDE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String label, String status, IconData icon) {
    Color statusColor;
    if (status == '완료') {
      statusColor = Colors.green;
    } else if (status == '안함' || status == '미완료') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(icon, size: 24, color: statusColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
