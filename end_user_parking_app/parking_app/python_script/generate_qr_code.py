import qrcode
import sys

def generate_qr_code(vehicle_number, booking_time, vehicle_type, parking_space_name, filename):
    data = f"{vehicle_number}\n{booking_time}\n{vehicle_type}\n{parking_space_name}"
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    img.save(filename)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python generate_qr_code.py <vehicle_number> <booking_time> <vehicle_type> <parking_space_name> <filename>")
        sys.exit(1)

    vehicle_number = sys.argv[1]
    booking_time = sys.argv[2]
    vehicle_type = sys.argv[3]
    parking_space_name = sys.argv[4]
    filename = sys.argv[5]

    generate_qr_code(vehicle_number, booking_time, vehicle_type, parking_space_name, filename)
    print("QR code generated successfully.")
