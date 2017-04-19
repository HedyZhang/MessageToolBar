//
//  YSMessageToolBar.h
//  YSMessageInputToolbar
//
//  Created by zhanghaidi on 15/11/20.
//  Copyright © 2015年 zhanghaidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSMessageTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;


@property (nonatomic, strong) UIColor *placeholderTextColor;

@end


/**
 *  YSMessageToolBar
 */

@protocol YSMessageToolBarDelegate;

@interface YSMessageToolBar : UIView

@property (nonatomic, weak) id<YSMessageToolBarDelegate> delegate;

@property (nonatomic, strong) UIButton *sendButton;

/**
 *  用于输入文本消息的输入框
 */
@property (strong, nonatomic) YSMessageTextView *inputTextView;

/**
 *  文字输入区域最大高度，必须 > KInputTextViewMinHeight(最小高度)并且 < KInputTextViewMaxHeight，否则设置无效
 */
@property (nonatomic) CGFloat maxTextInputViewHeight;

+ (CGFloat)defaultHeight;



@end

@protocol YSMessageToolBarDelegate <NSObject>

@optional

/**
 *  文字输入框开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(YSMessageTextView *)messageInputTextView;

/**
 *  文字输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(YSMessageTextView *)messageInputTextView;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;


@required
/**
 *  高度变到toHeight
 */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;

@end
