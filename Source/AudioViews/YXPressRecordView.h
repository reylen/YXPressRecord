//
//  YXPressRecordView.h
//  RecordDemo
//
//  Created by reylen on 16/8/10.
//  Copyright © 2016年 reylen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSpeechView.h"

@class YXPressRecordView;
@protocol YXPressRecordViewDelegate <NSObject>

- (void) pressRecordView:(YXPressRecordView *) pressRecordView didFinishRecordWithSpeech:(YXSpeechView *) speechView;

@end

@interface YXPressRecordView : UIButton

// 文件存储基本路径
@property (copy, nonatomic) NSString* recordStoreBasePath;
@property (assign, nonatomic) id<YXPressRecordViewDelegate>delegate;
// 录音的格式类型，默认采用 wav编码格式，可以设置为 MP4
@property (assign, nonatomic) YXRecordType recordType; // default WAV

- (instancetype)initWithFrame:(CGRect)frame
                   showInView:(UIView *) view
                 withBasePath:(NSString *) basePath;

@end

