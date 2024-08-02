import customtkinter as ctk
import tkinter

from PIL import Image, ImageTk

SCREEN = ctk.CTk()
SCREEN.geometry(f"{1000}x{600}")

BACKGROUND_PATH = "IMG\Background.jpg"
BACKGROUND_IMAGE = Image.open(BACKGROUND_PATH)
BACKGROUND_IMAGE = BACKGROUND_IMAGE.resize((1000,600))
BACKGROUND_PHOTO = ImageTk.PhotoImage(BACKGROUND_IMAGE)

BACKGROUND_LABEL = ctk.CTkLabel(SCREEN,
                                width=1000,
                                height=600,
                                image=BACKGROUND_PHOTO,
                                text=""
                                )
BACKGROUND_LABEL.grid(row = 0, column = 0)


SCREEN.mainloop()