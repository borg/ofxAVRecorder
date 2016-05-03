#include "ofMain.h"
#include "ofxAVRecorder.h"


class ofApp : public ofBaseApp{
    ofxAVRecorder *recorder;
    bool blackMagicIsSetup = false;
    
    
    //run the AVrecorder from Apple to see these options
    // https://developer.apple.com/library/mac/samplecode/AVRecorder/Introduction/Intro.html
    int videoSource = 0;
    int videoFormat = 0;
    int videoFrameRate = 0;
    
    int audioSource = 0;
    int audioFormat = 0;
    
    vector<string> videoDevices;
    vector<string> audioDevices;
    ofBuffer config;
public:
    void setup()
    {
        ofSetVerticalSync(true);
        ofSetFrameRate(60);

        recorder = new ofxAVRecorder();
       
        
        
        config = ofBufferFromFile("config.txt");
        
        
        if(config.size()){
            
            for(auto line: config.getLines()){
                cout << line << endl;
                vector<string>p = ofSplitString(line,"\t");
                if(p[0] == "videoSource"){
                    videoSource = ofToInt(p[1]);
                }else if(p[0] == "videoFormat"){
                    videoFormat = ofToInt(p[1]);
                }else if(p[0] == "videoFrameRate"){
                    videoFrameRate = ofToInt(p[1]);
                }else if(p[0] == "audioSource"){
                    audioSource = ofToInt(p[1]);
                }else if(p[0] == "audioFormat"){
                    audioFormat = ofToInt(p[1]);
                }
                
            }
        }else{
            stringstream settings;
            settings << "videoSource\t1\n";
            settings << "videoFormat\t4\n";
            settings << "videoFrameRate\t3\n";
            settings << "audioSource\t3\n";
            settings << "audioFormat\t3\n";
            config.append(settings.str());
            ofBufferToFile("config.txt", config);
        }
    }
    
    void update()
    {
        
       if(!blackMagicIsSetup && ofGetElapsedTimef()>2){
       
            videoDevices = recorder->listVideoDevices();
            audioDevices = recorder->listAudioDevices();
        
        
            //wait for the magic to happen
            blackMagicIsSetup = true;
            //press l to see your specific setup
            recorder->setActiveVideoDevice(videoSource);//ultra studio
            recorder->setActiveVideoFormat(videoFormat);//1080p 8 bit
            recorder->setActiveVideoFramerate(videoFrameRate);//29.9
            
            recorder->setActiveAudioDevice(audioSource);
            recorder->setActiveAudioFormat(audioFormat);//24bit 44100


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
        
        ofSetColor(0);
        stringstream ss;
        ss<<"VIDEO"<<endl;
        for(int i=0;i<videoDevices.size();i++){
            ss<<ofToString(i)<<" : "<<videoDevices[i]<<endl;
        }
        ss<<"\nAUDIO"<<endl;
        for(int i=0;i<audioDevices.size();i++){
            ss<<ofToString(i)<<" : "<<audioDevices[i]<<endl;
        }
        ss<<"\nSPACE starts/stops recording.\nSet devices in config.txt"<<endl;
        ofDrawBitmapString(ss.str(), 10, 30);
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
        
        //cout<<key<<endl;
        /*
        if(key >= 48 && key <=55){
        
            videoSource = key - 48;
            cout<<"videoSource "<<videoSource<<endl;
            blackMagicIsSetup = 0;
 
                   
        }*/
    }
};

//========================================================================
int main( ){
    ofSetupOpenGL(1280,730,OF_WINDOW);
    ofRunApp(new ofApp());
}