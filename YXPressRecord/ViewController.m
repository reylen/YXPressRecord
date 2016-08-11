//
//  ViewController.m
//
//  Created by reylen on 16/8/10.
//  Copyright © 2016年 reylen. All rights reserved.
//

#import "ViewController.h"
#import "YXPressRecordView.h"
#import "YXSpeechView.h"

@interface ViewController ()

@property (strong, nonatomic) YXPressRecordView* pressRecordView;

@property (copy, nonatomic) NSString* recordStorePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initUI {
    
    self.recordStorePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"record"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_recordStorePath]) {
        [fileManager createDirectoryAtPath:_recordStorePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.pressRecordView = [[YXPressRecordView alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(self.view.frame) - 100, self.view.frame.size.width - 135, 44) showInView:self.view withBasePath:_recordStorePath];
    [self.view addSubview:self.pressRecordView];
}

@end
