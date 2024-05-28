from pytube import YouTube, Playlist, Channel, Search
from tkinter import Tk
from customtkinter import *
 
    


class Youtube :
    
    def __init__(self, link : str, format_video : str) :
        self.yt_link = link #lien à rechercher
        self.format_video = format_video #type de format (MP3 ou MP4)
        
        self.playlist = None #playlist à télécharger
        self.search = None #Liste de vidéos recherché
        self.yt_video = [] #liste des vidéos à paramétrer
        self.yt_video_download = [] #liste des vidéos à télécharger
        
        
        
        #type_download = (video / musique)
        #Quality
        #Download
        
    
    #Vérifier si le lien est une vidéo ou une playlist
    def search_type_of_link(self) :
        #PLAYLIST
        if 'youtube.com/playlist?list=' in self.yt_link:
            print("playlist")
            self.playlist = Playlist(self.yt_link)
            for video in self.playlist:
                self.yt_video.append(YouTube(video, on_progress_callback=self.download_progress))
            
        #VIDEO
        elif 'https://youtu.be/' in self.yt_link:
            print("Vidéo")
            self.yt_video.append(YouTube(self.yt_link, on_progress_callback=self.download_progress))
             
        #ERREUR
        else :
            print("Erreur - Lien non conforme")
            self.search = Search(self.yt_link)
            
            
            
            
    #Récupérer le titre d'une PlayList :
    def get_titre_playlist(self):
        return self.playlist.title

    #Récupérer le nombre de vidéos dans un Playlist :
    def get_nb_video_in_playlist(self):
        return len(self.playlist)
    
    #Récupérer le titre des vidéos :
    def get_titre_video(self):
        for video in self.yt_video:
            return video.title
    
    #Récupérer l'auteur des vidéos :
    def get_author_video(self):
        return self.yt_video[0].author
            
    
    #Définir le format de téléchargement (vidéo / musique)
    def configure_download_type(self):
        if self.format_video == 'MP3':
            for video in self.yt_video :
                self.yt_video_download.append(video.streams.get_audio_only())
        elif self.format_video == 'MP4':
            for video in self.yt_video:
                self.yt_video_download.append(video.streams.get_highest_resolution())
            
            
    #Télécharger les vidéos :
    def download(self, dossier = None):
        for video in self.yt_video_download:
            video.download(dossier)
        print("Téléchargement terminé")

    #Calculer la progression du téléchargement
    def download_progress(self, stream, chunk, bytes_restant):
        taille_totale = stream.filesize
        bytes_telecharge = taille_totale-bytes_restant
        pourcentage_telecharge = bytes_telecharge/taille_totale*100       
        pourcentage_text = str(int(pourcentage_telecharge))
        print(pourcentage_telecharge, pourcentage_text)
        
    
        
            

YTV = Youtube("https://youtu.be/Fiaf796kieI?si=XkqB4FJGPJYbTthM", 'MP3')
YTV.search_type_of_link()
YTV.configure_download_type()
YTV.download()



#https://youtu.be/8J8wWxbAdFg?si=aGU0zr4hrPFSL7zw
#https://www.youtube.com/playlist?list=PLMS9Cy4Enq5KsM7GJ4LHnlBQKTQBV8kaR
 
 
 
        
'''
yt = YouTube('https://youtu.be/8J8wWxbAdFg?si=aGU0zr4hrPFSL7zw')
print(yt.title)

p = Playlist('https://www.youtube.com/playlist?list=PLMS9Cy4Enq5KsM7GJ4LHnlBQKTQBV8kaR')
print(p.title)
print(len(p))

for video in p:
    print(video)
    yt = YouTube(video)
    print(yt.title)
    
'''


s = Search("CREER UN JEU PYGAME - PYTHON")

for resultat in s.results[:1]:
    # Vérifier si l'objet est une vidéo
    link = 'https://youtu.be/' + resultat.video_id
    
    print()
    print(resultat.title)
    print(resultat.author)
    print(link)
    print()
    
    yt = YouTube(link)
    yt = yt.streams.get_highest_resolution()
    yt.download()
       

    
   
    
    
