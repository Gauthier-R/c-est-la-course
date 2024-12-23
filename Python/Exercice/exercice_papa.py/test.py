import customtkinter

app = customtkinter.CTk()

def checkbox_event():
    print("checkbox toggled, current value:", check_var.get())

check_var = customtkinter.StringVar(value="on")
checkbox = customtkinter.CTkCheckBox(app, text="CTkCheckBox", command=checkbox_event,
                                     variable=check_var, onvalue="on", offvalue="off")

checkbox.pack()

app.mainloop()


