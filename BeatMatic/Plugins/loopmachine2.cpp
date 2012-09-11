//
//  loopmachine2.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#include "loopmachine2.h"
#include "AudioEngineImpl.h"

LoopMachine::LoopMachine(AudioEngineImpl& engine) : audioEngine(engine), reserveIx(-1), commitIx(-1), drainIx(0), expectedBufferSize(0), wasPlaying(false) {
    for (int i = 0; i < MAX_NUM_GROUPS; i++) {
        userState[i] = LOOP_INACTIVE;
        audioState[i] = LOOP_INACTIVE;
    }
    std::memcpy(prevAudioState, audioState, sizeof(audioState));
}

void LoopMachine::init() {
    frameBuffer.buffer = new AudioSampleBuffer(2, 16384);
    frameBuffer.startSample = 0;
    frameBuffer.numSamples = 0;
}

void LoopMachine::setPreset(const char* const presetFilename) {
    std::cout << "MPD: CPP: LoopMachine::setPreset: setting looper preset to: " << presetFilename << std::endl;
    
    File presetFile(presetFilename);
    File presetDir = presetFile.getParentDirectory();
    var preset = JSON::parse(presetFile);
    
    std::cout << "MPD: CPP: LoopMachine::setPreset: preset json: " << preset.toString() << std::endl;
    
    auto& obj = *preset.getDynamicObject();
    
    std::cout << "MPD: CPP: LoopMachine::setPreset: preset name: " << obj.getProperty("preset").toString()
    << "; created by: " << obj.getProperty("preset").toString() << std::endl;
    
    var groups = obj.getProperty("groups");
    
    for (int i = 0; i < groups.size(); i++) {
        var group = groups[i];
        auto& obj = *group.getDynamicObject();
        String groupName = obj.getProperty("group");
        std::cout << "MPD: CPP: LoopMachine::setPreset: adding loops for " << groupName << std::endl;
        
        var loops = obj.getProperty("loops");
        for (int j = 0; j < loops.size(); j++) {
            File sample = presetDir.getChildFile(loops[j].toString());
            
            std::cout << "MPD: CPP: LoopMachine::setPreset: adding sample: "
            << sample.getFullPathName() << std::endl;
            
            addLoop(groupName, sample);
        }
    }
    
    prepareToPlay(expectedBufferSize, audioEngine.getSampleRate());
}

void LoopMachine::printState(String name, int state[]) {
    std::cout << "MPD: CPP: LoopMachine::printState:" << name << "=[";
    for (int i = 0; i < MAX_NUM_GROUPS; i++) {
        std::cout << state[i] << ", ";
    }
    std::cout << "]" << std::endl;
}

void LoopMachine::printRingBuffer() {
    std::cout << "MPD: CPP: LoopMachine::printRingBuffer:[";
    for (int i = drainIx; i <= commitIx.get(); i++) {
        std::cout << "[" << ringbuf[i][0] << ", " << ringbuf[i][1] << "], ";
    }
    std::cout << "]" << std::endl;
    
}

void LoopMachine::toggleLoop(int groupIx, int loopIx) {
    int oldLoopIx = userState[groupIx];
    if (loopIx == oldLoopIx) {
        // then we're muting the whole group, not switching.
        userState[groupIx] = LOOP_INACTIVE;
    } else {
        userState[groupIx] = loopIx;
    }
    
    printState("GUI thread, user", userState);
    
    // now we need to plop a message in the ring buffer
    int ix = ++reserveIx & RINGBUF_SIZE_M1; // == ++reserveIx % RINGBUF_SIZE
    ringbuf[ix][0] = groupIx;
    ringbuf[ix][1] = userState[groupIx];
    while (ix-1 != commitIx.get()) {
        std::cout << "MPD: CPP: LoopMachine::toggleLoop sleeping, ix=" << ix << ", commitIx:" << commitIx.get() << std::endl;
        Thread::sleep(20);
    }
    printRingBuffer();
    
    ++commitIx;
    
    std::cout << "MPD: CPP: LoopMachine::toggleLoop done processing." << std::endl;    
}

