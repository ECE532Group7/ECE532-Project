#!/usr/bin/env python
# Written by Jackson Banbury and Group 7 for ECE532 March, 2018
# Using Android IP Webcam video .jpg stream (tested) in Python2 OpenCV3

#from urllib.request import urlopen
#import cv2
import requests
import numpy as np
import time
import socket
import time
from io import BytesIO
from PIL import Image
import RPi.GPIO as GPIO
def send_gpio(img):

    #Pin used for reset
    gpio_rst = 12

    #Pin used for clk
    gpio_clk = 1

    #Array of pin numbers (BCM) where the index is the bit in the color
    gpio_list = [14,15,18,23,24,25,8,7]

    #Initializing the pins...
    GPIO.setup(gpio_rst, GPIO.OUT)
    GPIO.setup(gpio_clk, GPIO.OUT)

    for pin in range(8):
        GPIO.setup(gpio_list[pin], GPIO.OUT)

    #Reset HIGH
    GPIO.output(gpio_rst, GPIO.HIGH)
    time.sleep(0.025)
    #GPIO.output(gpio_clk, GPIO.LOW)
    time.sleep(0.025)
    GPIO.output(gpio_clk, GPIO.HIGH)
    time.sleep(0.025)
    GPIO.output(gpio_clk, GPIO.LOW)
    time.sleep(0.025)
    GPIO.output(gpio_clk, GPIO.HIGH)
    time.sleep(0.025)
    GPIO.output(gpio_clk, GPIO.LOW)
    #wait a small amount of time
    time.sleep(0.001)
    #Set reset low again
    GPIO.output(gpio_rst, GPIO.LOW)

    #perform the  operations on each color of each pixel
    for pixel_row in range(72):
        for pixel_col in range(72):
            for color in range(3):
                p = 0
                bin_color = '{0:08b}'.format(img[pixel_row,pixel_col,color])
                #if(color==0): print("...")
                #print(type(bin_color))
                #This is reversed because the FPGA has opposite endianness than the pi apparently
                for digit in bin_color:
                    pin = gpio_list[p]
                    if(digit=='1'):
                    #if(color==2):
                        GPIO.output(pin, GPIO.HIGH)
                    else:
                        GPIO.output(pin, GPIO.LOW)
                    p+=1
                    time.sleep(0.00001)
                #Wait before raising clk
                time.sleep(0.00001)

                #Raise the clk to validate the data (so FPGA reads)
                GPIO.output(gpio_clk, GPIO.HIGH)

                #Sleep for 10 microseconds to ensure GPIO data is read
                time.sleep(0.00001)

                #Lower the clk before moving to next
                GPIO.output(gpio_clk, GPIO.LOW)

                #Sleep for 10 microsecond afterwards just because
                time.sleep(0.00001)

    print("Done sending image")
    for pin in range(8):
        GPIO.output(gpio_list[pin], GPIO.LOW)

    GPIO.cleanup()
def writecsv(img):

    #open a file to write the pixel data

    #img = np.asarray(img, dtype="int")
    print(np.shape(img))
    np.savetxt("selfie.csv", img, delimiter = "," , fmt="%d,%d,%d")

    # with open('selfie.csv', 'w+') as f:
    #   #f.write('R,G,B\n')
    #
    #   #read the details of each pixel and write them to the file
    #   for x in range(width):
    #     for y in range(height):
    #       r = img[x,y][0]
    #       g = img[x,y][1]
    #       b = img[x,y][2]
    #       f.write('{0},{1},{2}\n'.format(r,g,b))


def send_tcp(img):

    # Define TCP parameters here
    tcp_ip = '127.0.0.1'
    tcp_port = 50005
    buffer_size = 4096


    # Establish connection
    print("Sending image...")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((tcp_ip, tcp_port))

    # Serialize the image array
    #img_string = pickle.dumps(img)

    s.send(img)

    #time.sleep(20)

    #data = s.recv(4096)
    #data_arr = pickle.loads(data)

    # Close the connection
    s.close()

    return None

if __name__ == "__main__":

    # Replace the URL with your own IPwebcam shot.jpg IP:port
    url='http://192.168.43.1:8080/shot.jpg'

    #Set the GPIO pin mode to the BCM numbering system
    GPIO.setmode(GPIO.BCM)

    btn_pin = 4

    GPIO.setup(btn_pin, GPIO.IN)

    height = 72
    width = 72

    #print("Press 's' to send photo, 'q' to quit program")

    while True:

        # Use requests to get the image from the IP camera
        url_image = requests.get(url)
        img = Image.open(BytesIO(url_image.content))
        #print(img)
        img = np.array(img)
        #print(np.shape(img))
        cropped_img = img[52:124,36:108]

        #To give the processor some less stress
        time.sleep(0.1)

        # Send the current image with s
        #if cv2.waitKey(1) & 0xFF == ord('s'):

        print('Press enter to send image...')
        pause=input('')
        print('Sending image to FPGA...')

        send_gpio(cropped_img)

        # if GPIO.input(btn_pin):
        #
        #     send_gpio(cropped_img)
        #     #writecsv(cropped_img)
        #     #readcsv()
        #     #send_tcp(cropped_img)
