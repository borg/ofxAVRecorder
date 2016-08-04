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
#import "AVRecorderDocument.h"

ofEvent <AVRecorderEvent> ofxAVRecorder::RECORDING_BEGAN;
ofEvent <AVRecorderEvent> ofxAVRecorder::RECORDING_FINISHED;
ofEvent <AVRecorderEvent> ofxAVRecorder::RECORDING_ERROR;

@interface AVRecorderDelegate () <AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate>
{

};

@end

@implementation AVRecorderDelegate
@synthesize outputPath;

#pragma mark - Delegate methods

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"AVRecorderDelegate Did start recording to %@", [fileURL description]);
    
    AVRecorderEvent e;
    e.error = (string) [fileURL.description UTF8String];
    ofNotifyEvent(ofxAVRecorder::RECORDING_BEGAN,e);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"AVRecorderDelegate Did pause recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"AVRecorderDelegate Did resume recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections dueToError:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		//[self presentError:error];
        AVRecorderEvent e;
        e.error = (string) [error.description UTF8String];
        ofNotifyEvent(ofxAVRecorder::RECORDING_ERROR,e);
	});
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)recordError
{
	if (recordError != nil && [[[recordError userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey] boolValue] == NO) {
		[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			//[self presentError:recordError];
            AVRecorderEvent e;
            e.error = (string) [recordError.description UTF8String];
            ofNotifyEvent(ofxAVRecorder::RECORDING_ERROR,e);
            
		});
	} else {
    
        if(outputPath){
            NSURL *output = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSError *error = nil;
            
            [[NSFileManager defaultManager] moveItemAtURL:outputFileURL toURL:output error:&error];
            NSLog(@"AVRecorderDelegate Did finish moving recording %@ to %@ ",outputFileURL, output);
            
            
            AVRecorderEvent e;
            if(error){
                NSLog(@"%@",error.description);
                e.error = (string) [error.description UTF8String];
                ofNotifyEvent(ofxAVRecorder::RECORDING_ERROR,e);
            }else{
                e.videoPath = (string) [outputPath UTF8String];
                ofNotifyEvent(ofxAVRecorder::RECORDING_FINISHED,e);
            }
        }
    }
}

- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(AVCaptureOutput *)captureOutput
{
    // We don't require frame accurate start when we start a recording. If we answer YES, the capture output
    // applies outputSettings immediately when the session starts previewing, resulting in higher CPU usage
    // and shorter battery life.
    return NO;
}



- (void)presentError:(NSError *)error modalForWindow:(NSWindow *)window delegate:(nullable id)delegate didPresentSelector:(nullable SEL)didPresentSelector contextInfo:(nullable void *)contextInfo{
    NSLog(@"presentError 1: %@",contextInfo);

};


- (BOOL)presentError:(NSError *)error{
    NSLog(@"presentError: %@",error.description);
};


- (NSError *)willPresentError:(NSError *)error{
 NSLog(@"willPresentError: %@",error.description);
};

@end

//#import <QuartzCore/QuartzCore.h>

//------------------------------------------------------------------
ofxAVRecorder::ofxAVRecorder(){
    outputPath = "capture.mov";
    
    recorder = [[AVRecorderDocument alloc] init];
    
    delegate = [[AVRecorderDelegate alloc] init];
    recorder.delegate = delegate;
};


//------------------------------------------------------------------
ofxAVRecorder::~ofxAVRecorder(){
    stopThread();
	//stopRecording();
    if(recorder) {
        ofLog() << "Releasing recorder";
        [[recorder session] stopRunning];
        
        //Not ARC currently...todo?
        [recorder release];
		recorder = 0;
        [delegate release];
        delegate = 0;
    }

};



void ofxAVRecorder::startSession(){
   /*
    
      NSWindow * appWindow = (NSWindow *)ofGetCocoaWindow();
    CGRect cg = CGRectMake(0, 0, ofGetWidth(), ofGetHeight());
    previewView = [[NSView alloc] initWithFrame:NSRectFromCGRect(cg)];


    AVCaptureVideoPreviewLayer * previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[recorder session]];

    previewLayer.frame = CGRectMake(0, 0, 1280, 720);
    //[previewLayer setBackgroundColor:CGColorCreateGenericRGB(0.756f,0.756f,0.1f, 0.5f)];

    [previewView setLayer:previewLayer];
    [previewView setWantsLayer:YES];

    [appWindow.contentView addSubview:previewView];
*/
    if(recorder){
        NSLog(@"ofxAVRecorder::startSession");
        [[recorder session] startRunning];
    }else{
        NSLog(@"No recorder");
    }
}


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
    
    delegate.outputPath = [[NSString alloc] initWithUTF8String:ofToDataPath(outputPath,true).c_str()];
    startThread();
}


void ofxAVRecorder::stopRecording() {
    
    bRecording = false;
    bRecordAudio = false;
    [recorder setRecording:NO];
    stopThread();
    
     ofLog() << "Stopping AVF recording & thread"<<endl;
}


//--------------------------------------------------------------

vector<string> ofxAVRecorder::listVideoDevices() {
    [recorder refreshDevices];
    NSLog(@"______________Video devices______________");
    
    vector<string> list;
    for(AVCaptureDevice* device : [recorder videoDevices]){
        NSLog(@"%@",device.localizedName);
        list.push_back((string) [device.localizedName UTF8String]);
    }
    NSLog(@"_________________________________________");
    return list;
}



vector<string> ofxAVRecorder::listAudioDevices() {
    [recorder refreshDevices];
    vector<string> list;
    NSLog(@"______________Audio devices______________");
    for(AVCaptureDevice* device : [recorder audioDevices]){
        NSLog(@"%@",device.localizedName);
        list.push_back((string) [device.localizedName UTF8String]);
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
        ofLogError()<<"Missing video device"<<endl;
        return;
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
        ofLogError()<<"Missing video format"<<endl;
        return;
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
        ofLogError()<<"Missing video framerate"<<endl;
        return;
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
        ofLogError()<<"Missing audio device"<<endl;
        return;
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
        ofLogError()<<"Missing audio format"<<endl;
        return;
    }
    [recorder setAudioDeviceFormat:[recorder.selectedAudioDevice.formats objectAtIndex:audioFormatIndex]];
}

int ofxAVRecorder::getActiveAudioFormat(){
    return audioFormatIndex;
}


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
            /*
            if(bRecordInitialised) {
                ofLog() << "Stopping AVF recording";
                bRecordInitialised = false;
                
                [recorder setRecording:NO];
                
                stopThread();
            }*/
            stopThread();
        }
    }
}