void LoopMachine::toggleLoop(String group, int loopIx) {
    int ix = groupIx(group);
    if (ix != NO_SUCH_GROUP)
        toggleLoop(ix, loopIx);
}

int LoopMachine::groupIx(String groupName) {
    if (groupNameToIx.contains(groupName))
        return groupNameToIx[groupName];
    else
        return NO_SUCH_GROUP;
}

void LoopMachine::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    if (expectedBufferSize == 0)
        expectedBufferSize = samplesPerBlockExpected;
    std::cout << "MPD: CPP: LoopMachine::prepareToPlay:samplesPerBlockExpected=" << samplesPerBlockExpected << ", sampleRate=" << sampleRate << std::endl;
    for (int i = 0; i < groupIxToAudioSource.size(); i++) {
        for (int j = 0; j < groupIxToAudioSource[i]->size(); j++) {
            std::cout << "MPD: CPP: LoopMachine::prepareToPlay:group " << i << ", sample " << j << std::endl;
            (*groupIxToAudioSource[i])[j]->prepareToPlay(samplesPerBlockExpected, sampleRate);
        }
    }
}

void LoopMachine::releaseResources() {
    for (int i = 0; i < groupIxToAudioSource.size(); i++) {
        for (int j = 0; j < groupIxToAudioSource[i]->size(); j++) {
            (*groupIxToAudioSource[i])[j]->releaseResources();
        }
    }
}

void LoopMachine::drainRingBuffer() {
//    std::cout << "MPD: CPP: LoopMachine:drainRingBuffer" << std::endl;
    
//    printRingBuffer();

    int limit = commitIx.get();
    while (drainIx <= limit) {
        int groupIx = ringbuf[drainIx][0];
        int loopIx = ringbuf[drainIx][1];

        audioState[groupIx] = loopIx;
        drainIx++;
    }
    
//    printState("curr", audioState);
//    printState("prev", prevAudioState);
}

void LoopMachine::processFadeIn(int groupIx, int loopIx, float frameStartTicks,
                 float frameEndTicks, float fadeStartTicks, float fadeEndTicks,
                 const AudioSourceChannelInfo& bufferToFill)
{
//   std::cout << "MPD: CPP: LoopMachine::processFadeIn: starting group " << groupIx << ", sample " << loopIx << std::endl;
   if (frameStartTicks < fadeStartTicks && frameEndTicks > fadeEndTicks) {
//       std::cout << "MPD: CPP: LoopMachine::processFadeIn: case 1" << std::endl;
        // this frame is large and completely contains the fadeout period.
        // in other words, start segment is normal, and then it fades out within this interval
        int offset = audioEngine.ticksToSamples(fadeStartTicks-frameStartTicks);

        // pre-f
        // NOP: we'd be outputting only zeros.
        
        // f
        float startGain = 0;
        float endGain = 1;
        int len = audioEngine.ticksToSamples(fadeEndTicks-fadeStartTicks);
        processFade(groupIx, loopIx, startGain, endGain, offset, len, bufferToFill);
        
        // post-f - audio is now at full volume!
        processBlock(groupIx, loopIx, offset+len, bufferToFill.numSamples-offset-len, bufferToFill);
        // MPD: done.
    } else if (frameEndTicks < fadeStartTicks) {
//        std::cout << "MPD: CPP: LoopMachine::processFadeIn: case 2" << std::endl;
        // this frame ends before the start of the fade period: there is no fade in this period.
        // this means we are in nop territory.
        // MPD: done.
    } else if (frameStartTicks < fadeStartTicks && frameEndTicks >= fadeStartTicks) {
//        std::cout << "MPD: CPP: LoopMachine::processFadeIn: case 3" << std::endl;
        // the fade period begins somewhere in this frame
        //  |-----|-----   |
        //  |     |     \  |
        //  |     |      \ |
        //  |     |       \|
        //  |     |        \
        //  |     |        |\
        //  |     |        | \___________
        //      f start   f end
        
        int offset = audioEngine.ticksToSamples(fadeStartTicks-frameStartTicks);
        
        float startGain = 0;
        float endGain = (frameEndTicks-fadeStartTicks)/(fadeEndTicks-fadeStartTicks);
        processFade(groupIx, loopIx, startGain, endGain, offset, bufferToFill.numSamples-offset, bufferToFill);
        // MPD: done.
    } else if (frameStartTicks > fadeStartTicks && frameEndTicks > fadeEndTicks) {
//        std::cout << "MPD: CPP: LoopMachine::processFadeIn: case 4" << std::endl;
        // the fade period (i.e. the next tick!) end occurs within this frame.
        //  |---------- |         |
        //  |          \|         |
        //  |           |\        |
        //  |           | \_______|____
        
        
        
        int numSamples = audioEngine.ticksToSamples(fadeEndTicks-frameStartTicks);
        float startGain = (frameStartTicks-fadeStartTicks)/(fadeEndTicks-fadeStartTicks);
        float endGain = 1;
        
        processFade(groupIx, loopIx, startGain, endGain, 0, numSamples, bufferToFill);
        
        // and after that we have to play the sample volle pulle
        processBlock(groupIx, loopIx, numSamples, bufferToFill.numSamples-numSamples, bufferToFill);
        // MPD: done.
    } else if (frameStartTicks > fadeStartTicks && frameEndTicks < fadeEndTicks) {
//        std::cout << "MPD: CPP: LoopMachine::processFadeIn: case 5" << std::endl;
        // this frame is very small compared to the fade time and is completely contained
        // within it.
        //  |---------- |  |
        //  |          \|  |
        //  |           \  |
        //  |           | \|
        //  |           |  \
        //  |           |  |\
        //  |           |  | \_______|____
        
        float startGain = (frameStartTicks-fadeStartTicks)/(fadeEndTicks-fadeStartTicks);
        float endGain = (frameEndTicks-fadeStartTicks)/(fadeEndTicks-fadeStartTicks);
        
        processFade(groupIx, loopIx, startGain, endGain, 0, bufferToFill.numSamples, bufferToFill);
    } else {
        throw AudioEngineException("This really should never happen.");
    }
}

