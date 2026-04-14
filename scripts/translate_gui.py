#!/usr/bin/env python3

import base64
import sys
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout,
    QTextEdit, QPushButton, QLabel,
)
from PyQt6.QtCore import Qt, QThread, QByteArray, pyqtSignal
from PyQt6.QtGui import QKeySequence, QShortcut, QPalette, QColor, QIcon, QPixmap
from deep_translator import GoogleTranslator

# icon.svg embedded as base64 so the project is a single file
_ICON_B64 = (
    b"PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIg"
    b"NTEyIj4KICA8IS0tIEFwcCBiYWNrZ3JvdW5kIC0tPgogIDxyZWN0IHdpZHRoPSI1MTIiIGhlaWdo"
    b"dD0iNTEyIiByeD0iOTYiIGZpbGw9IiM0MDNlNDEiLz4KCiAgPCEtLSBMZWZ0IGJ1YmJsZSAoTW9u"
    b"b2thaSBwaW5rKSDigJQgc2xpZ2h0bHkgYmVoaW5kIC0tPgogIDxyZWN0IHg9IjM2IiB5PSI3MiIg"
    b"d2lkdGg9IjI1NiIgaGVpZ2h0PSIyMDgiIHJ4PSIyNiIgZmlsbD0iI2ZmNjE4OCIvPgogIDxwYXRo"
    b"IGQ9Ik0gNjQsMjgwIEwgMjgsMzY0IEwgMTU4LDI4MCBaIiBmaWxsPSIjZmY2MTg4Ii8+CgogIDwh"
    b"LS0gUmlnaHQgYnViYmxlIChNb25va2FpIHllbGxvdykg4oCUIGluIGZyb250LCBvZmZzZXQgZG93"
    b"bi1yaWdodCAtLT4KICA8cmVjdCB4PSIyMjAiIHk9IjE3MiIgd2lkdGg9IjI1NiIgaGVpZ2h0PSIy"
    b"MDgiIHJ4PSIyNiIgZmlsbD0iI2ZmZDg2NiIvPgogIDxwYXRoIGQ9Ik0gNDQ2LDM4MCBMIDQ4Miw0"
    b"NjQgTCAzNTIsMzgwIFoiIGZpbGw9IiNmZmQ4NjYiLz4KCiAgPCEtLSAiQSIgY2VudHJlZCBpbiBs"
    b"ZWZ0IGJ1YmJsZSAtLT4KICA8dGV4dCB4PSIxNjQiIHk9IjE3OCIKICAgICAgICBmb250LWZhbWls"
    b"eT0iR2VvcmdpYSIKICAgICAgICBmb250LXNpemU9IjEyOCIgZm9udC13ZWlnaHQ9ImJvbGQiCiAg"
    b"ICAgICAgZmlsbD0id2hpdGUiCiAgICAgICAgdGV4dC1hbmNob3I9Im1pZGRsZSIgZG9taW5hbnQt"
    b"YmFzZWxpbmU9Im1pZGRsZSI+QTwvdGV4dD4KCiAgPCEtLSAi44GCIiBjZW50cmVkIGluIHJpZ2h0"
    b"IGJ1YmJsZSAtLT4KICA8dGV4dCB4PSIzNDgiIHk9IjI3OCIKICAgICAgICBmb250LWZhbWlseT0i"
    b"SGlyYWdpbm8gTWluY2hvIFByb04iCiAgICAgICAgZm9udC1zaXplPSIxMDgiCiAgICAgICAgZmls"
    b"bD0iIzQwM2U0MSIKICAgICAgICB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkb21pbmFudC1iYXNlbGlu"
    b"ZT0ibWlkZGxlIj7jgYI8L3RleHQ+Cjwvc3ZnPgo="
)


def _app_icon() -> QIcon:
    pm = QPixmap()
    pm.loadFromData(QByteArray(base64.b64decode(_ICON_B64)), "SVG")
    return QIcon(pm)


# Monokai Pro Light — warm parchment base, Monokai accent colours.
STYLESHEET = """
QWidget {
    background-color: #f7f3ea;
    color: #403e41;
    font-size: 13px;
}
QTextEdit {
    background-color: #faf7f0;
    border: 1px solid #d8d2c6;
    border-radius: 5px;
    padding: 6px;
    color: #403e41;
    selection-background-color: #ff6188;
    selection-color: #ffffff;
}
QTextEdit#output {
    background-color: #f2ede3;
    border-color: #cec8bc;
}
QPushButton {
    background-color: #ede8de;
    border: 1px solid #c8c2b5;
    border-radius: 5px;
    padding: 5px 16px;
    color: #403e41;
}
QPushButton:hover {
    background-color: #e5e0d5;
    border-color: #b8b2a5;
}
QPushButton:pressed {
    background-color: #d8d3c8;
}
QPushButton:disabled {
    color: #aaa59e;
    background-color: #ede8de;
}
QLabel {
    color: #75715e;
    font-size: 11px;
    font-weight: 600;
    background: transparent;
    border: none;
}
"""


