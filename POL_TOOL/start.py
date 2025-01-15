from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QVBoxLayout, QLabel, QMessageBox, QDialog, QDialogButtonBox
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QIcon
import sys
import subprocess
import os

class App(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("POL Launcher for Multiboxers")
        self.setGeometry(400, 400, 500, 250)
        self.setWindowIcon(QIcon('app.ico')) 

        layout = QVBoxLayout()

        self.main_description_label = QLabel("This application allows you to run scripts for multiple characters in the POL Launcher.")
        self.main_description_label.setAlignment(Qt.AlignCenter)
        self.main_description_label.setStyleSheet("font-size: 14px; color: white; margin-bottom: 15px;")
        layout.addWidget(self.main_description_label)

        self.description_label = QLabel("Start Char1 Script")
        self.description_label.setAlignment(Qt.AlignCenter)
        self.description_label.setStyleSheet("font-size: 14px; color: white;")
        layout.addWidget(self.description_label)

        self.run_button_char1 = QPushButton("   Start")
        self.run_button_char1.clicked.connect(lambda: self.run_script("char1.ps1"))
        layout.addWidget(self.run_button_char1)

        layout.addSpacing(20)

        self.description_label = QLabel("Start Char2 Script")
        self.description_label.setAlignment(Qt.AlignCenter)
        self.description_label.setStyleSheet("font-size: 14px; color: white;")
        layout.addWidget(self.description_label)

        self.run_button_char2 = QPushButton("   Start")
        self.run_button_char2.clicked.connect(lambda: self.run_script("char2.ps1"))
        layout.addWidget(self.run_button_char2)

        layout.addSpacing(20)

        self.quit_button = QPushButton("   Exit")
        self.quit_button.clicked.connect(self.exit_application)
        layout.addWidget(self.quit_button)

        self.setLayout(layout)

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

        self.quit_button.setObjectName("quit_button")

    def run_script(self, script_name):
        current_script_dir = os.path.dirname(os.path.realpath(sys.argv[0])) 

        sibling_script_path = os.path.join(current_script_dir, script_name)

        if not os.path.exists(sibling_script_path):  
            self.show_error("Script not found", f"Script not found: {sibling_script_path}")
            return

        command = [
            "powershell.exe",
            "-ExecutionPolicy", "Bypass",
            "-NoProfile",
            "-File", sibling_script_path
        ]

        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        except Exception as e:
            self.show_error("Execution Failed", f"Error executing script: {str(e)}")

    def show_error(self, title, message):
        QMessageBox.critical(self, title, message)

    def exit_application(self):
        dialog = QDialog(self)
        dialog.setWindowTitle("Exit Application")
        
        dialog_layout = QVBoxLayout()
        label = QLabel("Are you sure you want to exit?\n")
        
        dialog_layout.addWidget(label)

        button_box = QDialogButtonBox(QDialogButtonBox.Yes | QDialogButtonBox.No)
        
        yes_button = button_box.button(QDialogButtonBox.Yes)
        yes_button.setText("   Exit Now")  
        yes_button.setStyleSheet("background-color: #D32F2F; color: white;")  
        no_button = button_box.button(QDialogButtonBox.No)
        no_button.setText("Cancel") 
        no_button.setStyleSheet("background-color: #4CAF50; color: white;") 

        button_box.accepted.connect(dialog.accept)
        button_box.rejected.connect(dialog.reject)

        dialog_layout.addWidget(button_box)
        dialog.setLayout(dialog_layout)

        result = dialog.exec_()

        if result == QDialog.Accepted:
            self.close()

    def closeEvent(self, event):
        event.accept()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = App()
    window.show()
    sys.exit(app.exec_())