void LoopMachine::processFadeOut(int groupIx, int loopIx, float frameStartTicks,
                                 float frameEndTicks, float fadeStartTicks, float fadeEndTicks,
                                 const AudioSourceChannelInfo& bufferToFill)
{
    // MPD: all done.
    if (frameStartTicks < fadeStartTicks && frameEndTicks > fadeEndTicks) {
        // this frame is large and completely contains the fadeout period.
        // in other words, start segment is normal, and then it fades out within this interval
        //  |----------             |
        //  |          \            |
        //  |           \___________|
        //    pre-f    f     post-f
        int numSamples = audioEngine.ticksToSamples(fadeStartTicks-frameStartTicks);
        
        // pre-f
        processBlock(groupIx, loopIx, 0, numSamples, bufferToFill);
        
        // f
        float startGain = 1;
        float endGain = 0;
        
        int len = audioEngine.ticksToSamples(fadeEndTicks-fadeStartTicks);
        processFade(groupIx, loopIx, startGain, endGain, numSamples, len, bufferToFill);
        
        // post-f
        // NOP: we'd be outputting only zeros.
    } else if (frameEndTicks < fadeStartTicks) {
        // this frame ends before the start of the fade period: there is no fade in this period.
        // this means we need to process the block as if it was full volume.
        processBlock(groupIx, loopIx, 0, bufferToFill.numSamples, bufferToFill);
    } else if (frameStartTicks < fadeStartTicks && frameEndTicks >= fadeStartTicks) {
        // the fade period begins somewhere in this frame
        // this frame is very small compared to the fade time and is completely contained
        // within it.
        //  |-----|-----   |
        //  |     |     \  |
        //  |     |      \ |
        //  |     |       \|
        //  |     |        \
        //  |     |        |\
        //  |     |        | \___________
        //      f start   f end
        
        int numSamples = audioEngine.ticksToSamples(fadeStartTicks-frameStartTicks);
        processBlock(groupIx, loopIx, 0, numSamples, bufferToFill);
        
        float startGain = 1;
        float endGain = (fadeEndTicks-frameEndTicks)/(fadeEndTicks-fadeStartTicks);
        processFade(groupIx, loopIx, startGain, endGain, numSamples, bufferToFill.numSamples-numSamples, bufferToFill);
    } else if (frameStartTicks > fadeStartTicks && frameEndTicks > fadeEndTicks) {
        // the fade period (i.e. the next tick!) end occurs within this frame.
        //  |---------- |         |
        //  |          \|         |
        //  |           |\        |
        //  |           | \_______|____
        
        
        
        int numSamples = audioEngine.ticksToSamples(fadeEndTicks-frameStartTicks);
        float startGain = (fadeEndTicks-frameStartTicks)/(fadeEndTicks-fadeStartTicks);
        float endGain = 0;
        
        processFade(groupIx, loopIx, startGain, endGain, 0, numSamples, bufferToFill);

        // and after that there's silence, so nothing more to do.
    } else if (frameStartTicks > fadeStartTicks && frameEndTicks < fadeEndTicks) {
        // this frame is very small compared to the fade time and is completely contained
        // within it.
        //  |---------- |  |
        //  |          \|  |
        //  |           \  |
        //  |           | \|
        //  |           |  \
        //  |           |  |\
        //  |           |  | \_______|____
        
        float startGain = (fadeEndTicks-frameStartTicks)/(fadeEndTicks-fadeStartTicks);
        float endGain = (fadeEndTicks-frameEndTicks)/(fadeEndTicks-fadeStartTicks);
        
        processFade(groupIx, loopIx, startGain, endGain, 0, bufferToFill.numSamples, bufferToFill);
    } else {
        throw AudioEngineException("This really should never happen.");
    }
}