def _monokai_palette() -> QPalette:
    p = QPalette()
    p.setColor(QPalette.ColorRole.Window,          QColor(247, 243, 234))
    p.setColor(QPalette.ColorRole.WindowText,       QColor( 64,  62,  65))
    p.setColor(QPalette.ColorRole.Base,             QColor(250, 247, 240))
    p.setColor(QPalette.ColorRole.AlternateBase,    QColor(242, 237, 227))
    p.setColor(QPalette.ColorRole.Text,             QColor( 64,  62,  65))
    p.setColor(QPalette.ColorRole.Button,           QColor(237, 232, 222))
    p.setColor(QPalette.ColorRole.ButtonText,       QColor( 64,  62,  65))
    p.setColor(QPalette.ColorRole.PlaceholderText,  QColor(170, 165, 158))
    p.setColor(QPalette.ColorRole.Highlight,        QColor(255,  97, 136))  # Monokai pink
    p.setColor(QPalette.ColorRole.HighlightedText,  QColor(255, 255, 255))
    return p


class TranslateWorker(QThread):
    result_en = pyqtSignal(str)
    result_ja = pyqtSignal(str)
    error = pyqtSignal(str)

    def __init__(self, text: str):
        super().__init__()
        self.text = text

    def run(self):
        try:
            en = GoogleTranslator(source="auto", target="en").translate(self.text)
            ja = GoogleTranslator(source="auto", target="ja").translate(self.text)
            self.result_en.emit(en or "")
            self.result_ja.emit(ja or "")
        except Exception as exc:
            self.error.emit(str(exc))


class XlateWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("xlate")
        self.setMinimumSize(800, 480)
        self._worker = None
        self._build_ui()
        self._build_shortcuts()

    def _build_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(6)
        layout.setContentsMargins(10, 10, 10, 10)

        # Input
        layout.addWidget(QLabel("Input"))
        self.input_box = QTextEdit()
        self.input_box.setPlaceholderText("Type or paste text to translate…")
        layout.addWidget(self.input_box, stretch=1)

        # Buttons
        btn_row = QHBoxLayout()
        self.paste_btn = QPushButton("Paste from clipboard")
        self.translate_btn = QPushButton("Translate  ⌘↩")
        self.translate_btn.setDefault(True)
        btn_row.addWidget(self.paste_btn)
        btn_row.addStretch()
        btn_row.addWidget(self.translate_btn)
        layout.addLayout(btn_row)

        # English output
        layout.addWidget(QLabel("English"))
        self.en_box = QTextEdit()
        self.en_box.setObjectName("output")
        self.en_box.setReadOnly(True)
        self.en_box.setPlaceholderText("English translation…")
        layout.addWidget(self.en_box, stretch=1)

        # Japanese output
        layout.addWidget(QLabel("日本語"))
        self.ja_box = QTextEdit()
        self.ja_box.setObjectName("output")
        self.ja_box.setReadOnly(True)
        self.ja_box.setPlaceholderText("日本語訳…")
        layout.addWidget(self.ja_box, stretch=1)

        self.paste_btn.clicked.connect(self._paste_and_translate)
        self.translate_btn.clicked.connect(self._do_translate)

    def _build_shortcuts(self):
        QShortcut(QKeySequence("Escape"), self).activated.connect(self.close)
        # Cmd+Enter on macOS
        QShortcut(QKeySequence("Ctrl+Return"), self).activated.connect(self._do_translate)

    def _paste_and_translate(self):
        text = QApplication.clipboard().text()
        if text:
            self.input_box.setPlainText(text)
            self._do_translate()

    def _do_translate(self):
        text = self.input_box.toPlainText().strip()
        if not text:
            return
        self._set_busy(True)
        self.en_box.setPlainText("…")
        self.ja_box.setPlainText("…")

        self._worker = TranslateWorker(text)
        self._worker.result_en.connect(self.en_box.setPlainText)
        self._worker.result_ja.connect(self.ja_box.setPlainText)
        self._worker.error.connect(self._on_error)
        self._worker.finished.connect(lambda: self._set_busy(False))
        self._worker.start()

    def _on_error(self, msg: str):
        self.en_box.setPlainText(f"Error: {msg}")
        self.ja_box.setPlainText(f"Error: {msg}")

    def _set_busy(self, busy: bool):
        self.translate_btn.setEnabled(not busy)
        self.paste_btn.setEnabled(not busy)
        self.translate_btn.setText("Translating…" if busy else "Translate  ⌘↩")


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("xlate")
    app.setPalette(_monokai_palette())
    app.setStyleSheet(STYLESHEET)
    app.setWindowIcon(_app_icon())
    win = XlateWindow()

    # Auto-load clipboard on startup
    startup_text = app.clipboard().text()
    if startup_text:
        win.input_box.setPlainText(startup_text)
        win._do_translate()

    win.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
