import os
import time as t
import sys
import argparse
import subprocess
from skpy import Skype, SkypeMsg
from datetime import datetime, time

def quality(b, p):
    close_pavicom = 'start cmd /k kill_Pavicom.bat'
    subprocess.run(close_pavicom, shell=True)
    t.sleep(2*60) 
    bat_file_path = "C:/Users/sndlhc/check_quality.bat"
    check_quality = f'start cmd /k "{bat_file_path}" {b} {p}'
    subprocess.run(check_quality, shell=True)

def get_seconds_until_8am():
    current_time = datetime.now().time()
    target_time = time(8, 0)  # 8 am

    # Calculate the seconds until 8 am
    target_datetime = datetime.combine(datetime.today(), target_time)
    if current_time <= target_time:
        seconds_until_8am = (target_datetime - datetime.now()).total_seconds()
    else:
        # If it's already past 8 am, calculate the seconds until 8 am of the next day
        target_datetime = target_datetime.replace(day=target_datetime.day + 1)
        seconds_until_8am = (target_datetime - datetime.now()).total_seconds()

    return seconds_until_8am

def is_between_8am_and_8pm():
    current_time = datetime.now().time()
    start_time = time(8, 0)  # 8 am
    end_time = time(20, 0)  # 8 pm

    return start_time <= current_time <= end_time

def tail_grep(filename, pattern):
    try:
        with open(filename, 'r') as file:
            # Read the last 10 lines of the file
            lines = file.readlines()[-10:]

            # Filter lines containing the specified pattern
            filtered_lines = [line.strip() for line in lines if pattern in line]

            return filtered_lines

    except:
        print(f"Failed to open file {filename}")
        return []

def send_alert(text):
    username = "bolognascan@gmail.com"
    password = ""

    sk = Skype(username, password)

    ch = sk.chats["19:f4c38cdb04cc4c73aac08047e3bae313@thread.skype"]
    ch.sendMsg(SkypeMsg.bold(text), rich=True)
 
    #contact = sk.contacts["live:.cid.2a260759f1cd797b"]
    #contact.chat.sendMsg(SkypeMsg.bold(text), rich=True)

def format_seconds(seconds):
    # Calculate hours, minutes, and remaining seconds
    hours, remainder = divmod(seconds, 3600)
    minutes, seconds = divmod(remainder, 60)

    # Create a formatted time string
    time_string = "{:02}h {:02}min {:02}s".format(int(hours), int(minutes), int(seconds))

    return time_string

def check_file_modification(file_path, max_window, is_stopped, b, p):
    try:
        text = ""
        # Get the last modification time of the file
        last_modified_time = os.path.getmtime(file_path)

        # Get the current time
        current_time = t.time()
        curr_date = t.strftime("%Y-%m-%d %H:%M:%S", t.localtime(current_time))
        last_date = t.strftime("%Y-%m-%d %H:%M:%S", t.localtime(last_modified_time))

        last_mod = current_time - last_modified_time

        # Check if the file has been modified within the last max_window minutes
        lines = tail_grep("D:/disp_local/\!Dispatch.log", "Leaving OpDispatch::Stop")
        if len(lines)>0:
            print("Scanning complete\n")
            lines = tail_grep("D:/disp_local/\!Dispatch.log", "time taken")
            print(lines, ' ms')
            quality(b, p)
            sys.exit()
            return False
        else:
            if last_mod < max_window*60:
                print(" " * len(text), end="\r")
                text = f"{curr_date}: The file {file_path} has been modified within the last {max_window} minutes." 
                print(text, end="\r")
                return True
            else:
                print(" " * len(text), end="\r")
                text = f"{curr_date}: [WARNING] The file {file_path} last update was {format_seconds(last_mod)} ago ({last_date})."
                print(text, end="\r")
                send_alert("[MIC 1] "+ text)
                print("\n")
                quality(b, p)
                sys.exit()
                return False

    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('brick', type=int)
    parser.add_argument('plate', type=int)
    args = parser.parse_args()
    brick = args.brick
    plate = args.plate
    
    file_path = f"D:/RUN3_W2_B{brick}/P{plate}/tracks.obx"  # Replace with the path to your file
    max_window = 120 #max minutes before sending warning
    is_stopped = False
    while (True):
        is_stopped = check_file_modification(file_path, max_window, is_stopped, brick, plate)
        t.sleep(10*60)    #check status every 10 min
        if (not is_between_8am_and_8pm()):
            t.sleep(get_seconds_until_8am())
