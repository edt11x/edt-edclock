import sys
from datetime import datetime, date
import calendar
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QGridLayout, QFrame
)
from PySide6.QtCore import Qt, QTimer, QPoint, QSize
from PySide6.QtGui import QFont, QColor, QPalette

class CalendarWidget(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.view_date = date.today()
        self.init_ui()

    def init_ui(self):
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(6, 2, 6, 6)
        self.layout.setSpacing(2)

        # Header
        header_layout = QHBoxLayout()
        
        self.prev_year_btn = QPushButton("«")
        self.prev_month_btn = QPushButton("‹")
        self.month_year_label = QLabel()
        self.next_month_btn = QPushButton("›")
        self.next_year_btn = QPushButton("»")

        for btn in [self.prev_year_btn, self.prev_month_btn, self.next_month_btn, self.next_year_btn]:
            btn.setFixedSize(20, 20)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setStyleSheet("""
                QPushButton {
                    background: transparent;
                    color: white;
                    border: none;
                    font-size: 14px;
                    border-radius: 4px;
                }
                QPushButton:hover {
                    background: rgba(255, 255, 255, 0.1);
                }
            """)

        self.month_year_label.setAlignment(Qt.AlignCenter)
        self.month_year_label.setStyleSheet("font-weight: 600; font-size: 12px; color: white;")

        self.prev_year_btn.clicked.connect(lambda: self.change_date(years=-1))
        self.prev_month_btn.clicked.connect(lambda: self.change_date(months=-1))
        self.next_month_btn.clicked.connect(lambda: self.change_date(months=1))
        self.next_year_btn.clicked.connect(lambda: self.change_date(years=1))

        header_layout.addWidget(self.prev_year_btn)
        header_layout.addWidget(self.prev_month_btn)
        header_layout.addStretch()
        header_layout.addWidget(self.month_year_label)
        header_layout.addStretch()
        header_layout.addWidget(self.next_month_btn)
        header_layout.addWidget(self.next_year_btn)
        
        self.layout.addLayout(header_layout)

        # Weekdays
        weekdays_layout = QGridLayout()
        weekdays_layout.setSpacing(1)
        weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for i, day in enumerate(weekdays):
            label = QLabel(day)
            label.setAlignment(Qt.AlignCenter)
            label.setStyleSheet("font-size: 10px; font-weight: 700; color: rgba(255, 255, 255, 0.5);")
            weekdays_layout.addWidget(label, 0, i)
        self.layout.addLayout(weekdays_layout)

        # Grid
        self.grid_layout = QGridLayout()
        self.grid_layout.setSpacing(1)
        self.layout.addLayout(self.grid_layout)

        self.update_calendar()

    def change_date(self, months=0, years=0):
        new_month = self.view_date.month + months
        new_year = self.view_date.year + years
        
        while new_month > 12:
            new_month -= 12
            new_year += 1
        while new_month < 1:
            new_month += 12
            new_year -= 1
            
        self.view_date = date(new_year, new_month, 1)
        self.update_calendar()

    def update_calendar(self):
        # Clear grid
        for i in reversed(range(self.grid_layout.count())): 
            self.grid_layout.itemAt(i).widget().setParent(None)

        year, month = self.view_date.year, self.view_date.month
        self.month_year_label.setText(f"{calendar.month_name[month]} {year}")

        cal = calendar.monthcalendar(year, month)
        today = date.today()

        for row_idx, week in enumerate(cal):
            for col_idx, day in enumerate(week):
                if day == 0:
                    continue
                
                label = QLabel(str(day))
                label.setAlignment(Qt.AlignCenter)
                label.setFixedSize(32, 18)
                
                is_today = (day == today.day and month == today.month and year == today.year)
                
                style = """
                    QLabel {
                        font-size: 11px;
                        border-radius: 3px;
                        color: white;
                    }
                    QLabel:hover {
                        background: rgba(255, 255, 255, 0.05);
                    }
                """
                if is_today:
                    style += """
                        QLabel {
                            background: #646cff;
                            font-weight: 700;
                        }
                    """
                label.setStyleSheet(style)
                self.grid_layout.addWidget(label, row_idx, col_idx)

class EdClock(QMainWindow):
    def __init__(self):
        super().__init__()
        self.init_ui()
        self.drag_pos = QPoint()

    def init_ui(self):
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool)
        self.setAttribute(Qt.WA_TranslucentBackground)
        
        self.central_widget = QWidget()
        self.central_widget.setObjectName("mainContainer")
        self.setCentralWidget(self.central_widget)
        
        # Main Layout
        self.main_layout = QVBoxLayout(self.central_widget)
        self.main_layout.setContentsMargins(20, 6, 20, 10)
        self.main_layout.setSpacing(4)

        # Style sheet for main container
        self.central_widget.setStyleSheet("""
            #mainContainer {
                background: rgba(20, 20, 25, 230);
                border: 1px solid rgba(255, 255, 255, 25);
                border-radius: 12px;
            }
        """)

        # Window Controls (Close & Drag)
        controls_layout = QHBoxLayout()
        
        self.close_btn = QPushButton("×")
        self.close_btn.setFixedSize(20, 20)
        self.close_btn.setCursor(Qt.PointingHandCursor)
        self.close_btn.setStyleSheet("""
            QPushButton {
                background: transparent;
                color: rgba(255, 255, 255, 75);
                border: none;
                font-size: 18px;
                line-height: 1;
            }
            QPushButton:hover {
                color: #ff6b6b;
            }
        """)
        self.close_btn.clicked.connect(self.close)
        
        self.drag_handle = QLabel("⋮")
        self.drag_handle.setStyleSheet("color: rgba(255, 255, 255, 50); font-size: 14px;")
        self.drag_handle.setCursor(Qt.OpenHandCursor)

        controls_layout.addWidget(self.close_btn)
        controls_layout.addStretch()
        controls_layout.addWidget(self.drag_handle)
        self.main_layout.addLayout(controls_layout)

        # Clock
        self.clock_label = QLabel()
        self.clock_label.setAlignment(Qt.AlignCenter)
        self.clock_label.setStyleSheet("""
            font-size: 40px;
            font-weight: 700;
            color: white;
            letter-spacing: -1px;
        """)
        # Try to use JetBrains Mono if available
        font = QFont("JetBrains Mono")
        if not font.exactMatch():
            font = QFont("monospace")
        self.clock_label.setFont(font)
        self.main_layout.addWidget(self.clock_label)

        # Date
        self.date_container = QWidget()
        date_layout = QVBoxLayout(self.date_container)
        date_layout.setContentsMargins(0, 0, 0, 0)
        date_layout.setSpacing(1)
        
        self.day_name_label = QLabel()
        self.day_name_label.setAlignment(Qt.AlignCenter)
        self.day_name_label.setStyleSheet("""
            font-size: 14px;
            font-weight: 600;
            color: #646cff;
            text-transform: uppercase;
        """)
        
        self.full_date_label = QLabel()
        self.full_date_label.setAlignment(Qt.AlignCenter)
        self.full_date_label.setStyleSheet("""
            font-size: 11px;
            color: rgba(255, 255, 255, 180);
        """)
        
        date_layout.addWidget(self.day_name_label)
        date_layout.addWidget(self.full_date_label)
        self.main_layout.addWidget(self.date_container)

        # Calendar
        self.calendar_widget = CalendarWidget()
        self.calendar_widget.setStyleSheet("""
            background: rgba(0, 0, 0, 50);
            border-radius: 6px;
        """)
        self.main_layout.addWidget(self.calendar_widget)

        # Timer
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_time)
        self.timer.start(1000)
        self.update_time()

        self.setFixedSize(320, 310)

    def update_time(self):
        now = datetime.now()
        self.clock_label.setText(now.strftime("%H:%M:%S"))
        self.day_name_label.setText(now.strftime("%A"))
        self.full_date_label.setText(now.strftime("%B %d, %Y"))

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            # startSystemMove() delegates dragging to the compositor,
            # which is required for Wayland/GNOME where globalPos() is unreliable.
            win = self.windowHandle()
            if win:
                win.startSystemMove()
            else:
                # Fallback for X11 without compositor delegation
                self.drag_pos = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        # Only used as fallback when startSystemMove() is unavailable
        if event.buttons() == Qt.LeftButton and not self.drag_pos.isNull():
            self.move(event.globalPos() - self.drag_pos)
            event.accept()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = EdClock()
    window.show()
    sys.exit(app.exec())
