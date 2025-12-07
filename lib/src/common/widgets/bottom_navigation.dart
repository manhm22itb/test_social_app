// lib/src/modules/common/widgets/widget__bottom_nav.dart
import 'package:flutter/material.dart';
import '../../../generated/colors.gen.dart';

class WidgetBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; 
  const WidgetBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const icons = <IconData>[
      Icons.home_rounded,
      Icons.chat_bubble_rounded,
      Icons.add_box_rounded,
      Icons.notifications_rounded,
      Icons.person_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorName.mint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabCount = icons.length;
              final tabWidth = constraints.maxWidth / tabCount;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Bubble chạy theo tab đang chọn
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    left: currentIndex * tabWidth + (tabWidth - 42) / 2,
                    top: 8,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icons[currentIndex],
                        size: 24,
                        color: ColorName.mint,
                      ),
                    ),
                  ),

                  // Hàng icon bấm được
                  Row(
                    children: List.generate(tabCount, (i) {
                      final isSelected = i == currentIndex;
                      return Expanded(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => onTap(i), 
                          child: SizedBox(
                            height: double.infinity,
                            child: Center(
                              child: Icon(
                                icons[i],
                                size:
                                    isSelected ? 0 : 24, 
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
