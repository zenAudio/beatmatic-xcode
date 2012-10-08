//
//  recorder.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 12.09.12.
//
//

#include "recorder.h"
#include "AudioEngineImpl.h"
#include "objctrampoline.h"

AudioRecorder::AudioRecorder(AudioEngineImpl& engine) : backgroundThread ("Audio Recorder Thread"), sampleRate (0), activeWriter (0),
    callbackId(String::empty), audioEngine(engine)
{
    backgroundThread.startThread();
}

AudioRecorder::~AudioRecorder() {
    stop();
}

//==============================================================================
void AudioRecorder::startRecording(const File& file)
{
//    std::cout << "MPD: NATIVE: CPP: AudioRecorder::startRecording: attempt to record " << file.getFullPathName() << std::endl;
    stop();
    
    this->outputFile = file;
    
    if (sampleRate > 0)
    {
        // Create an OutputStream to write to our destination file...
        file.deleteFile();
        ScopedPointer<FileOutputStream> fileStream (file.createOutputStream());
        
        if (fileStream != 0)
        {
            // Now create a WAV writer object that writes to our output stream...
//            WavAudioFormat wavFormat;
			OggVorbisAudioFormat oggFormat;
            AudioFormatWriter* writer = oggFormat.createWriterFor (fileStream, sampleRate, 1, 16, StringPairArray(), 0);
            
            if (writer != 0)
            {
                fileStream.release(); // (passes responsibility for deleting the stream to the writer object that is now using it)
                
                // Now we'll create one of these helper objects which will act as a FIFO buffer, and will
                // write the data to disk on our background thread.
                threadedWriter = new AudioFormatWriter::ThreadedWriter (writer, backgroundThread, 32768);
                
                // And now, swap over our active writer pointer so that the audio callback will start using it..
                const ScopedLock sl (writerLock);
                activeWriter = threadedWriter;
//                    std::cout << "MPD: NATIVE: CPP: AudioRecorder::startRecording: record in progress: " << std::endl;
                
            } else {
                std::cout << "MPD: NATIVE: CPP: AudioRecorder::startRecording: record failed: null writer." << std::endl;
                
            }
        } else {
            std::cout << "MPD: NATIVE: CPP: AudioRecorder::startRecording: record failed: null file stream." << std::endl;
        }
    } else {
        std::cout << "MPD: NATIVE: CPP: AudioRecorder::startRecording: record failed: sample rate is 0." << std::endl;
    }
}

void AudioRecorder::stop()
{
    // First, clear this pointer to stop the audio callback from using our writer object..
    {
        const ScopedLock sl (writerLock);
        activeWriter = 0;
    }
    
    // Now we can delete the writer object. It's done in this order because the deletion could
    // take a little time while remaining data gets flushed to disk, so it's best to avoid blocking
    // the audio callback while this happens.
    threadedWriter = 0;
}

void AudioRecorder::stopRecording(juce::String callbackId) {
//    bool sendMsg = isRecording();
        
    stop();
    
    if (true) {
        const char* const cb = callbackId.toUTF8();
        const char* const json = outputFile.getFullPathName().toUTF8();
        std::cout << "MPD: NATIVE: CPP: AudioRecorder::stopRecording: sending to " << cb << ", json " << json <<std::endl;
        InvokePhoneGapCallback(audioEngine.getGuiFacade(), cb, json);
    }
}

bool AudioRecorder::isRecording() const
{
    return activeWriter != 0;
}

//==============================================================================
void AudioRecorder::audioDeviceAboutToStart (AudioIODevice* device)
{
    sampleRate = device->getCurrentSampleRate();
}

void AudioRecorder::audioDeviceStopped()
{
    sampleRate = 0;
}

void AudioRecorder::audioDeviceIOCallback (const float** inputChannelData, int /*numInputChannels*/,
                            float** outputChannelData, int numOutputChannels,
                            int numSamples)
{
    const ScopedLock sl (writerLock);
    
    if (activeWriter != 0)
        activeWriter->write (inputChannelData, numSamples);
    
    // We need to clear the output buffers, in case they're full of junk..
    for (int i = 0; i < numOutputChannels; ++i)
        if (outputChannelData[i] != 0)
            zeromem (outputChannelData[i], sizeof (float) * numSamples);
}
