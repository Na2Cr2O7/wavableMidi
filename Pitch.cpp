#include "AudioFile.h"
#include <iostream>
#include <cmath>
#include <cstring>
#include<string>
#define resampleAudio resampleAudioNearestNeighbor
float linearInterpolation(float x, float x0, float x1, float y0, float y1) {
    return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
}

// 音频重采样函数 - 改变音调
std::vector<float> resampleAudioLinear(std::vector<float>& audioData, float oldSampleRate, float newSampleRate) {
    // 采样率比
    float ratio = newSampleRate / oldSampleRate;
    
    // 新的音频数据长度
    int newLength = static_cast<int>(audioData.size() * ratio);
    
    // 创建并填充新的音频数据向量
    std::vector<float> newAudioData(newLength);
    
    // 使用线性插值进行重采样
    for (int i = 0; i < newLength; ++i) {
        float oldIndex = i / ratio;
        int lowerIndex = static_cast<int>(floor(oldIndex));
        float interpolationFactor = oldIndex - lowerIndex;
        
        // 线性插值计算新样本值
        newAudioData[i] = linearInterpolation(interpolationFactor, 0.0f, 1.0f,
                                             audioData[lowerIndex], audioData[lowerIndex + 1]);
    }
    
    return newAudioData;
}
std::vector<float> resampleAudioNearestNeighbor(std::vector<float>& audioData, float oldSampleRate, float newSampleRate) {
    // 采样率比
    float ratio = newSampleRate / oldSampleRate;
    
    // 新的音频数据长度
    int newLength = static_cast<int>(audioData.size() * ratio);
    
    // 创建并填充新的音频数据向量
    std::vector<float> newAudioData(newLength);
    
    // 使用最近邻插值进行重采样
    for (int i = 0; i < newLength; ++i) {
        float oldIndex = i / ratio;
        int nearestIndex = static_cast<int>(round(oldIndex));
        
        // 选择最近的样本值
        newAudioData[i] = audioData[nearestIndex];
    }
    
    return newAudioData;
}

float halfNotes(int count)
{
    return std::pow(2.0f, count / 12.0f);
}
int main(int argc, char** argv)
{
    char* inputFile = nullptr;
    char* outputfile = nullptr;
    int halfNote = 0;
    int i = 0;
    bool logToConsole = false;
    for(; i < argc; i++)
    {
        if(std::strcmp(argv[i], "-h") == 0)
        {
            info:
            std::printf("Change pitch of a wav file.\n");
            std::printf("-h: show help\n");
            std::printf("-i <input file>: input wav file\n");
            std::printf("-o <output file>: output wav file\n");
            std::printf("-a <halfnote(s)>: half note(s) to change pitch\n");
            std::printf("-L: log to console\n");
            std::printf("Usage: %s [-h] -i <input file> -o <output file> -a halfnote(s) -L \n", argv[0]);
            return 0;
        }
        else if(std::strcmp(argv[i], "-i") == 0)
        {
            inputFile = argv[i + 1];

        }
        else if(std::strcmp(argv[i], "-o") == 0)
        {
            outputfile = argv[i + 1];
        }
        else if(std::strcmp(argv[i], "-a") == 0)
        {
            halfNote = std::stoi(argv[i + 1]);
        }
        else if(std::strcmp(argv[i], "-L") == 0)
        {
            logToConsole = true;
        }
    }
    if (inputFile == nullptr || outputfile == nullptr || halfNote == 0)
    {
        goto info;
    }
    AudioFile<float> audioFile;
    audioFile.load(inputFile);
    if(logToConsole) audioFile.printSummary();
    // int sampleRate = audioFile.getSampleRate();
    // audioFile.setSampleRate(static_cast<int>(sampleRate * halfNotes(halfNote)));
    // audioFile.save(outputfile);

     int sampleRate = audioFile.getSampleRate();
     std::vector<float> audioData = audioFile.samples[0];
     int newSampleRate=static_cast<int>(sampleRate * halfNotes(halfNote));
     //std::cout << "new sample rate: " << newSampleRate << std::endl;
     
     std::vector<float> newAudioData = resampleAudio(audioData,  newSampleRate,sampleRate);

     audioFile.samples[0] = newAudioData;
    audioFile.save(outputfile);

    return 0;
}