import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../generated/colors.gen.dart'; // Giả định ColorName.primary và ColorName.error tồn tại

class ToastWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor; // Thêm tham số màu nền

  const ToastWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = FontAwesomeIcons.circleExclamation, // Thay đổi icon mặc định
    this.iconColor = ColorName.primary, // Màu icon mặc định (có thể là Primary)
    this.backgroundColor = Colors.white, // Màu nền mặc định
  });

  // Factory constructor tiện ích cho Lỗi
  factory ToastWidget.error({
    required String title,
    required String description,
    IconData icon = FontAwesomeIcons.circleXmark,
  }) {
    return ToastWidget(
      title: title,
      description: description,
      icon: icon,
      iconColor: ColorName.primary, // Ví dụ: Màu đỏ cho lỗi
      backgroundColor: const Color(0xFFFEE2E2), // Màu nền đỏ nhạt
    );
  }

  // Factory constructor tiện ích cho Thành công
  factory ToastWidget.success({
    required String title,
    required String description,
    IconData icon = FontAwesomeIcons.circleCheck,
  }) {
    return ToastWidget(
      title: title,
      description: description,
      icon: icon,
      iconColor: ColorName.background, // Ví dụ: Màu xanh lá cho thành công
      backgroundColor: const Color(0xFFD1FAE5), // Màu nền xanh nhạt
    );
  }


  @override
  Widget build(BuildContext context) {
    // 1. Giảm padding ngang, chuyển lên TopCenter
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24), 
      child: Align(
        alignment: Alignment.topCenter, // 👈 Hiển thị ở trên cùng
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor, // 👈 Sử dụng màu nền tùy chỉnh
              // borderRadius: BorderRadius.circular(12.0), // Bo tròn vừa phải
              border: Border.all(color: iconColor.withOpacity(0.5), width: 1), // Thêm viền nhẹ
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Tăng độ nổi khối
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max, // Mở rộng hết chiều ngang
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Icon (Cố định, to hơn một chút)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    icon, 
                    color: iconColor, 
                    size: 20, // Icon lớn hơn
                  ),
                ),
                const SizedBox(width: 12),
                
                // 3. Nội dung
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall // Dùng titleSmall để cân đối
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                
                // (Tùy chọn: Thêm nút đóng nếu bạn muốn nó giống alert hơn, nhưng Toast thường không có)
              ],
            ),
          ),
        ),
      ),
    );
  }
}