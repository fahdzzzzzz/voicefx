#import <AVFoundation/AVFoundation.h>

static AVAudioEngine *engine;
static AVAudioUnitTimePitch *pitch;
static AVAudioUnitDelay *echo;

// 0 = عادي, 1 = بنت, 2 = رجل, 3 = صدى
void VoiceFX_SetPreset(int preset) {
    pitch.pitch = 0;
    echo.wetDryMix = 0;
    switch (preset) {
        case 1: pitch.pitch = 700;  break;   // نبرة أعلى (بنت)
        case 2: pitch.pitch = -500; break;   // نبرة أخف (رجل)
        case 3:
            echo.delayTime = 0.35;
            echo.feedback = 45;
            echo.wetDryMix = 50;
            break;
    }
}

void VoiceFX_Start(void) {
    AVAudioSession *s = [AVAudioSession sharedInstance];
    [s setCategory:AVAudioSessionCategoryPlayAndRecord
              mode:AVAudioSessionModeDefault
           options:AVAudioSessionCategoryOptionDefaultToSpeaker |
                   AVAudioSessionCategoryOptionAllowBluetooth
             error:nil];
    [s setActive:YES error:nil];

    engine = [AVAudioEngine new];
    pitch  = [AVAudioUnitTimePitch new];
    echo   = [AVAudioUnitDelay new];

    [engine attachNode:pitch];
    [engine attachNode:echo];

    AVAudioFormat *fmt = [engine.inputNode outputFormatForBus:0];
    [engine connect:engine.inputNode to:pitch format:fmt];
    [engine connect:pitch to:echo format:fmt];
    [engine connect:echo to:engine.mainMixerNode format:fmt];

    VoiceFX_SetPreset(0);
    [engine startAndReturnError:nil];
}

void VoiceFX_Stop(void) {
    [engine stop];
}
