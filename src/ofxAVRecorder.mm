// =============================================================================
//
// ofxAVRecorder.mm
// BlackMagic
//
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



#include "ofxAVRecorder.h"
//#import <QuartzCore/QuartzCore.h>

//------------------------------------------------------------------
ofxAVRecorder::ofxAVRecorder(){
    outputPath = "capture.mov";
    
    recorder = [[AVRecorderDocument alloc] init];

};


//------------------------------------------------------------------
ofxAVRecorder::~ofxAVRecorder(){

	stopRecording();
    if(recorder) {
        ofLog() << "Releaseing recorder";
        [[recorder session] stopRunning];
		recorder = 0;
    }

};


void ofxAVRecorder::showPreview(){
    if(previewView){
        [previewView setHidden:NO];
    }
};

void ofxAVRecorder::hidePreview(){
    if(previewView){
        [previewView setHidden:YES];
    }
};

//--------------------------------------------------------------
void ofxAVRecorder::startRecording(string _outputPath, int _videoDeviceIndex, int _videoFormatIndex,int _videoFpsIndex, int _audioDeviceIndex, int _audioFormatIndex, int _compressionPresetIndex){
    
    outputPath = _outputPath;
    
    if(_videoDeviceIndex>-1){
        videoDeviceIndex = _videoDeviceIndex;
    }
    if(_videoFormatIndex>-1){
        videoFormatIndex = _videoFormatIndex;
    }
    
    if(_videoFpsIndex>-1){
        videoFpsIndex = _videoFpsIndex;
    }
    
    if(_audioDeviceIndex>-1){
        audioDeviceIndex =_audioDeviceIndex;
    }
    
    if(_audioFormatIndex>-1){
        audioFormatIndex = _audioFormatIndex;
    }
    
    if(_compressionPresetIndex >-1){
        compressionPresetIndex = _compressionPresetIndex;
    }
    
    bRecording = true;
    startThread();
}


void ofxAVRecorder::stopRecording() {
    
    bRecording = false;
    bRecordAudio = false;
    [recorder setRecording:NO];
}


//--------------------------------------------------------------

vector<string> ofxAVRecorder::listVideoDevices() {
    [recorder refreshDevices];
    NSLog(@"______________Video devices______________");
    
    vector<string> list;
    for(AVCaptureDevice* device : [recorder videoDevices]){
        NSLog(@"%@",device.description);
        list.push_back((string) [device.description UTF8String]);
    }
    NSLog(@"_________________________________________");
    return list;
}



vector<string> ofxAVRecorder::listAudioDevices() {
    [recorder refreshDevices];
    vector<string> list;
    NSLog(@"______________Audio devices______________");
    for(AVCaptureDevice* device : [recorder audioDevices]){
        NSLog(@"%@",device.description);
        list.push_back((string) [device.description UTF8String]);
    }
    NSLog(@"_________________________________________");
    return list;
}

vector<AVCaptureDevice *> ofxAVRecorder::getAvailableVideoDevices(){
    vector<AVCaptureDevice *> list;
    for(int i=0;i<[recorder.videoDevices count];i++){
        list.push_back([recorder.videoDevices objectAtIndex:i]);
    }
    return list;
};

vector<AVCaptureDeviceFormat*> ofxAVRecorder::getActiveVideoFormats(){
    vector<AVCaptureDeviceFormat *> list;
    if(recorder.selectedVideoDevice){
        for(int i=0;i<[recorder.selectedVideoDevice.formats count];i++){
            list.push_back([recorder.selectedVideoDevice.formats objectAtIndex:i]);
        }
    }
    return list;
};

vector<AVFrameRateRange*> ofxAVRecorder::getActiveVideoFramerates(){
    vector<AVFrameRateRange *> list;
    if(recorder.selectedVideoDevice){
        if([[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] count]){
            for(int i=0;i<[[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] count];i++){
                list.push_back([[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges]objectAtIndex:i]);
            }
        }
    }
    return list;
};

vector<AVCaptureDevice*> ofxAVRecorder::getAvailableAudioDevices(){
    vector<AVCaptureDevice *> list;
    for(int i=0;i<[recorder.audioDevices count];i++){
        list.push_back([recorder.audioDevices objectAtIndex:i]);
    }
    return list;
};

vector<AVCaptureDeviceFormat*> ofxAVRecorder::getActiveAudioFormats(){
    vector<AVCaptureDeviceFormat *> list;
    if(recorder.selectedAudioDevice){
        for(int i=0;i<[recorder.selectedAudioDevice.formats count];i++){
            list.push_back([recorder.selectedAudioDevice.formats objectAtIndex:i]);
        }
    }
    return list;
};

/*
vector<NSString *const> ofxAVRecorder::getAvailableCompressionPresets(){
    vector<NSString *const>list;
    for(int i=0;i<[recorder.availableSessionPresets count];i++){
        list.push_back([recorder.availableSessionPresets objectAtIndex:i]);
    }
    return list;
};
*/


