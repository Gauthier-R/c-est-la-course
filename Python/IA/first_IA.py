import numpy as np

x_enter = np.array(([3, 1.5], [2, 1], [4, 1.5], [3, 1], [3.5, 0.5], [2, 0.5], [5.5, 1], [1, 1], [4.5, 1]), dtype=float)
y_colors = np.array(([1],[0],[1],[0],[1],[0],[1],[0]), dtype=float) #Rouge = 1 et Bleu = 0

x_enter = x_enter / np.amax(x_enter, axis=0)

x = np.split(x_enter, [-1])[0] #On garde seulement les valeurs que l'on connaît
x_prediction = np.split(x_enter, [8])[1]



class Neural_Network(object):
    
    def __init__(self) :
        self.inputSize = 2 #Couche d'entrée
        self.outputSize = 1 #Couche de Sortie
        self.hiddenSize = 3 #Couche cachée
        
        #Crée des poids des synapses
        self.W1 = np.random.randn(self.inputSize, self.hiddenSize) #matrice 2x3
        self.W2 = np.random.randn(self.hiddenSize, self.outputSize) #matrice 3x1
        
        
    def forward(self, x):
        
        self.z = np.dot(x, self.W1)
        self.z2 = self.sigmoid(self.z)
        self.z3 = np.dot(self.z2, self.W2)
        out = self.sigmoid(self.z3)
        return out
    
    def sigmoid(self, s):
        return 1/(1+np.exp(-s))
    
    def sigmoidPrime(self, s):
        return s * (1-s)
    
    def backward(self, x, y, o):
        
        self.o_error = y - o
        self.o_delta = self.o_error * self.sigmoidPrime(o)
        
        self.z2_error = self.o_delta.dot(self.W2.T)
        self.z2_delta = self.z2_error * self.sigmoidPrime(self.z2)
        
        self.W1 += x.T.dot(self.z2_delta)
        self.W2 += self.z2.T.dot(self.o_delta) 
        
        
    def train(self, x, y):
        out = self.forward(x)
        self.backward(x,y,out)
        
        
    def predict(self):
        print("Donnée prédite après entraînement : ")  
        print("Entrée : \n " + str(x_prediction))
        print("Sortie : \n " + str(self.forward(x_prediction)))
        
        if self.forward(x_prediction) < 0.5 :
            print("La fleur est BLEU ! \n")
        else :
            print("La fleur est ROUGE ! \n")
    
    
NN = Neural_Network()


for i in range(30000):
    print("# " + str(i) + "\n")
    print("Valeur d'entrées : \n " + str(x))
    print("Valeur actuelle : \n " + str(y_colors))
    print("Sortie prédite : \n " + str(np.matrix.round(NN.forward(x),2)))
    print("\n")
    NN.train(x, y_colors)
    
NN.predict()

#print("Sortit prédit par l'IA : \n" + str(out))
#print("Vrai sorti : \n" + str(y_colors))
        