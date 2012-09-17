//
//  limitereffect.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 9/15/12.
//
//

#include "limitereffect.h"

LimiterEffect::LimiterEffect(AudioSource* inputSource, bool deleteInputWhenDeleted) : meanSquare(0), src(inputSource), deleteInputWhenDeleted(deleteInputWhenDeleted), n(0)
{
}
LimiterEffect::~LimiterEffect() {
}

void LimiterEffect::setParams(const Parameters& newSettings) {
    parms = newSettings;
}

const LimiterEffect::Parameters& LimiterEffect::getParams() const {
    return parms;
}

void LimiterEffect::prepareToPlay (int samplesPerBlockExpected, double sampleRate) {
    meanSquare = 0;
    src->prepareToPlay(samplesPerBlockExpected, sampleRate);
}
void LimiterEffect::releaseResources() {
    src->releaseResources();
}

void LimiterEffect::getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill) {
    src->getNextAudioBlock(bufferToFill);
    
    float **wav = bufferToFill.buffer->getArrayOfChannels();
    
    float threshold = parms.threshold * 0.01;          // threshold to unity (0...1)
    float slope = parms.slope * 0.01;              // slope to unity
    float tla = parms.lookAhead * 1e-3;                // lookahead time to seconds
    float decay = parms.rmsDecay;               // window time to seconds
    float tatt = parms.attack * 1e-3;               // attack time to seconds
    float trel = parms.release * 1e-3;               // release time to seconds
    float sr = parms.sampleRate;
    
    // attack and release "per sample decay"
    float att = (tatt == 0.0) ? (0.0) : exp (-1.0 / (sr * tatt));
    float rel = (trel == 0.0) ? (0.0) : exp (-1.0 / (sr * trel));
    
    // envelope
    float env = 0.0;
    
    // sample offset to lookahead wnd start
    int lhsmp = (int) (sr * tla);
    
    // for each sample...
    for (int i = 0; i < bufferToFill.numSamples; ++i) {
        
        for (int chan = 0; chan < NUM_OUTPUT_CHANNELS; chan++)
            buf.setSample(chan, n+i, wav[chan][i]);
        
        buf.sampleAdded();
        
        if (buf.size() < lhsmp) {
            for (int chan=0; chan < NUM_OUTPUT_CHANNELS; chan++) {
                wav[chan][i] = 0;
            }
        } else {
            int ix = n + i - lhsmp;
            
            float sum = 0;
            for (int chan = 0; chan < NUM_OUTPUT_CHANNELS; chan++) {
                sum += buf.getSample(chan, ix);
            }
            meanSquare = decay * 0.5 * sum + (1.0 - decay)*meanSquare;
            buf.sampleRead();
            
            float rms = sqrt(meanSquare);   // root-mean-square
            
            // dynamic selection: attack or release?
            float  theta = rms > env ? att : rel;
            
            // smoothing with capacitor, envelope extraction...
            // here be aware of pIV denormal numbers glitch
            env = (1.0 - theta) * rms + theta * env;
            
            // the very easy hard knee 1:N compressor
            double  gain = 1.0;
            if (env > threshold)
                gain = gain - (env - threshold) * slope;
            
            // result - two hard kneed compressed channels...
            for (int chan = 0; chan < NUM_OUTPUT_CHANNELS; chan++) {
                wav[chan][i] *= gain;
            }
        }
    }
    
    n += bufferToFill.numSamples;
}


void compress
(
 float*  wav_in,     // signal
 int     n,          // N samples
 double  threshold,  // threshold (percents)
 double  slope,      // slope angle (percents)
 int     sr,         // sample rate (smp/sec)
 double  tla,        // lookahead  (ms)
 double  twnd,       // window time (ms)
 double  tatt,       // attack time  (ms)
 double  trel        // release time (ms)
 )
{
    typedef float stereodata[2];
    stereodata*     wav = (stereodata*) wav_in; // our stereo signal
    threshold *= 0.01;          // threshold to unity (0...1)
    slope *= 0.01;              // slope to unity
    tla *= 1e-3;                // lookahead time to seconds
    twnd *= 1e-3;               // window time to seconds
    tatt *= 1e-3;               // attack time to seconds
    trel *= 1e-3;               // release time to seconds
    
    // attack and release "per sample decay"
    double  att = (tatt == 0.0) ? (0.0) : exp (-1.0 / (sr * tatt));
    double  rel = (trel == 0.0) ? (0.0) : exp (-1.0 / (sr * trel));
    
    // envelope
    double  env = 0.0;
    
    // sample offset to lookahead wnd start
    int     lhsmp = (int) (sr * tla);
    
    // samples count in lookahead window
    int     nrms = (int) (sr * twnd);
    
    // for each sample...
    for (int i = 0; i < n; ++i)
    {
        // now compute RMS
        double  summ = 0;
        
        // for each sample in window
        for (int j = 0; j < nrms; ++j)
        {
            int     lki = i + j + lhsmp;
            double  smp;
            
            // if we in bounds of signal?
            // if so, convert to mono
            if (lki < n)
                smp = 0.5 * wav[lki][0] + 0.5 * wav[lki][1];
            else
                smp = 0.0;      // if we out of bounds we just get zero in smp
            
            summ += smp * smp;  // square em..
        }
        
        double  rms = sqrt (summ / nrms);   // root-mean-square
        
        // dynamic selection: attack or release?
        double  theta = rms > env ? att : rel;
        
        // smoothing with capacitor, envelope extraction...
        // here be aware of pIV denormal numbers glitch
        env = (1.0 - theta) * rms + theta * env;
        
        // the very easy hard knee 1:N compressor
        double  gain = 1.0;
        if (env > threshold)
            gain = gain - (env - threshold) * slope;
        
        // result - two hard kneed compressed channels...
        float  leftchannel = wav[i][0] * gain;
        float  rightchannel = wav[i][1] * gain;
    }
}
