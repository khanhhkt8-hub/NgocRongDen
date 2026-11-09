# Định hướng gameplay — NGỌC RỒNG ĐEN

## Mục tiêu trải nghiệm
NGỌC RỒNG ĐEN hướng tới một MMORPG 2D side-scrolling có nhịp chơi, cấu trúc tiến trình và cảm giác điều khiển gần với dòng game Chú Bé Rồng Online: vào khu vực, gặp người chơi khác, luyện quái, nhận nhiệm vụ, tăng sức mạnh, săn boss và giao lưu. Đây là định hướng tham khảo về thể loại và trải nghiệm, không sao chép tài sản hay nội dung có bản quyền.

## Các nguyên tắc bắt buộc
1. Màn hình ngang, góc nhìn 2D ngang; nhân vật và quái cùng tồn tại trên một mặt phẳng chiến đấu.
2. Di chuyển trái/phải, nhảy, đánh thường, dùng chưởng/kỹ năng; thao tác phải phù hợp màn hình cảm ứng.
3. HUD MMORPG hiển thị HP, KI, sức mạnh/tiềm năng, cấp độ và trạng thái chiến đấu.
4. Vòng lặp cốt lõi: nhận nhiệm vụ → tới khu vực → đánh quái → nhận EXP/vật phẩm → nâng cấp nhân vật → mở khu vực/thử thách mới.
5. Khu vực có cổng/chuyển map, quái có cấp độ và phạm vi hoạt động, NPC có hội thoại/dịch vụ.
6. Tiến trình nhân vật: cấp độ, sức mạnh, tiềm năng, chỉ số, kỹ năng, trang bị và biến đổi hình thái nguyên bản.
7. Online là mục tiêu kiến trúc: server có quyền quyết định trạng thái quan trọng; đồng bộ vị trí, hoạt ảnh, chiến đấu, quái, chat và nhóm. Không giả lập online bằng nhiều nhân vật bot cục bộ.
8. Android là nền tảng ưu tiên; UI và điều khiển phải được thiết kế cho màn hình cảm ứng ngang.

## Phạm vi nội dung nguyên bản
Có thể tham khảo cấu trúc gameplay và cảm giác thể loại. Không sử dụng tên nhân vật, hành tinh, địa danh, hình ảnh, sprite, âm thanh, lời thoại, nhiệm vụ, bản đồ, biểu tượng hoặc mã nguồn của Chú Bé Rồng Online hay thương hiệu khác. Tất cả nội dung của NGỌC RỒNG ĐEN phải tự thiết kế.

## Thứ tự triển khai
- Milestone 1: điều khiển ngang, camera, HUD HP/KI, đánh thường/chưởng, quái, EXP.
- Milestone 2: bản đồ/khu vực, NPC, hội thoại, nhiệm vụ, cổng chuyển map.
- Milestone 3: túi đồ, trang bị, chỉ số, tiềm năng, kỹ năng và nâng cấp.
- Milestone 4: boss, phần thưởng, tổ đội và hoạt động theo nhóm.
- Milestone 5: máy chủ authoritative, đăng nhập, nhiều người chơi thật, chat, giao dịch và PvP.
- Milestone 6: tối ưu Android, kiểm thử thiết bị thật và đóng gói APK.

## Tiêu chí chất lượng
Mỗi milestone phải có cảnh chạy được, tài nguyên placeholder rõ ràng, hướng dẫn kiểm thử và không được tuyên bố hoàn thành nếu chưa chạy kiểm tra trong Godot/Android.