void LoopMachine::processFade(int groupIx, int loopIx, float startGain, float endGain, int destOffset, int numSamples,
                              const AudioSourceChannelInfo& bufferToFill) {
    auto src = (*groupIxToAudioSource[groupIx])[loopIx];
    
    // we need to tell the audio format reader source how many samples we need fetching.
    frameBuffer.numSamples = numSamples;
    // now grab them, storing them into our temporary buffer.
    src->getNextAudioBlock(frameBuffer);
    
    // finally, we can add these to our main output buffer.
    for (int channel = 0; channel < NUM_OUTPUT_CHANNELS; channel++) {
        bufferToFill.buffer->addFromWithRamp(channel, destOffset, frameBuffer.buffer->getSampleData(channel),
                                             numSamples, startGain, endGain);
    }
}

void LoopMachine::processBlock(int groupIx, int loopIx, int destOffset, int numSamples,
                               const AudioSourceChannelInfo& bufferToFill) {
    auto src = (*groupIxToAudioSource[groupIx])[loopIx];
        
    // we need to tell the audio format reader source how many samples we need fetching.
    frameBuffer.numSamples = numSamples;
    // now grab them, storing them into our temporary buffer.
    src->getNextAudioBlock(frameBuffer);
    
    // finally, we can add these to our main output buffer.
    for (int channel = 0; channel < NUM_OUTPUT_CHANNELS; channel++) {
        bufferToFill.buffer->addFrom(channel, destOffset, *frameBuffer.buffer, channel, 0, numSamples);
    }
}

