from mido import MidiFile
import mido
def getBPM(mid):
    midf=MidiFile(mid)
    for track in midf.tracks:
        for msg in track:
            if msg.type=='set_tempo':
                return mido.tempo2bpm(msg.tempo)
    return 120 #默认值
def getNotesCount(mid):
    midf=MidiFile(mid)
    count=0
    for track in midf.tracks:
        for msg in track:
            if msg.type=='note_on' and msg.velocity!=0:
                count+=1
    return count
def getNotesStartTimes(midFile):
    # 打开 MIDI 文件
    mid = MidiFile(midFile)
    
    # 初始化时间
    absolute_time_in_seconds = 0.0
    
    tempo = mido.bpm2tempo(getBPM(midFile))
    
    track= mid.tracks[-1] # 取最后一个轨道
    for msg in track:
            # 更新绝对时间
            absolute_time_in_seconds += mido.tick2second(msg.time, mid.ticks_per_beat, tempo)
            
            # 如果消息是音符开启消息
            if msg.type == 'note_on' and msg.velocity != 0:
                # 记录音符的绝对开始时间和音符编号
                yield absolute_time_in_seconds, msg.note
            
            # 更新速度信息
            if msg.type == 'set_tempo':
                tempo = msg.tempo

def getNotesStartTimesAndVolumes(midFile,Tracks):
    '''
    yield absoluteTimeinSeconds, note, velocity
    '''

    # 打开 MIDI 文件
    mid = MidiFile(midFile)
    
    # 初始化时间
    absoluteTimeinSeconds = 0.0
    
    tempo = mido.bpm2tempo(getBPM(midFile))
    try:
        track = mid.tracks[Tracks] # 取指定轨道
    except IndexError:
        print("Warn: illegal track number")
        track = mid.tracks[-1] # 取最后一个轨道
    for msg in track:
        # 更新绝对时间
        absoluteTimeinSeconds += mido.tick2second(msg.time, mid.ticks_per_beat, tempo)
        
        # 如果消息是音符开启消息
        if msg.type == 'note_on':
            # 记录音符的绝对开始时间、音符编号和音量
            yield absoluteTimeinSeconds, msg.note, msg.velocity
        
        # 更新速度信息
        if msg.type == 'set_tempo':
            tempo = msg.tempo


if __name__ == '__main__':
    s=getNotesStartTimes('q.mid')
    c=getNotesCount('q.mid')
    print(c)
