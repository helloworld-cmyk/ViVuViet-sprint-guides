#!/bin/bash
# ============================================================
# Script: run.sh
# Mục đích: Map qldt.hust.edu.vn -> localhost (127.0.0.1) và ngược lại
# ============================================================

set -e

DOMAIN="qldt.hust.edu.vn"
HOSTS_FILE="/etc/hosts"

# -------------------- HÀM PHỤ TRỢ --------------------

flush_dns() {
  echo ">>> Xóa cache DNS..."
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  echo ">>> Đã xóa cache DNS."
}

# -------------------- XỬ LÝ THAM SỐ --------------------

case "$1" in
  add)
    # Đặt qldt.hust.edu.vn -> localhost (127.0.0.1)
    echo ">>> Thêm dòng map: 127.0.0.1 $DOMAIN vào $HOSTS_FILE"
    if grep -q "^127.0.0.1 $DOMAIN" "$HOSTS_FILE"; then
      echo ">>> Dòng map đã tồn tại, bỏ qua."
    else
      echo "127.0.0.1 $DOMAIN" | sudo tee -a "$HOSTS_FILE"
    fi
    flush_dns
    echo ""
    echo ">>> Hoàn tất! Truy cập: https://$DOMAIN"
    ;;

  remove)
    # Xóa dòng map để đặt lại mặc định (IP thật của HUST)
    echo ">>> Xóa mọi dòng chứa $DOMAIN trong $HOSTS_FILE"
    sudo sed -i '' "/$DOMAIN/d" "$HOSTS_FILE"
    flush_dns
    echo ""
    echo ">>> Hoàn tất! $DOMAIN đã trở về IP thật của HUST."
    ;;

  comment)
    # Vô hiệu hóa tạm thời (comment) - giữ lại để dễ bật lại
    echo ">>> Comment dòng map $DOMAIN trong $HOSTS_FILE"
    sudo sed -i '' "s/^127.0.0.1 $DOMAIN/#127.0.0.1 $DOMAIN/" "$HOSTS_FILE"
    flush_dns
    echo ""
    echo ">>> Hoàn tất! $DOMAIN đã bị comment (tạm thời quay về IP thật)."
    ;;

  uncomment)
    # Bật lại mapping (bỏ comment)
    echo ">>> Bỏ comment dòng map $DOMAIN trong $HOSTS_FILE"
    sudo sed -i '' "s/^#127.0.0.1 $DOMAIN/127.0.0.1 $DOMAIN/" "$HOSTS_FILE"
    flush_dns
    echo ""
    echo ">>> Hoàn tất! Truy cập: https://$DOMAIN"
    ;;

  status)
    # Kiểm tra hiện tại domain đang trỏ về đâu
    echo ">>> Kiểm tra file $HOSTS_FILE:"
    grep "$DOMAIN" "$HOSTS_FILE" || echo "    (Không có dòng nào liên quan đến $DOMAIN trong hosts file)"
    echo ""
    echo ">>> Ping $DOMAIN:"
    ping -c 1 "$DOMAIN" 2>&1 | head -1 || true
    ;;

  *)
    echo "Sử dụng: ./run.sh {add|remove|comment|uncomment|status}"
    echo ""
    echo "  add       - Map $DOMAIN -> localhost (127.0.0.1, thêm vào /etc/hosts)"
    echo "  remove    - Xóa map, $DOMAIN trở về IP thật của HUST"
    echo "  comment   - Vô hiệu hóa tạm thời (thêm dấu # đầu dòng)"
    echo "  uncomment - Bật lại map đã bị comment"
    echo "  status    - Kiểm tra $DOMAIN đang trỏ về đâu"
    echo ""
    echo "Ví dụ:"
    echo "  ./run.sh add      # Map domain -> localhost"
    echo "  ./run.sh remove   # Xóa map"
    echo "  ./run.sh status   # Kiểm tra domain đang trỏ về đâu"
    exit 1
    ;;
esac