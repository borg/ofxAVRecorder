#include "ofMain.h"
#include "ofxAVRecorder.h"


class ofApp : public ofBaseApp{
    ofxAVRecorder *recorder;
    bool blackMagicIsSetup = false;
public:
    void setup()
    {
        ofSetVerticalSync(true);
        ofSetFrameRate(60);

        recorder = new ofxAVRecorder();
        recorder->listVideoDevices();
        recorder->listAudioDevices();
        
    }
    
    void update()
    {
        
       if(!blackMagicIsSetup && recorder->getAvailableVideoDevices().size()>1){
            //wait for the magic to happen
            blackMagicIsSetup = true;
            //press l to see your specific setup
            recorder->setActiveVideoDevice(1);//ultra studio
            recorder->setActiveVideoFormat(4);//1080p 8 bit
            recorder->setActiveVideoFramerate(3);//29.9
            
            recorder->setActiveAudioDevice(3);
            recorder->setActiveAudioFormat(3);//24bit 44100


            recorder->startSession();
       }
    }
    
    void draw()
    {
        
        ofSetColor(255);

        if(recorder->isRecording()){
            ofSetColor(255,0,0);
        }else{
            ofSetColor(0,255,0);
        }
        
        ofDrawRectangle(0, 0, ofGetWidth(), 10);
        
        ofSetWindowTitle(ofToString(ofGetFrameRate()));
    }
    
    void keyPressed(int key)
    {
        
        
        if(key ==' '){
        
            if(recorder->isRecording()){
                recorder->stopRecording();
            }else{
                string outputPath = "capture_"+ofGetTimestampString()+".mov";
                recorder->startRecording(outputPath);
            }
        }
        
        if(key == 'l'){
            recorder->listVideoDevices();
            recorder->listAudioDevices();
            
        }
    }
};

//========================================================================
int main( ){
    ofSetupOpenGL(1280,730,OF_WINDOW);
    ofRunApp(new ofApp());
}