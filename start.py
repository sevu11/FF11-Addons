from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QVBoxLayout, QLabel, QMessageBox
from PyQt5.QtCore import Qt  # Import Qt for alignment constants
import sys
import subprocess
import os

class App(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("POL Launcher for Multiboxers")
        self.setGeometry(400, 400, 500, 250)  # Increased height to accommodate more text

        layout = QVBoxLayout()

        # Add the main description about the app
        self.main_description_label = QLabel("This application allows you to run scripts for multiple characters in the POL Launcher.")
        self.main_description_label.setAlignment(Qt.AlignCenter)
        self.main_description_label.setStyleSheet("font-size: 14px; color: white; margin-bottom: 15px;")
        layout.addWidget(self.main_description_label)

        # Add description for the first script
        self.description_label = QLabel("Start Char1 Script")
        self.description_label.setAlignment(Qt.AlignCenter)
        self.description_label.setStyleSheet("font-size: 14px; color: white;")
        layout.addWidget(self.description_label)

        # Button to run the first script
        self.run_button_char1 = QPushButton("   Start")
        self.run_button_char1.clicked.connect(lambda: self.run_script("char1.ps1"))
        layout.addWidget(self.run_button_char1)

        layout.addSpacing(20)

        # Add description for the second script
        self.description_label = QLabel("Start Char2 Script")
        self.description_label.setAlignment(Qt.AlignCenter)
        self.description_label.setStyleSheet("font-size: 14px; color: white;")
        layout.addWidget(self.description_label)

        # Button to run the second script
        self.run_button_char2 = QPushButton("   Start")
        self.run_button_char2.clicked.connect(lambda: self.run_script("char2.ps1"))
        layout.addWidget(self.run_button_char2)

        layout.addSpacing(20)  # Adds 20 pixels of space

        # Exit button with red color
        self.quit_button = QPushButton("   Exit")
        self.quit_button.clicked.connect(self.close)
        layout.addWidget(self.quit_button)

        self.setLayout(layout)

        # Modern style with a red exit button
        self.setStyleSheet("""
            QWidget {
                background-color: #2C2F36;
                color: white;
                font-family: "Segoe UI";
            }
            QPushButton {
                background-color: #4CAF50;
                color: white;
                padding: 5px;
                font-size: 16px;
                border-radius: 5px;
                border: none;
                margin: 1px;
            }
            QPushButton:hover {
                background-color: #45a049;
            }
            QPushButton:pressed {
                background-color: #388e3c;
            }
            #quit_button {
                background-color: #D32F2F;
                color: white;
            }
            #quit_button:hover {
                background-color: #e57373;
            }
            #quit_button:pressed {
                background-color: #c62828;
            }
        """)

        # To explicitly set the quit_button style in PyQt5, you need to use objectName
        self.quit_button.setObjectName("quit_button")

    # Function to run the PowerShell script
    def run_script(self, script_name):
        current_script_dir = os.path.dirname(os.path.realpath(__file__))  # Get current directory of the Python script
        sibling_script_path = os.path.join(current_script_dir, script_name)  # Path to the script (char1.ps1 or char2.ps1)

        if not os.path.exists(sibling_script_path):  # Check if the script exists
            self.show_error("Script not found", f"Script not found: {sibling_script_path}")
            return

        # Construct the PowerShell command to run the script
        command = [
            "powershell.exe",
            "-ExecutionPolicy", "Bypass",  # Set ExecutionPolicy to Bypass
            "-NoProfile",                  # Skip profile loading
            "-File", sibling_script_path   # Path to the .ps1 script
        ]

        try:
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError as e:
            self.show_error("Execution Failed", f"Error executing script: {e}")

    # Function to show error message
    def show_error(self, title, message):
        QMessageBox.critical(self, title, message)

if __name__ == '__main__':
    app = QApplication(sys.argv) 
    window = App()  
    window.show() 
    sys.exit(app.exec_()) 
