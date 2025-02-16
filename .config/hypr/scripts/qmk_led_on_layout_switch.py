import sys
import hid

vendor_id = 0x414A
product_id = 0x304E

usage_page = 0xFF60
usage = 0x61
report_length = 32

COMMANDS = {
    "bg": 0x01,
    "en": 0x02,
    "off": 0x03,
}

def get_raw_hid_interface():
    device_interfaces = hid.enumerate(vendor_id, product_id)
    raw_hid_interfaces = [i for i in device_interfaces if i['usage_page'] == usage_page and i['usage'] == usage]

    if len(raw_hid_interfaces) == 0:
        return None

    interface = hid.Device(path=raw_hid_interfaces[0]['path'])

    # print(f"Manufacturer: {interface.manufacturer}")
    # print(f"Product: {interface.product}")

    return interface

def send_led_command(command):
    interface = get_raw_hid_interface()

    if interface is None:
        print("No device found")
        sys.exit(1)

    request_data = [0x00] * (report_length + 1)  # First byte is Report ID
    request_data[1] = command  # Set the first data byte to our command
    request_report = bytes(request_data)

    print(f"Sending command: {hex(command)}")
    interface.write(request_report)

    # response_report = interface.read(report_length, timeout=1000)
    # print("Response:", response_report)

    interface.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python test.py <bg|en|off>")
        sys.exit(1)

    command_str = sys.argv[1].lower()  # Convert input to lowercase
    if command_str in COMMANDS:
        send_led_command(COMMANDS[command_str])
    else:
        print(f"Invalid command: {command_str}. Available options: {', '.join(COMMANDS.keys())}")

