//
//  YXSpeechView.h
//
//  Created by reylen on 13-9-11.
//  Copyright (c) 2013年 reylen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

typedef NS_ENUM(NSUInteger, YXRecordType) {
    YXRecordTypeMP4,
    YXRecordTypeWAV
};

typedef NS_ENUM(NSUInteger, YXRecordState) {
    YXRecordStateRecoding,
    YXRecordStateCancel,
    YXRecordStateReadyCancel
};


@class CALevelMeter;

@protocol ZUSpeechViewDelegate;


@interface YXSpeechView : UIView <AVAudioPlayerDelegate,AVAudioSessionDelegate,AVAudioRecorderDelegate>
{
    id<ZUSpeechViewDelegate> _delegate;
    
    //声波显示
    CALevelMeter	 *lvlMeter_in;
    //录音
    AVAudioRecorder *soundRecorder;
    //播放器
    AVAudioPlayer *soundPlayer;
    
    //路径URL
    NSURL *soundFileURL;
    
    //路径
    NSString *soundFilePath;
    
    //用户使用的信息
    NSString *userInfo;
    
    BOOL isRecord;
    BOOL isStarted;
    
    NSTimer	*updateTimer;
    
    UILabel *currentTimeLabel;
}

@property (nonatomic, assign)   id<ZUSpeechViewDelegate> delegate;

@property (nonatomic, retain)	CALevelMeter	*lvlMeter_in;

@property (nonatomic, retain)	UILabel	*currentTimeLabel;

@property (nonatomic, retain)   AVAudioRecorder *soundRecorder;
@property (nonatomic, retain)   AVAudioPlayer *soundPlayer;

@property (nonatomic, retain,readonly)   NSURL *soundFileURL;
@property (nonatomic, copy,readonly)   NSString *soundFilePath;
@property (nonatomic, assign)   YXRecordState recordState;


@property (nonatomic, copy,)   NSString *userInfo;

@property (assign, nonatomic,readonly) YXRecordType    recordType;


- (id)initWithPlayerPath:(NSString *)path recordType:(YXRecordType) rType;
- (id)initWithRecorderPath:(NSString *)path recordType:(YXRecordType) rType;

- (BOOL)isRecord;

- (BOOL)start;

- (void)stop;

@end


@protocol ZUSpeechViewDelegate <NSObject>

@optional

- (void)speechView:(YXSpeechView *)speechView playerDecodeErrorDidOccur:(NSError *)error;
- (void)speechViewDidFinishPlayingSuccessfully:(BOOL)flag;

@end
