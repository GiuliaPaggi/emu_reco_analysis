import time
import os
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import pyautogui

# Function to authenticate and get Google Drive service
def authenticate_drive():
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)
    return drive

# Function to take a screenshot
def take_screenshot():
    timestamp = time.strftime("%Y-%m-%d_%H-%M-%S")
    #filename = f"screenshot_{timestamp}.png"
    filename = f"MIC_1.png"
    if os.path.exists(filename):
        os.remove(filename)
    screenshot = pyautogui.screenshot()
    screenshot.save(filename)
    return filename

# Function to upload a file to Google Drive
def upload_to_drive(drive, filename, folder_id):
    try:
        # Check if the file already exists in Google Drive
        file_list = drive.ListFile({'q': f"'{folder_id}' in parents and title = '{os.path.basename(filename)}' and trashed=false"}).GetList()
    
        if file_list:  # If the file exists, update it with the new data
            file = file_list[0]
            file.SetContentFile(filename)
            file.Upload()
            current_time = time.strftime("%Y/%m/%d-%H:%M:%S")
            print(f"{ current_time } - Updated {filename} on Google Drive.", end="\r")
        else:  # If the file doesn't exist, create a new one
            file = drive.CreateFile({'title': os.path.basename(filename), 'parents': [{'id': folder_id}]})
            file.SetContentFile(filename)
            file.Upload()
            print(f"{current_time} - Uploaded {filename} to Google Drive.")
        return 1
    except:
        print(f"Upload failed. Try again.", flush = True)
        return 0
    
# Main function
def main():
    # Interval between screenshots in seconds
    interval = 60 * 30  # 30 minutes
    retry_interval = 60 #  1 minute 
    # Google Drive folder ID where screenshots will be uploaded
    folder_id = '1u6U4zEpMzeOmeBkCG0jVM2ACiA_1qz4l'

    # Authenticate Google Drive
    drive = authenticate_drive()

    try:
        while True:
            counter = 0
            # Take a screenshot
            screenshot_file = take_screenshot()
            # Upload screenshot to Google Drive
            status = upload_to_drive(drive, screenshot_file, folder_id)
            while (not status) : 
                time.sleep(retry_interval)
                counter+=1
                status = upload_to_drive(drive, screenshot_file, folder_id)
                if counter > 3 : 
                    print(f"Retrying in a while.")
                    break

            # Wait for the specified interval before taking the next screenshot
            time.sleep(interval)
    except KeyboardInterrupt:
        print("Screenshot capture stopped.")

if __name__ == "__main__":
    main()