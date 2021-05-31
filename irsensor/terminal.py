from serial import Serial

ser = Serial("/dev/ttyACM0", 9600)

while(True):
	raw = ser.readline()
	string = raw.decode()
	print(string, end = '')