void LoopMachine::getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill) {
    bufferToFill.clearActiveBufferRegion();
    
    if (audioEngine.isPlaying()) {
        float frameStartTicks = audioEngine.getFrameStartTicks();
        float frameEndTicks = audioEngine.getFrameEndTicks();
        
        float nextTick = (float) ((int)frameStartTicks + 1);
        float fadeLengthTicks = audioEngine.millisToTicks(FADE_TIME_MS);
        
        float fadeStartTicks = nextTick - fadeLengthTicks;
        float fadeEndTicks = nextTick;
        
        if (frameStartTicks < fadeStartTicks && frameEndTicks >= fadeStartTicks)
            drainRingBuffer();
//        std::cout << "MPD: CPP: LoopMachine::getNextAudioBlock: reality check! " << ((int)nextTick/4) << std::endl;
        for (int groupIx = 0; groupIx < groupIxToAudioSource.size(); groupIx++) {
            
            int state = audioState[groupIx];
            int prevState = prevAudioState[groupIx];
            
            if (state == LOOP_INACTIVE && prevState == LOOP_INACTIVE) {
                // we were doing nothing last period, and we're still doing nothing: do nothing
            } else if (state == LOOP_INACTIVE && prevState != LOOP_INACTIVE) {
//                std::cout << "MPD: CPP: LoopMachine::getNextAudioBlock: muting group " << groupIx << std::endl;
                // for this loop group, we are fading out: going from an active loop to silence.
                processFadeOut(groupIx, prevState, frameStartTicks, frameEndTicks, fadeStartTicks, fadeEndTicks, bufferToFill);
            } else if (!wasPlaying || (state != LOOP_INACTIVE && prevState == LOOP_INACTIVE)) {
                int bar = (int) (fadeStartTicks/16.0);
                float barStartTicks = bar*16;
                
                float dTicks = fadeStartTicks - barStartTicks;
                int dSamples = audioEngine.ticksToSamples(dTicks);

                if (frameStartTicks == 0 || frameStartTicks <= fadeStartTicks) {
                    auto src = (*groupIxToAudioSource[groupIx])[state];
                    src->setNextReadPosition(dSamples % src->getTotalLength());
                }
//                std::cout << "MPD: CPP: LoopMachine::getNextAudioBlock: starting group " << groupIx << ", sample " << state << std::endl;
                // for this loop group, we are fading in: going from silence to signal.
                processFadeIn(groupIx, state, frameStartTicks, frameEndTicks, fadeStartTicks, fadeEndTicks, bufferToFill);
            } else if (prevState != state) {
//                std::cout << "MPD: CPP: LoopMachine::getNextAudioBlock: xfade " << groupIx << ", sample " << state << std::endl;
                // for this loop group, the loop being played has switched: do a crossfade
                processFadeOut(groupIx, prevState, frameStartTicks, frameEndTicks, fadeStartTicks, fadeEndTicks, bufferToFill);
                
                int bar = (int) (fadeStartTicks/16.0);
                float barStartTicks = bar*16;
                
                float dTicks = fadeStartTicks - barStartTicks;
                int dSamples = audioEngine.ticksToSamples(dTicks);
                
                if (frameStartTicks == 0 || frameStartTicks <= fadeStartTicks) {
                    auto src = (*groupIxToAudioSource[groupIx])[state];
                    src->setNextReadPosition(dSamples % src->getTotalLength());
                }
                
                processFadeIn(groupIx, state, frameStartTicks, frameEndTicks, fadeStartTicks, fadeEndTicks, bufferToFill);
            } else {
                // we're playing the same thing as in the last period.
//              std::cout << "MPD: CPP: LoopMachine::getNextAudioBlock: process block " << groupIx << ", sample " << state << std::endl;
                if (!wasPlaying) {
                    auto src = (*groupIxToAudioSource[groupIx])[state];
                    src->setNextReadPosition(0);
                }
               processBlock(groupIx, state, 0, bufferToFill.numSamples, bufferToFill);
            }
        }
        
        if (frameStartTicks < fadeEndTicks && frameEndTicks >= fadeEndTicks) {
            std::memcpy(prevAudioState, audioState, sizeof(audioState));
            wasPlaying = true;
        }
        
        bufferToFill.buffer->applyGain(0, 0, bufferToFill.numSamples, 0.5);
        bufferToFill.buffer->applyGain(1, 0, bufferToFill.numSamples, 0.5);
        
//        wasPlaying = true;
    }
    
    if (wasPlaying && !audioEngine.isPlaying())
        wasPlaying = false;
}

void LoopMachine::addLoop(String groupName, File loopFile) {
    int groupIx;
    if (!groupNameToIx.contains(groupName)) {
        groupIx = groupNameToIx.size();
        groupNameToIx.set(groupName, groupIx);
        groupIxToAudioSource.add(new Array<AudioFormatReaderSource*>());
    } else {
        groupIx = groupNameToIx[groupName];
    }
    
    auto& groupSources = *groupIxToAudioSource[groupIx];
    auto src = new AudioFormatReaderSource(wavFormat.createReaderFor(new FileInputStream(loopFile), true), true);
    src->setLooping(true);
    groupSources.add(src);
}





