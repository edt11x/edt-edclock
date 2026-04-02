import sys
from datetime import datetime, date
import calendar

# Set calendar to start on Sunday to match UI headers (S M T W T F S)
calendar.setfirstweekday(calendar.SUNDAY)

from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QGridLayout, QFrame
)
from PySide6.QtCore import Qt, QTimer, QPoint
from PySide6.QtGui import QFont, QColor, QPalette

# ── Color palette ──────────────────────────────────────────────────────────────
C_BG          = "rgba(13, 13, 20, 240)"
C_BORDER      = "rgba(120, 100, 255, 80)"
C_HOUR        = "#60a5fa"                    # blue       – hours
C_MIN         = "#a78bfa"                    # violet     – minutes
C_SEC         = "#34d399"                    # emerald    – seconds
C_COLON       = "rgba(255, 255, 255, 60)"
C_DAY_NAME    = "#f472b6"                    # rose       – day of week
C_DATE        = "rgba(255, 255, 255, 155)"
C_MON_LABEL   = "#a5b4fc"                    # lavender   – month/year
C_NAV_BTN     = "#a5b4fc"
C_TODAY_BG    = "#6d28d9"                    # deep violet – today pill
C_WEEKEND_NUM = "#f87171"                    # red-ish    – weekend day numbers
C_HDR_WEEK    = "rgba(255, 255, 255, 110)"
C_HDR_WKEND   = "rgba(248, 113, 113, 190)"  # pinkish    – S/S column headers


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

        self.prev_year_btn  = QPushButton("«")
        self.prev_month_btn = QPushButton("‹")
        self.month_year_label = QLabel()
        self.next_month_btn = QPushButton("›")
        self.next_year_btn  = QPushButton("»")

        for btn in [self.prev_year_btn, self.prev_month_btn,
                    self.next_month_btn, self.next_year_btn]:
            btn.setFixedSize(20, 20)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setStyleSheet(f"""
                QPushButton {{
                    background: transparent;
                    color: {C_NAV_BTN};
                    border: none;
                    font-size: 14px;
                    border-radius: 4px;
                }}
                QPushButton:hover {{
                    background: rgba(124, 111, 247, 0.25);
                    color: white;
                }}
            """)

        self.month_year_label.setAlignment(Qt.AlignCenter)
        self.month_year_label.setStyleSheet(
            f"font-weight: 700; font-size: 12px; color: {C_MON_LABEL}; letter-spacing: 0.5px;"
        )

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

        # Weekday headers – S/S columns tinted pink
        weekdays_layout = QGridLayout()
        weekdays_layout.setSpacing(1)
        for i, day in enumerate(["S", "M", "T", "W", "T", "F", "S"]):
            label = QLabel(day)
            label.setAlignment(Qt.AlignCenter)
            color = C_HDR_WKEND if i in (0, 6) else C_HDR_WEEK
            label.setStyleSheet(f"font-size: 10px; font-weight: 700; color: {color};")
            weekdays_layout.addWidget(label, 0, i)
        self.layout.addLayout(weekdays_layout)

        # Day grid
        self.grid_layout = QGridLayout()
        self.grid_layout.setSpacing(1)
        self.layout.addLayout(self.grid_layout)

        self.update_calendar()

    def change_date(self, months=0, years=0):
        new_month = self.view_date.month + months
        new_year  = self.view_date.year  + years
        while new_month > 12:
            new_month -= 12
            new_year  += 1
        while new_month < 1:
            new_month += 12
            new_year  -= 1
        self.view_date = date(new_year, new_month, 1)
        self.update_calendar()

    def update_calendar(self):
        for i in reversed(range(self.grid_layout.count())):
            self.grid_layout.itemAt(i).widget().setParent(None)

        year, month = self.view_date.year, self.view_date.month
        self.month_year_label.setText(f"{calendar.month_name[month]} {year}")

        today = date.today()
        for row_idx, week in enumerate(calendar.monthcalendar(year, month)):
            for col_idx, day in enumerate(week):
                if day == 0:
                    continue
                label = QLabel(str(day))
                label.setAlignment(Qt.AlignCenter)
                label.setFixedSize(32, 18)

                is_today   = (day == today.day and month == today.month and year == today.year)
                is_weekend = col_idx in (0, 6)

                if is_today:
                    style = f"""
                        QLabel {{
                            font-size: 11px;
                            font-weight: 700;
                            border-radius: 4px;
                            color: white;
                            background: {C_TODAY_BG};
                        }}
                    """
                elif is_weekend:
                    style = f"""
                        QLabel {{
                            font-size: 11px;
                            border-radius: 3px;
                            color: {C_WEEKEND_NUM};
                        }}
                        QLabel:hover {{
                            background: rgba(248, 113, 113, 0.12);
                        }}
                    """
                else:
                    style = """
                        QLabel {
                            font-size: 11px;
                            border-radius: 3px;
                            color: rgba(255, 255, 255, 195);
                        }
                        QLabel:hover {
                            background: rgba(124, 111, 247, 0.15);
                        }
                    """
                label.setStyleSheet(style)
                self.grid_layout.addWidget(label, row_idx, col_idx)


