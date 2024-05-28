import tkinter as tk

class Fenetre :
    
    def __init__(self) :
        self.root = tk.Tk()
        self.root.title("TikTakToe")
        self.root.geometry("800x800")
        self.compteur = 0
        self.button = []
        self.current_player = 'X'
        
        
    
    def open_root(self):
        return self.root.mainloop()
    
    
    def creer_grille(self):
        self.root.configure(bg='blue')
        for column in range(3):
            button_in_cols = []
            for row in range(3):
                bouton = tk.Button(
                    self.root, font=("Arial", 15),
                    width=20, height=8,
                    command= lambda r=row, c=column:self.action_click(r, c)
                    )
                bouton.grid(row=row, column=column, padx=2, pady=2)
                button_in_cols.append(bouton)
            self.button.append(button_in_cols)
                

    def action_click(self, row, column):
        print("click", row, column)
        cliked_button = self.button[column][row]
        if cliked_button['text'] == '':
            cliked_button.config(text=self.current_player)
        
            self.check_win(row, column)
        
        
    def check_win(self, clicked_row, clicked_column):
        
        #Detecter victoire horizontale
        count = 0
        for i in range(3):
            current_button = self.button[i][clicked_row]
            
            if current_button['text'] == self.current_player:
                count += 1
        if count == 3:
            self.victoire()
        
        
        #Detecter victoire verticale
        count = 0
        for i in range(3):
            current_button = self.button[clicked_column][i]
            
            if current_button['text'] == self.current_player:
                count += 1
        if count == 3:
            self.victoire()
            
            
        
        #Detecter victoire diagonale
        count = 0
        for i in range(3):
            current_button = self.button[i][i]
            
            if current_button['text'] == self.current_player:
                count += 1
        if count == 3:
            self.victoire()
            
            
        #Detecter victoire diagonale inverse
        count = 0
        for i in range(3):
            current_button = self.button[2-i][i]
            
            if current_button['text'] == self.current_player:
                count += 1
        if count == 3:
            self.victoire()
        
        self.partie_null()
        self.switch_player()
            
            
    
    def victoire(self):
        print(f'Le joueur {self.current_player} a gagné !')
        
        
    def partie_null(self):
        count=0
        for column in range(3):
            for row in range(3):
                current_button = self.button[column][row]
                if current_button['text'] == 'X' or current_button['text'] == 'O':
                    count += 1
        if count == 9:
            print('EGALITE')
            
            
    
    def switch_player(self):
        if self.current_player == 'X':
            self.current_player = 'O'
        else:
            self.current_player = 'X'
                    
                
            
            
        
        
        
        
        

mon_jeu = Fenetre()
mon_jeu.creer_grille()
mon_jeu.open_root()