// Old code for getNextAudioBlock.
//int frameStartSamples = audioEngine.getFrameStartSamples();
//int frameEndSamples = audioEngine.getFrameEndSamples();
//float fadeLengthSamples = ((float)FADE_TIME_MS) / ((float)1000.0) * audioEngine.getSampleRate();
//int nextTickSamples = audioEngine.ticksToSamples(nextTick);
//        int fadeInStartSamples = nextTickSamples - fadeInLengthSamples;
//        if (fadeInStartSamples < frameStartSamples) {
//
//            int x = nextTickSamples - fadeInLengthSamples;
//            if (frameStartSamples <= x && frameEndSamples > x) {
//                // we're switching from a tick into another
//                int limit = commitIx.get();
//                while (drainIx < limit) {
//                    int groupIx = ringbuf[drainIx][0];
//                    int loopIx = ringbuf[drainIx][1];
//
//                    userState[groupIx] = loopIx;
//                    drainIx++;
//                }
//
//                std::memcpy(prevAudioState, audioState, sizeof(audioState));
//            }
//
//            int tick = (int) frameEndTicks;
//            int ntick = tick % 16;
//
//
//            for (int groupIx = 0; groupIx < MAX_NUM_GROUPS; groupIx++) {
//                int state = audioState[groupIx];
//                int prevState = prevAudioState[groupIx];
//                if (state == LOOP_INACTIVE && prevState == LOOP_INACTIVE) {
//                    // do nothing
//                } else if (state == LOOP_INACTIVE) {
//                    // we're going from something to silence fadeout
//                    frameBuffer.numSamples = bufferToFill.numSamples;
//                    auto src = groupIxToAudioSource[groupIx][prevState];
//                    src->getNextAudioBlock(frameBuffer);
//                    int numSamples = bufferToFill.numSamples;
//
//                    int offset;
//                    float startGain;
//                    float endGain;
//                    if (frameStartSamples < x) {
//                        offset = x - frameStartSamples;
//                        startGain = 1;
//                    } else {
//                        offset = 0;
//                        startGain = ((float)(nextTickSamples - frameStartSamples))/((float)fadeInSamples);
//                    }
//                    endGain = ((float)(nextTickSamples - frameEndSamples))/((float)fadeInSamples);
//
//                    for (int channel = 0; channel < 2; channel++) {
//                        bufferToFill.buffer->addFromWithRamp(channel, offset,
//                            frameBuffer.buffer->getSampleData(channel), numSamples-offset, startGain, endGain);
//                    }
//
//                    src->setNextReadPosition(0);
//                } else if (prevState == LOOP_INACTIVE) {
//                    // we're starting a loop, fade in!
//
//                    int readPos = 0;
//
//                    // we're going from silence to something fadein
//                    frameBuffer.numSamples = bufferToFill.numSamples;
//                    auto src = groupIxToAudioSource[groupIx][state];
//
//                    src->setNextReadPosition(readPos);
//                    src->getNextAudioBlock(frameBuffer);
//
//
//                    int offset;
//                    float startGain;
//                    float endGain;
//                    if (frameStartSamples < x) {
//                        offset = x - frameStartSamples;
//                        startGain = 1;
//                    } else {
//                        offset = 0;
//                        startGain = ((float)(nextTickSamples - frameStartSamples))/((float)fadeInSamples);
//                    }
//                    endGain = ((float)(nextTickSamples - frameEndSamples))/((float)fadeInSamples);
//
//                    for (int channel = 0; channel < 2; channel++) {
//                        bufferToFill.buffer->addFromWithRamp(channel, offset,
//                                                             frameBuffer.buffer->getSampleData(channel), numSamples-offset, startGain, endGain);
//                    }
//
//                    src->setNextReadPosition(0);
//                } else if (prevState != state) {
//                    // we're switching loops: crossfade.
//                 } else  {
//                    for (int channel = 0; channel < 2; channel++) {
//                        bufferToFill.buffer->addFromWithRamp(channel, offset,
//                                                             frameBuffer.buffer->getSampleData(channel), numSamples-offset, startGain, endGain);
//                    }
//                }
//            }
//        }

