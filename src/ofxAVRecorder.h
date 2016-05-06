// =============================================================================
//
// ofxAVRecorder.h
// BlackMagic
// An adaptation of https://developer.apple.com/library/mac/samplecode/AVRecorder/Introduction/Intro.html

// Tested with GoPro Hero4 + BlackMagic Ultrastudio Express + MacBook 2011
// Make sure to add AVFoundation.framework
// https://www.blackmagicdesign.com/support
// DesktopVideo_10.6.4.dmg
//

// Make sure GoPro dimensions and framerate are the same as in Black Magic Desktop video, only successful with 1080p @ 29.97 (although GoPro says 30)

// Created by Andreas Borg on 4/25/16
//
// Copyright (c) 2015-2016 Andreas Borg localprojects.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================



#ifndef _ofxAVRecorder
#define _ofxAVRecorder

#include "ofMain.h"

#import "AVRecorderDocument.h"


@class AVCaptureVideoPreviewLayer;
@class AVCaptureSession;
@class AVCaptureDeviceInput;
@class AVCaptureMovieFileOutput;
@class AVCaptureAudioPreviewOutput;
@class AVCaptureConnection;
@class AVCaptureDevice;
@class AVCaptureDeviceFormat;
@class AVFrameRateRange;

class ofxAVRecorder : public ofThread {
	
  public:
	
	ofxAVRecorder();
    ~ofxAVRecorder();
	
    
    

    void startRecording(string outputPath, int videoDeviceIndex = -1, int videoFormatIndex =-1,int videoFpsIndex = -1, int audioDeviceIndex = -1, int audioFormatIndex = -1, int compressionPresetIndex = -1);

    void stopRecording();
    
    NSView* previewView = 0;
    void showPreview();
    void hidePreview();
    
    vector<string> listVideoDevices();
    vector<string> listAudioDevices();
    
    void threadedFunction();

    bool isRecording() {
        return bRecording;
    }
    
    vector<AVCaptureDevice *> getAvailableVideoDevices();
    
    void setActiveVideoDevice(int i);
    int getActiveVideoDevice();
    
    vector<AVCaptureDeviceFormat*> getActiveVideoFormats();//for selected device
    
    void setActiveVideoFormat(int i);
    int getActiveVideoFormat();
    vector<AVFrameRateRange*> getActiveVideoFramerates();
    
    void setActiveVideoFramerate(int i);
    int getActiveVideoFramerate();
    
    vector<AVCaptureDevice*> getAvailableAudioDevices();
    void setActiveAudioDevice(int i);
    int getActiveAudioDevice();
    
    vector<AVCaptureDeviceFormat*> getActiveAudioFormats();//for selected device
    
    void setActiveAudioFormat(int i);
    int getActiveAudioFormat();
    
    //vector<NSString *const> getAvailableCompressionPresets();
    void startSession();
 
 private:
    
    AVRecorderDocument* recorder = 0;
    string outputPath = "capture.mov";

    
    int videoDeviceIndex=0;
    int videoFormatIndex = 0;
    int videoFpsIndex = 0;
    
    int audioDeviceIndex=0;
    int audioFormatIndex=0;
    
    int compressionPresetIndex = 0; //AVCaptureSessionPresetXXX
    
    bool bRecording = false;
    bool bRecordInitialised = false;
    bool bRecordAudio = false;
   
    
};

#endif
