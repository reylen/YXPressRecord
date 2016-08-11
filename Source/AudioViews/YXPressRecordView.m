//
//  YXPressRecordView.m
//  RecordDemo
//
//  Created by reylen on 16/8/10.
//  Copyright © 2016年 reylen. All rights reserved.
//

#import "YXPressRecordView.h"
#import "UIColor+hexColor.h"

@interface YXPressRecordView ()<UIAlertViewDelegate>

@property (assign, nonatomic) UIView* recordingShowInView;
@property (strong, nonatomic) YXSpeechView* speechView;
@property (copy, nonatomic) NSString* filePath;

@end

@implementation YXPressRecordView

- (instancetype)initWithFrame:(CGRect)frame showInView:(UIView *) view withBasePath:(NSString *) basePath
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.recordingShowInView = view;
        self.recordStoreBasePath = basePath;
        self.recordType = YXRecordTypeWAV;
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_recordStoreBasePath]) {
            [fileManager createDirectoryAtPath:_recordStoreBasePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [self setBackgroundImage:[[UIImage imageNamed:@"resource.bundle/recordPress.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:22] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[[UIImage imageNamed:@"resource.bundle/recordNormal.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:22] forState:UIControlStateNormal];
        
        
        self.exclusiveTouch = YES;
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitle:@"按住说话" forState:UIControlStateNormal];
        [self setTitle:@"松开结束" forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor r_colorWithHex:0x19a7ff] forState:UIControlStateNormal];

        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        //按下
        [self addTarget:self action:@selector(speechButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        //里面放开
        [self addTarget:self action:@selector(speechButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        //外面放开
        [self addTarget:self action:@selector(speechButtonTouchUpOutside: forEvent:) forControlEvents:UIControlEventTouchUpOutside];
        //进入外面
        [self addTarget:self action:@selector(speechButtonTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
        
        //进入里面
        [self addTarget:self action:@selector(speechButtonTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        
        //事件取消
        [self addTarget:self action:@selector(speechButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        
        
        //外面拖动
        [self addTarget:self action:@selector(speechButtonTouchDragOutside: forEvent:) forControlEvents:UIControlEventTouchDragOutside];
        
        //---------------------------------------------------
    }
    return self;
}

#pragma mark - action

- (BOOL) isRecordPermission {
    
    __block BOOL result = YES;
    
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
            result = granted;
        }];
    }
    
    return  result;
}
- (IBAction)speechButtonTouchUpInside:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(pressRecordView:didFinishRecordWithSpeech:)]) {
        [_delegate pressRecordView:self didFinishRecordWithSpeech:_speechView];
    }
    
    [self removeSpeechView];
    
}
- (IBAction)speechButtonTouchDown:(id)sender
{
    
    NSString*ext = _recordType == YXRecordTypeWAV ? @"wav" :@"mp4";
    
    self.filePath = [[_recordStoreBasePath stringByAppendingPathComponent:[[NSDate new] description]] stringByAppendingPathExtension:ext];
    
    if (_filePath == nil) {
        return;
    }
    
    if (![self isRecordPermission]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"麦克风权限被禁，无法录音，请打开设置开启权限！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1003;
        [alert show];
        return;
    }
    
    self.speechView = [[YXSpeechView alloc] initWithRecorderPath:_filePath recordType:_recordType];
    self.speechView.center = CGPointMake(self.recordingShowInView.center.x, self.recordingShowInView.center.y - 120.0f);
    [self.recordingShowInView addSubview:self.speechView];
    [self.speechView start];
    
}
- (IBAction)speechButtonTouchUpOutside:(id)sender  forEvent:(UIEvent *)event
{
    if (self.speechView.recordState == YXRecordStateReadyCancel) {
        //取消发送
        [self removeAndDeleteSpeechView];
    }
    else
    {
        [self speechButtonTouchUpInside:nil];
    }
}

- (IBAction)speechButtonTouchDragExit:(id)sender
{
    self.speechView.recordState = YXRecordStateCancel;
}

- (IBAction)speechButtonTouchDragEnter:(id)sender
{
    self.speechView.recordState = YXRecordStateRecoding;
}

- (IBAction)speechButtonTouchCancel:(id)sender
{
    [self speechButtonTouchUpInside:nil];
}

- (IBAction)speechButtonTouchDragOutside:(id)sender  forEvent:(UIEvent *)event
{
    NSSet *touches = [event touchesForView:sender];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.speechView];
    if (CGRectContainsPoint(self.speechView.bounds, touchPoint)) {
        self.speechView.recordState = YXRecordStateReadyCancel;
    }
    else
    {
        self.speechView.recordState = YXRecordStateCancel;
    }
}

#pragma mark - remove
- (void)removeSpeechView
{
    if (_speechView) {
        _speechView.delegate = nil;
        [_speechView stop];
        [_speechView removeFromSuperview];
        _speechView = nil;
    }
}


- (void)removeAndDeleteSpeechView
{
    [[NSFileManager defaultManager] removeItemAtPath:_speechView.soundFilePath error:nil];
    [self removeSpeechView];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1003) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}
@end