void ofxAVRecorder::setActiveVideoDevice(int i){
    if([recorder.videoDevices count]>i){
        videoDeviceIndex = i;
        [recorder setSelectedVideoDevice: [recorder.videoDevices objectAtIndex:videoDeviceIndex]];
    }else{
        videoDeviceIndex = 0;
    }
    
    [recorder setSelectedVideoDevice: [recorder.videoDevices objectAtIndex:videoDeviceIndex]];
}

int ofxAVRecorder::getActiveVideoDevice(){
    return videoDeviceIndex;
}




 void ofxAVRecorder::setActiveVideoFormat(int i){
    if([recorder.selectedVideoDevice.formats count]>i){
        videoFormatIndex = i;
        
    }else{
        videoFormatIndex = 0;
    }
    [recorder setVideoDeviceFormat:[recorder.selectedVideoDevice.formats objectAtIndex:videoFormatIndex]];
}
    
int ofxAVRecorder::getActiveVideoFormat(){
    return videoFormatIndex;
}


void ofxAVRecorder::setActiveVideoFramerate(int i){
    if([[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] count]>videoFpsIndex){
    videoFpsIndex = i;
    }else{
        videoFpsIndex = 0;
    }
    
    [recorder setFrameRateRange:[[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] objectAtIndex:videoFpsIndex]];
    
}

int ofxAVRecorder::getActiveVideoFramerate(){
    return videoFpsIndex;
}


void ofxAVRecorder::setActiveAudioDevice(int i){
    if([recorder.audioDevices count]>audioDeviceIndex){
        audioDeviceIndex = i;
    }else{
        audioDeviceIndex = 0;
    }
    [recorder setSelectedAudioDevice: [recorder.audioDevices objectAtIndex:audioDeviceIndex]];
}

int ofxAVRecorder::getActiveAudioDevice(){
    return audioDeviceIndex;
}


void ofxAVRecorder::setActiveAudioFormat(int i){
    if([recorder.selectedAudioDevice.formats count]>audioFormatIndex){
        audioFormatIndex = i;

    }else{
        audioFormatIndex = 0;
    }
    [recorder setAudioDeviceFormat:[recorder.selectedAudioDevice.formats objectAtIndex:audioFormatIndex]];
}

int ofxAVRecorder::getActiveAudioFormat(){
    return audioFormatIndex;
}




void ofxAVRecorder::startSession(){
    NSWindow * appWindow = (NSWindow *)ofGetCocoaWindow();
    previewView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, ofGetWidth(), ofGetHeight()-10)];


    AVCaptureVideoPreviewLayer * previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[recorder session]];

    previewLayer.frame = CGRectMake(0, 0, 1280, 720);
    //[previewLayer setBackgroundColor:CGColorCreateGenericRGB(0.756f,0.756f,0.1f, 0.5f)];

    [previewView setLayer:previewLayer];
    [previewView setWantsLayer:YES];

    [appWindow.contentView addSubview:previewView];


    [[recorder session] startRunning];
}

//--------------------------------------------------------------
void ofxAVRecorder::threadedFunction() {
    while( isThreadRunning() ){
    
        if(bRecording) {
            
            if(!bRecordInitialised) {
                
                ofLog() << "Beginning AVF recording";
                bRecordInitialised = true;
  
                //AUDIO
                if([recorder.audioDevices count]>audioDeviceIndex){
                    [recorder setSelectedAudioDevice: [recorder.audioDevices objectAtIndex:audioDeviceIndex]];
                }else{
                    [recorder setSelectedAudioDevice: [recorder.audioDevices objectAtIndex:0]];
                }
                
                if([recorder.selectedAudioDevice.formats count]>audioFormatIndex){
                    [recorder setAudioDeviceFormat:[recorder.selectedAudioDevice.formats objectAtIndex:audioFormatIndex]];
                }
                
                
                
                
                
                //VIDEO
                if([recorder.videoDevices count]>videoDeviceIndex){
                    [recorder setSelectedVideoDevice: [recorder.videoDevices objectAtIndex:videoDeviceIndex]];
                }else{
                    [recorder setSelectedVideoDevice: [recorder.videoDevices objectAtIndex:0]];
                }
                
                
                if([recorder.selectedVideoDevice.formats count]>videoFormatIndex){
                    [recorder setVideoDeviceFormat:[recorder.selectedVideoDevice.formats objectAtIndex:videoFormatIndex]];
                }
                
                if([[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] count]>videoFpsIndex){
                    [recorder setFrameRateRange:[[[[recorder selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] objectAtIndex:videoFpsIndex]];
                }
                
        
                [recorder setOutputPath:[[NSString alloc] initWithUTF8String:ofToDataPath(outputPath,true).c_str()]];
                
                [recorder setRecording:YES];
            }
        } else {
            
            if(bRecordInitialised) {
                ofLog() << "Stopping AVF recording";
                bRecordInitialised = false;
                
                [recorder setRecording:NO];
                
                stopThread();
            }
            
        }
    }
}
