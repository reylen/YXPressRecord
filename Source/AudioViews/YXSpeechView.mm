//
//  YXSpeechView.m
//
//  Created by jerry.local on 13-8-16.
//
//

#import "YXSpeechView.h"
#import <QuartzCore/QuartzCore.h>
#import "CALevelMeter.h"

@interface YXSpeechView ()
{
}

@property (nonatomic, retain) UIImageView *BGImageView;
@property (nonatomic, retain) UILabel *infoLabel;

@end;

@implementation YXSpeechView

@synthesize lvlMeter_in, soundPlayer,soundRecorder,soundFilePath,userInfo,soundFileURL,currentTimeLabel,delegate;


- (void)dealloc
{
    NSLog(@"speech view dealloc");
    [UIApplication sharedApplication].idleTimerDisabled = NO; //自动锁屏

}


- (void)initAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive: YES error: nil];
}

- (id)initWithPlayerPath:(NSString *)path recordType:(YXRecordType)rType
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        _recordType = rType;
        isRecord = NO;
        soundFilePath = [path copy];
        soundFileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath isDirectory:NO];
    }
    return self;
    
}


- (id)initWithRecorderPath:(NSString *)path recordType:(YXRecordType)rType
{
    self = [super initWithFrame:CGRectMake(0, 0, 160, 160.0f)];
    if (self) {
        
        _recordType = rType;
        isRecord = YES;
        soundFilePath = [path copy];
        soundFileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath isDirectory:NO];
        
        self.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.8];
        self.layer.cornerRadius = 15;
        
        UIImageView *BGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        BGImageView.contentMode = UIViewContentModeCenter;
        BGImageView.image = [UIImage imageNamed:@"resource.bundle/recordRetain.png"];
        BGImageView.center = self.center;
        BGImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.BGImageView = BGImageView;
        [self addSubview:BGImageView];
        
        lvlMeter_in = [[CALevelMeter alloc] initWithFrame:CGRectMake(63, 37, 34, 58) bgColor:nil];
        [lvlMeter_in setBackgroundColor:[UIColor clearColor]];
        [lvlMeter_in.layer setCornerRadius:17];
        lvlMeter_in.clipsToBounds = YES;
        [BGImageView addSubview:lvlMeter_in];
        
        
        currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake((BGImageView.bounds.size.width - 80) / 2, 6, 80, 20)];
        currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        currentTimeLabel.backgroundColor = [UIColor clearColor];
        currentTimeLabel.textColor = [UIColor whiteColor];
        [BGImageView addSubview:currentTimeLabel];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 136, 140, 20)];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.font = [UIFont systemFontOfSize:14];
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.layer.cornerRadius = 2;
        infoLabel.clipsToBounds = YES;
        infoLabel.text = @"上滑可取消发送";
        self.infoLabel = infoLabel;
        [BGImageView addSubview:infoLabel];
    }
    return self;
}

- (BOOL)isRecord
{
    return isRecord;
}


- (void)updateCurrentRecorderTime
{
    NSInteger minute = (NSInteger)soundRecorder.currentTime / 60;
    NSInteger second = (NSInteger)soundRecorder.currentTime % 60;
	currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second, nil];
}

- (BOOL)start
{
    [UIApplication sharedApplication].idleTimerDisabled = YES; //不自动锁屏
    
    isStarted = YES;
    [self initAudioSession];
    if (isRecord) {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord  error: nil];

        
        if (_recordType == YXRecordTypeMP4) {
            
            NSMutableDictionary *recordSettings =[[NSMutableDictionary alloc] init];
            
            [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
            [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
            [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
            [recordSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            [recordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
            [recordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
            
            self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL
                                                              settings: recordSettings
                                                                 error: nil];
            [soundRecorder prepareToRecord];
            [soundRecorder record];
            
        }
        else{
            
            NSMutableDictionary *recordSettings =[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                                  [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                                  [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                                  [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                                  nil];
            
            self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL
                                                              settings: recordSettings
                                                                 error: nil];
            //soundRecorder.delegate = self;
            BOOL preparedOK = [soundRecorder prepareToRecord];

            BOOL recordOK = [soundRecorder record];
            NSLog(@"ok:%i,%i",preparedOK,recordOK);
        }

        [lvlMeter_in setRecorder:soundRecorder];
        
        
        if (updateTimer){
            [updateTimer invalidate];
            updateTimer = nil;
        }
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCurrentRecorderTime) userInfo:nil repeats:YES];
        
    }
    
    else
    {
        //设置扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback  error: nil];
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        soundPlayer.delegate = self;
        [soundPlayer prepareToPlay];
        return [soundPlayer play];
    }
    
    return YES;
}


- (void)stop
{
    [UIApplication sharedApplication].idleTimerDisabled = NO; //自动锁屏
    
    if (!isStarted) {
        return;
    }
    isStarted = NO;
    if (isRecord) {
        if (updateTimer) {
            [updateTimer invalidate];
            updateTimer = nil;
        }
        [soundRecorder stop];
        [lvlMeter_in setRecorder:nil];
    }
    else {
        [soundPlayer stop];
    }
    
//    [[AVAudioSession sharedInstance] setActive: NO error: nil];

}

//设置录音状态
- (void)setRecordState:(YXRecordState)recordState
{
    if (_recordState != recordState) {
        _recordState = recordState;
        switch (recordState) {
            case YXRecordStateCancel:
                self.BGImageView.image = [UIImage imageNamed:@"resource.bundle/recordDelete.png"];
                self.infoLabel.backgroundColor = [UIColor clearColor];
                self.infoLabel.text = @"移动到此，取消发送";
                self.infoLabel.frame = CGRectMake(10, 5, 140, 20);
                lvlMeter_in.hidden = YES;
                currentTimeLabel.hidden = YES;
                break;
            case YXRecordStateReadyCancel:
                self.BGImageView.image = [UIImage imageNamed:@"resource.bundle/recordReadyDelete.png"];
                self.infoLabel.backgroundColor = [UIColor colorWithRed:168 / 255.0 green:0 blue:0 alpha:1];
                self.infoLabel.text = @"松开手指，取消发送";
                self.infoLabel.frame = CGRectMake(10, 5, 140, 20);
                lvlMeter_in.hidden = YES;
                currentTimeLabel.hidden = YES;
                break;
            case YXRecordStateRecoding:
                self.BGImageView.image = [UIImage imageNamed:@"resource.bundle/recordRetain.png"];
                self.infoLabel.backgroundColor = [UIColor clearColor];
                self.infoLabel.text = @"上滑可取消发送";
                self.infoLabel.frame = CGRectMake(10, 136, 140, 20);
                lvlMeter_in.hidden = NO;
                currentTimeLabel.hidden = NO;
                break;
            default:
                break;
        }
        
        //currentTimeLabel.textColor = [UIColor whiteColor];
    }
}


#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)_error {
    NSLog(@"error:%@",_error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechView:playerDecodeErrorDidOccur:)]) {
        [self.delegate speechView:self playerDecodeErrorDidOccur:_error];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewDidFinishPlayingSuccessfully:)]) {
        [self.delegate speechViewDidFinishPlayingSuccessfully:flag];
    }
}


@end
