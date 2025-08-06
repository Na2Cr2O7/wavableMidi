#include"AudioFile.h"
#include <iostream>
#include <cstdio>
#include <stdexcept>
#include <vector>
#include <fstream>


// sample rate
const int SAMPLE_RATE = 44100;

// 定义一个结构体来保存WAV文件的信息，包括文件名、开始时间和音量
struct wavFile0
{
   char* fileName;
   float startTime;
   float volume   ;  
};


// 改变音量
void changeVolume(AudioFile<float>& audioFile, float volume)
{

    if(volume<0) throw std::invalid_argument("volume must be non-negative"); // 非负数
    if (volume > 1) volume /=127; // 0-1之间
    // change volume
    int numChannels = audioFile.getNumChannels(); // 声道数
    int numSamples = audioFile.getNumSamplesPerChannel(); // 采样数
    for(int i = 0; i < numChannels; i++)
    {
        for(int j = 0; j < numSamples; j++)
        {
            audioFile.samples[i][j] *= volume; // 改变音量
        }
    }
}

// 单独改变音量
inline float changeVolume(float sample,float volume)
{
        if(volume<0) throw std::invalid_argument("volume must be non-negative"); // 非负数
    if (volume > 1) volume /=127; // 0-1之间
    return sample*volume; // 改变音量
}
int main(int argc, char* argv[])
{

    system("chcp 65001");
    // if ((argc-1) % 3)
    // {
    //     std::printf("Usage: %s <wavfile> <starttime> <volume> ...\n", argv[0]);
    //     return 213478;
    // }

    //default output
    char* wavFileInput =(char*)"result.wav";
    if (argc<2) 
    {
        std::printf("Usage: %s <txt> -o <outputfile> \n", argv[0]);
        return 213478;
    }
    //get output file name
    for(int i = 1; i < argc; i++)
    {
        if(std::strcmp(argv[i-1],"-o")==0)
        {
            wavFileInput = argv[i];
        }
    }

    //read txt file
    char* txtFileInput =argv[1];
    std::ifstream file(txtFileInput);
    if (!file.good())
    {
        std::printf("Error: cannot open file %s\n", txtFileInput);
        return 213478;
    }
    std::printf("Reading %s\n", txtFileInput);


    //read file into ram
    std::vector<std::string> newArgv;
    char buf;
    char buf2[260]; //maybe it is enough.
    memset(buf2, 0, 260);
    int index = 0;
    while (file.get(buf))
    {
        if (buf == ' ')
        {
            std::string s(buf2);
            newArgv.push_back(s);
            memset(buf2, 0, 260);
            index = 0;

        }
        else
        {
            buf2[index] = buf;
            index++;
        }

    }
    // for(auto s : newArgv)
    // {
    //     std::cout << s << std::endl;
    // }


    int newArgc=newArgv.size()+1;
    int audioCount= (newArgc-1)/3;

    // create audioFiles array
    struct wavFile0* audioFiles = new wavFile0[audioCount];

    int audioIndex = 0;
    char* wavFile ;
    float startTime,volume;
    //fill audioFiles array
    for(int i = 0; i < newArgc; i += 3)
    {
        

        wavFile= (char*)newArgv[i].c_str();
        //std::printf("File: %s, Start Time: %s, Volume: %s\n", wavFile, (char*)newArgv[i+1].c_str(), (char*)newArgv[i+2].c_str());
        
        try{
           startTime  = std::stof((char*)newArgv[i+1].c_str());
            volume = std::stof((char*)newArgv[i+2].c_str());
        }
        catch(const std::exception& e)
        {
            std::printf("Error: %s\n", e.what());  
            continue;
        }
      

        audioFiles[audioIndex].fileName = wavFile;
        audioFiles[audioIndex].startTime = startTime;
        audioFiles[audioIndex].volume = volume;
        audioIndex++;
        


    }


    std::cout<<"audioCount: "<<audioCount<<std::endl;
    //AudioFile<float>::AudioBuffer buffer;
    int bufferSize = SAMPLE_RATE*100;


    // combine audio files into one audio file
    //float* buffer = new float[bufferSize];
    float * buffer[2] = {new float[bufferSize],new float[bufferSize]};
    memset(buffer[0], 0, bufferSize*sizeof(float));
    memset(buffer[1], 0, bufferSize*sizeof(float));
    // memset(buffer, 0, bufferSize*sizeof(float));
    // CWW::WAVData* wavData = CWW::audioread(audioFiles[0].fileName);
    // free(wavData->sample); //use its Header only

    for(int i = 0; i < audioCount; i++)
    {
        wavFile0 audioFile = audioFiles[i];
        printf("(%d)Loading %s\n",i ,audioFile.fileName);
        AudioFile<float> audio;
        audio.load(audioFile.fileName);

        int startSample = (int)(audioFile.startTime * SAMPLE_RATE);
        float volume = audioFile.volume;
        // std::cout << "startSample: " << startSample << std::endl;
        if (audio.isStereo())
        {
            std::printf("(%d)Stereo\n",i);
        }

        int channel = 0;
        int numSamples = audio.getNumSamplesPerChannel();
        int numChannels = audio.getNumChannels();
        int endSample = startSample + numSamples;
        
        while(bufferSize < endSample)
        {
            int oldBufferSize = bufferSize;
            bufferSize *= 2;
            float* newBuffer[2] = {new float[bufferSize],new float[bufferSize]};
            
            for(int j = 0; j < oldBufferSize; j++)
            {
             newBuffer[0][j]=buffer[0][j];
             newBuffer[1][j]=buffer[1][j];

            }
            std::printf("Resizing buffer from %d to %d\n", oldBufferSize, bufferSize);
            memset(newBuffer + oldBufferSize, 0, (bufferSize - oldBufferSize)*sizeof(float));
            
            delete[] buffer[0];
            delete[] buffer[1];
            buffer[0] = newBuffer[0];
            buffer[1] = newBuffer[1];
        
        }



        for(channel = 0; channel < numChannels; channel++)
        {
        for (int i = 0; i < numSamples ; i++)
        {
            double currentSample = audio.samples[channel][i];

            buffer[channel][startSample + i] += changeVolume(currentSample, volume);
        }
    }
    }
    //now resize buffer to the actual size
    for(int i = bufferSize-1; i >= 0; i--)
    {
        if(buffer[0][i]!= 0 || buffer[1][i]!= 0)
        {
            break;
        }
        bufferSize--;
    }
    std::printf("Final buffer size: %d\n", bufferSize);

    //save to file
    AudioFile<float>::AudioBuffer audioBuffer;
    
    int numSamples = bufferSize;
    int numChannels = 2;
    audioBuffer.resize(numChannels);
    for(int i = 0; i < numSamples; i++)
    {
        audioBuffer[0].push_back(buffer[0][i]);
        audioBuffer[1].push_back(buffer[1][i]);
    }
    AudioFile<float> Result;
    bool success = Result.setAudioBuffer(audioBuffer);
    if (success)
    {   
        Result.save(wavFileInput);
        std::printf("Saved to %s\n", wavFileInput);
    }


    // the OS will automatically free the memory when the program exits.
    delete[] audioFiles;
    delete[] buffer[0];
    delete[] buffer[1];
    
}