class EdClock(QMainWindow):
    def __init__(self):
        super().__init__()
        self.drag_pos = QPoint()
        self.init_ui()

    def init_ui(self):
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool)
        self.setAttribute(Qt.WA_TranslucentBackground)

        self.central_widget = QWidget()
        self.central_widget.setObjectName("mainContainer")
        self.setCentralWidget(self.central_widget)

        self.main_layout = QVBoxLayout(self.central_widget)
        self.main_layout.setContentsMargins(20, 6, 20, 10)
        self.main_layout.setSpacing(4)

        self.central_widget.setStyleSheet(f"""
            #mainContainer {{
                background: {C_BG};
                border: 1px solid {C_BORDER};
                border-radius: 14px;
            }}
        """)

        # ── Window controls ────────────────────────────────────────────────────
        controls_layout = QHBoxLayout()

        self.close_btn = QPushButton("×")
        self.close_btn.setFixedSize(20, 20)
        self.close_btn.setCursor(Qt.PointingHandCursor)
        self.close_btn.setStyleSheet("""
            QPushButton {
                background: transparent;
                color: rgba(255, 255, 255, 55);
                border: none;
                font-size: 18px;
            }
            QPushButton:hover { color: #ff6b6b; }
        """)
        self.close_btn.clicked.connect(self.close)

        self.drag_handle = QLabel("⠿")
        self.drag_handle.setStyleSheet(f"color: rgba(165, 180, 252, 65); font-size: 13px;")
        self.drag_handle.setCursor(Qt.OpenHandCursor)

        controls_layout.addWidget(self.close_btn)
        controls_layout.addStretch()
        controls_layout.addWidget(self.drag_handle)
        self.main_layout.addLayout(controls_layout)

        # ── Clock (rich text – H/M/S in distinct colors) ───────────────────────
        self.clock_label = QLabel()
        self.clock_label.setAlignment(Qt.AlignCenter)
        self.clock_label.setTextFormat(Qt.RichText)
        self.clock_label.setStyleSheet(
            "font-size: 40px; font-weight: 700;"
            "font-family: 'JetBrains Mono', monospace;"
            "letter-spacing: -1px;"
        )
        self.main_layout.addWidget(self.clock_label)

        # Thin accent separator
        sep = QFrame()
        sep.setFrameShape(QFrame.HLine)
        sep.setStyleSheet("color: rgba(120, 100, 255, 45);")
        sep.setFixedHeight(1)
        self.main_layout.addWidget(sep)

        # ── Date ───────────────────────────────────────────────────────────────
        self.date_container = QWidget()
        date_layout = QVBoxLayout(self.date_container)
        date_layout.setContentsMargins(0, 0, 0, 0)
        date_layout.setSpacing(1)

        self.day_name_label = QLabel()
        self.day_name_label.setAlignment(Qt.AlignCenter)
        self.day_name_label.setStyleSheet(f"""
            font-size: 13px;
            font-weight: 700;
            color: {C_DAY_NAME};
            letter-spacing: 2px;
        """)

        self.full_date_label = QLabel()
        self.full_date_label.setAlignment(Qt.AlignCenter)
        self.full_date_label.setStyleSheet(f"font-size: 11px; color: {C_DATE};")

        date_layout.addWidget(self.day_name_label)
        date_layout.addWidget(self.full_date_label)
        self.main_layout.addWidget(self.date_container)

        # ── Calendar ───────────────────────────────────────────────────────────
        self.calendar_widget = CalendarWidget()
        self.calendar_widget.setStyleSheet("background: rgba(0, 0, 0, 65); border-radius: 8px;")
        self.main_layout.addWidget(self.calendar_widget)

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_time)
        self.timer.start(1000)
        self.update_time()

        self.setFixedSize(320, 318)

    def update_time(self):
        now = datetime.now()
        h, m, s = now.strftime("%H"), now.strftime("%M"), now.strftime("%S")
        colon = f"<span style='color:{C_COLON}'>:</span>"
        self.clock_label.setText(
            f"<span style='color:{C_HOUR}'>{h}</span>{colon}"
            f"<span style='color:{C_MIN}'>{m}</span>{colon}"
            f"<span style='color:{C_SEC}'>{s}</span>"
        )
        self.day_name_label.setText(now.strftime("%A").upper())
        self.full_date_label.setText(now.strftime("%B %d, %Y"))

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            win = self.windowHandle()
            if win:
                win.startSystemMove()
            else:
                self.drag_pos = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.LeftButton and not self.drag_pos.isNull():
            self.move(event.globalPos() - self.drag_pos)
            event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = EdClock()
    window.show()
    sys.exit(app.exec())
