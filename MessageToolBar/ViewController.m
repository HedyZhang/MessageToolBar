//
//  ViewController.m
//  MessageToolBar
//
//  Created by zhanghaidi on 2017/4/19.
//  Copyright © 2017年 zhanghaidi. All rights reserved.
//

#import "ViewController.h"
#import "YSMessageToolBar.h"


@interface ViewController ()<YSMessageToolBarDelegate>

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) YSMessageToolBar *chatToolbar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    [self.view addSubview:self.chatToolbar];

}


- (void)didSendText:(NSString *)text {
    
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight {
    
}

#pragma mark - Getter

- (YSMessageToolBar *)chatToolbar {
    if (!_chatToolbar) {
        _chatToolbar = [[YSMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [YSMessageToolBar defaultHeight], self.view.frame.size.width, [YSMessageToolBar defaultHeight])];
        _chatToolbar.delegate = self;
        [_chatToolbar.sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _chatToolbar.inputTextView.placeholder = @"发送消息";
        _chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _chatToolbar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
