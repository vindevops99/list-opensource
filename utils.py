import urllib.parse

# Config tài khoản VietQR
BANK_CODE = "MB"
ACCOUNT_NUMBER = "2040108383002"

def generate_qr(amount, phone, service):
    """
    Trả về URL QR VietQR với nội dung chuyển khoản:
    'SĐT khách hàng - Tên dịch vụ'
    """
    qr_note = f"{phone} - {service}"   # chỉ dùng SĐT - dịch vụ
    qr_note_encoded = urllib.parse.quote(qr_note)
    qr_url = f"https://img.vietqr.io/image/{BANK_CODE}-{ACCOUNT_NUMBER}-compact2.png?amount={amount}&addInfo={qr_note_encoded}"
    return qr_url

