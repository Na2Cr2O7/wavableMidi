import argparse
pa = argparse.ArgumentParser('quickwindsonglyre')

# 英文: input midi file
# 中文: 输入的 MIDI 文件路径
pa.add_argument('-i','--input', help='input midi file | 输入的 MIDI 文件路径', required=True)

# 英文: wav file to be used as reference
# 中文: 作为参考使用的 WAV 文件（用于音色或采样）
pa.add_argument('-w','--wavfile', help='wav file to be used as reference | 作为参考使用的 WAV 文件（用于音色或采样）', required=True)

# 英文: output directory
# 中文: 输出文件的保存目录
pa.add_argument('-o','--output', help='output directory | 输出文件的保存目录', required=True)

# 英文: the track number of the midi file to be used(-1 means the last track)
# 中文: 要使用的 MIDI 文件中的轨道编号（-1 表示最后一轨）
pa.add_argument('-t','--midiTrack', 
                help='the track number of the midi file to be used (-1 means the last track) | 要使用的 MIDI 文件中的轨道编号（-1 表示最后一轨）', 
                default=-1, 
                type=int)

# 英文: sample rate to be used for output
# 中文: 输出音频所使用的采样率
pa.add_argument('-s','--sampleRate', 
                help='sample rate to be used for output | 输出音频所使用的采样率', 
                default=44100, 
                type=int)

# 英文: the base note to be used for the output(60 -> C4)
# 中文: 输出音频所使用的基准音符（60 对应中央 C，即 C4）
pa.add_argument('-B','--baseNote', 
                help='the base note to be used for the output (60 -> C4) | 输出音频所使用的基准音符（60 对应中央 C，即 C4）', 
                default=60, 
                type=int)

# 英文: disable cache
# 中文: 禁用缓存缓存到RAM
pa.add_argument('-N','--NoCache', 
                help='disable cache | 禁用缓存缓存到RAM', 
                action='store_true', 
                default=False)

# 英文: another way to process the audio(-N will be enabled while -s will be 44100 forever)
# 中文: 使用另一种音频处理方式（启用此选项会自动禁用缓存，并固定采样率为 44100）
pa.add_argument('-C','--anotherway', 
                help='another way(wavCompositor) to process the audio (-N will be enabled while -s will be 44100 forever) | 使用另一种音频处理方式(wavCompositor)（启用此选项会自动禁用缓存，并固定采样率为 44100）', 
                action='store_true', 
                default=False)
if __name__ == '__main__':
    args=pa.parse_args()

import shutil
import os
import midiNotes
import tqdm
from VoiceSwift import changePitch
from colorama import Fore, Back, Style
import subprocess


try:
    # moviepy > 2.0.0
    from moviepy import *
except ImportError:
    
    from moviepy.editor import * # type: ignore






garbageList=[]

def cleanGarbage():
    print(Fore.CYAN,'Cleaning.')
    for file in tqdm.tqdm(garbageList):
        try:
            os.remove(file)
        except:
            pass
    print(Fore.RESET)



def fileNameLegalty(fileName:str):
    legalFileExt=['wav','mp3','ogg','flac']
    for ext in legalFileExt:
        if fileName.endswith(ext):
            return fileName
    return fileName+'.wav'
loadedFileList={}
def loadFile(fileName:str,f,NoCache=False):
    if not NoCache:
        return f(fileName)
    if fileName in loadedFileList:
        return loadedFileList[fileName]
    else:
        return f(fileName)
def separateVoice(midiFile:str,wavFile:str,outputFileName:str,sampleRate:int=44100,midiTrack=-1,baseNote=60,NoCache=False,way=0):
    wavFile=fileNameLegalty(wavFile)
    wavFile=os.path.abspath(wavFile)
    outputFileName=fileNameLegalty(outputFileName)

    NotesStartTimesAndVolumes=midiNotes.getNotesStartTimesAndVolumes(midiFile,midiTrack)
    notesCount=midiNotes.getNotesCount(midiFile)
    audioList=[]
    bar=tqdm.tqdm(total=notesCount,desc='',unit='notes')
    o=''
    for i in NotesStartTimesAndVolumes:
        bar.update(1)
        startTimeinSeconds, note, velocity=i

        noteDelta=note-baseNote
        if noteDelta !=0:
            try:
                pitchChangedFileName=changePitch(wavFile,noteDelta)
                garbageList.append(pitchChangedFileName)
            except Exception as e:
                print(Fore.RED,f'Error while changing pitch: {e}{Fore.RESET}')
                pitchChangedFileName=wavFile
        else:
            pitchChangedFileName=wavFile
        
        #AudioFileClip(pitchChangedFileName)
        
        if way==1:
            o+=f'{pitchChangedFileName} {startTimeinSeconds} {velocity} '
        else:

            afc=loadFile(pitchChangedFileName,AudioFileClip,NoCache).with_start(startTimeinSeconds).with_volume_scaled(velocity/127)
            audioList.append(afc)
    if way==1:
        with open('f.txt','w',encoding='utf-8') as f:
            f.write(o)
#Usage: wavCompositor.exe <txt> -o <outputfile>
        r=subprocess.call(f'wavCompositor.exe f.txt -o {outputFileName}',shell=True)
        if r!=0:
            print(Fore.RED,f'Error while running wavCompositor.exe (Maybe you sholdn\'t use -C option){Fore.RESET}')
    elif way==2:
    
        result=CompositeAudioClip(audioList)
        result.fps=sampleRate
        result.write_audiofile(outputFileName)
        
if __name__ == '__main__':
    if not args.NoCache and not args.anotherway:
        print(Fore.CYAN,'Caching into RAM.')
    if args.anotherway:
        print(Fore.GREEN,'Using wavCompositor program')
    separateVoice(args.input,args.wavfile,args.output,args.sampleRate,args.midiTrack,args.baseNote,args.NoCache,args.anotherway)
    cleanGarbage()
    print(Fore.RESET)

        