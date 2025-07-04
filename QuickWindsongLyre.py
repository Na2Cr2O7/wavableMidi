from tkinter import *
from tkinter.ttk import Combobox
import json
from tkinter import filedialog
from configparser import ConfigParser
import tkinter.messagebox as messagebox
import os

Translation=ConfigParser()
Translation.read('translation.ini',encoding='utf-8')
lang=Translation['Language']['language']
print(lang)
def getTranslation(key,prefix=True):
    if prefix:
        key='Untranslated'+key
    try:
        return Translation['Translation'][lang+key]
    except KeyError:
        return '[Untranslated]'+key
def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        data = json.load(file)
    return data
def print(*args):
    messagebox.showinfo(getTranslation('Title'),*args)

data = load_json('A.json')


wavName=list(data.values())[0]

trl=dict()
def comboBox_Selected(event, combobox, data):
    global wavName, trl
    selected_key = combobox.get()
    wavName=data[trl[selected_key]]
    print(wavName)

def create_combobox(root, data):
    global trl
    combobox = Combobox(root)
    combobox.config(width=30)
    v=list(data.keys())
    v2=[getTranslation(i,True) for i in v]
    trl=dict(zip(v2,v))
    combobox['values'] = v2
    combobox['state'] = 'readonly'  # 设置为只读，不允许用户输入其他值
    combobox.current(0)  # 默认选择第一个值
    combobox.bind('<<ComboboxSelected>>', lambda e, c=combobox, d=data: comboBox_Selected(e, c, d))
    combobox.pack(pady=20)
midInput=None
def select_midi_file():
    global midInput
    # 弹出文件选择对话框
    file_path = filedialog.askopenfilename(title=getTranslation('SelectMidiFile'), filetypes=[("MIDI files", "*.mid *.midi")])
    if file_path:
        print(f"{getTranslation('SelectedMidiFile')}{file_path}")
        midInput=file_path

midt=None
def export_audio():
    global midt,midInput
    # 弹出文件保存对话框
    file_path = filedialog.asksaveasfilename(title=getTranslation('ExportAudio'), defaultextension=".wav",
                                             filetypes=[("WAV files", "*.wav"), ("MP3 files", "*.mp3")])
    
    midiTrack=midt.get()
    if file_path:
        print(f'Python SeparateVoice.py -i "{midInput}" -w "{wavName}" -o "{file_path}" -t {midiTrack}')
        r=os.system(f'Python SeparateVoice.py -i "{midInput}" -w "{wavName}" -o "{file_path}" -t {midiTrack}' )
        if r==0:
            print(f"{getTranslation('ExportAudioSuccess')}{file_path}")
        else:
            print(f"{getTranslation('ExportAudioFailed')}")
    


def main():
    global midt
    root = Tk()
    root.title(getTranslation("Title"))
    root.geometry("400x400")

    

    Label(root, text=getTranslation("SelectSynth")).pack(pady=20)

    # 创建 Combobox
    create_combobox(root, data)


    # 创建按钮
    button = Button(root, text=getTranslation("SelectMidiFile"), command=select_midi_file)
    button.pack(pady=20)

    Label(root, text=getTranslation("SelectMidiTrack")).pack(pady=20)
    midt=Spinbox(root, from_=1, to=100)
    midt.pack(pady=20)

    export_button = Button(root, text=getTranslation("ExportAudio"), command=export_audio)
    export_button.pack(pady=20)
    root.mainloop()


if __name__ == "__main__":
    main()
