try:
    import librosa
    import soundfile as sf
    loaded=True
except ModuleNotFoundError:
    print('librosa and soundfile are not installed. using Pitch.exe instead.')
    loaded=False


from os import path
import os

import threading
import sys

cwd=os.getcwd()
#print(cwd)
if sys.platform.startswith('win'):
    import winsound
    def playsound(file):
        winsound.PlaySound(path.abspath(file), winsound.SND_FILENAME)
    def playsound_T(file):
        threading.Thread(winsound.PlaySound,args=(path.abspath(file), winsound.SND_FILENAME)).start()
else:
    def playsound(file):
        pass
    def playsound_T(file):
        pass


def changePitch1(filename,halfNotes=2):
    if not loaded:
        return changePitch3(filename,halfNotes)
    fn=os.path.basename(filename)
    #print(fn)
    y, sr = librosa.load(filename)
    b=librosa.effects.pitch_shift(y,sr= sr, n_steps=halfNotes)
    newFileName=os.path.join(cwd,f'{path.splitext(fn)[0]}Shifted_{halfNotes}.wav')
    #playsound(newFileName)
    if path.exists(newFileName):
        return newFileName
    sf.write(newFileName, b, sr)
    #librosa.output.write_wav(newFileName, b, sr)
   
    return newFileName
def changePitch2(filename,halfNotes=2):
    if not loaded:
        return changePitch3(filename,halfNotes)
    fn=os.path.basename(filename)
    print(fn)
    y, sr = librosa.load(filename)
    
    newFileName=os.path.join(cwd,f'{path.splitext(fn)[0]}Shifted_{halfNotes}.wav')
    if halfNotes>0:
        sf.write(newFileName, y, int(sr*(1+(halfNotes/24))))
    elif halfNotes==0:
        sf.write(newFileName, y, sr)
    else:
        sf.write(newFileName, y, int(sr*(1-(-halfNotes/24))))
    return newFileName
import subprocess
def changePitch3(filename,halfNotes=2):
    fn=os.path.basename(filename)
    newFileName=os.path.join(cwd,f'{path.splitext(fn)[0]}Shifted_{halfNotes}.wav')
    if path.exists(newFileName):
        return newFileName
    '''Pitch.exe [-h] -i <input file> -o <output file> -a halfnote(s)'''
    res=subprocess.call(['Pitch', '-i', filename, '-o', newFileName, '-a', str(halfNotes)])
    if res!=0:
        return changePitch1(filename,halfNotes)
    return newFileName


changePitch=changePitch3
