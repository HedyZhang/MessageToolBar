//
//  YSMessageToolBar.m
//  YSMessageInputToolbar
//
//  Created by zhanghaidi on 15/11/20.
//  Copyright © 2015年 zhanghaidi. All rights reserved.
//

#import "YSMessageToolBar.h"

#pragma mark -  Class YSMessageTextView

@interface YSMessageTextView ()
{
    BOOL _shouldDrawPlaceholder;
}
@end

@implementation YSMessageTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        [self configure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}
- (void)configure
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    self.placeholderTextColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    _shouldDrawPlaceholder = NO;
}

- (void)textChanged:(NSNotification *)notification
{
    [self drawPlaceholder];
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    [self drawPlaceholder];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (![placeholder isEqualToString:_placeholder])
    {
        _placeholder = placeholder;
        [self drawPlaceholder];
    }
}


- (void)drawPlaceholder
{
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderTextColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder)
    {
        [self setNeedsDisplay];
    }
    return;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (_shouldDrawPlaceholder)
    {
        [_placeholderTextColor set];
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f)
                  withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName: _placeholderTextColor}];
    }
}
@end


#pragma mark -  Class YSMessageToolBar
#define kVerticalPadding 5 //toolBar 竖直方向控件
#define kHorizontalPadding 5
#define kInputTextViewMaxHeight 80
#define kInputTextViewMinHeight 35

@interface YSMessageToolBar()<UITextViewDelegate>
{
    CGFloat  _previousTextViewContentHeight;

}
@property (strong, nonatomic) UIImageView *backgroundImageView;


@end


@implementation YSMessageToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {

        [self setupConfig];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)setFrame:(CGRect)frame
//{
//    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight))
//    {
//        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
//    }
//    
//    [super setFrame:frame];
//}

- (void)setupConfig
{
    self.maxTextInputViewHeight = kInputTextViewMaxHeight;
    
    self.backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:self.backgroundImageView];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inputTextView = [[YSMessageTextView  alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupSubviews
{
    [_sendButton sizeToFit];
    _sendButton.enabled = NO;
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_sendButton addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kHorizontalPadding * 2 - CGRectGetWidth(_sendButton.bounds), kVerticalPadding, CGRectGetWidth(_sendButton.bounds), kInputTextViewMinHeight);
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.sendButton.frame) - 5 * kHorizontalPadding;
    // 初始化输入框

    self.inputTextView.frame = CGRectMake(kHorizontalPadding, kVerticalPadding, width, kInputTextViewMinHeight);
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _inputTextView.font = [UIFont systemFontOfSize:15];
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];

    [self addSubview:self.sendButton];
    [self addSubview:self.inputTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];

}
- (void)textChanged
{
    if (_inputTextView.text.length == 0) {
        _sendButton.enabled = NO;
    }
    else
    {
        _sendButton.enabled  = YES;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupSubviews];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

#pragma  mark - Setter

- (void)setMaxTextInputViewHeight:(CGFloat)maxTextInputViewHeight
{
    if (maxTextInputViewHeight > kInputTextViewMaxHeight) {
        maxTextInputViewHeight = kInputTextViewMaxHeight;
    }
    _maxTextInputViewHeight = maxTextInputViewHeight;
}

#pragma  mark - Getter
- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor orangeColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _backgroundImageView;
}

#pragma  mark - Keyboard

/**
 键盘显示通知
 */
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat deltaY = keyboardBounds.size.height;
    
    void (^animations)() = ^{
        self.transform = CGAffineTransformMakeTranslation(0, -deltaY);
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [_delegate didChangeFrameToHeight:deltaY];
        }
    };
    
    if (duration > 0) {
        NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
    } else {
        animations();
    }
}

/**
 键盘隐藏通知
 */

- (void)keyboardWillHidden:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyboardBounds.size.height;
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    void (^animations)() = ^{
        self.transform = CGAffineTransformIdentity;
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)])
        {
            [_delegate didChangeFrameToHeight:-deltaY];
        }
    };
    
    if (duration > 0) {
        NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
    } else {
        animations();
    }
}


/**
 键盘高度更新，界面适应，
 */
- (void)textViewDidChange:(UITextView *)textView{
    //kVerticalPadding * 2
    CGFloat deltaHeight = 0;
    CGFloat textViewContentHeight = [self getTextViewContentH:textView];
    textViewContentHeight = textViewContentHeight > kInputTextViewMaxHeight ? kInputTextViewMaxHeight : textViewContentHeight;
    if (textViewContentHeight == _previousTextViewContentHeight) {
        return;
    }
    deltaHeight = textViewContentHeight - _previousTextViewContentHeight;
    _previousTextViewContentHeight = textViewContentHeight;
    CGRect barFrame = self.frame;
    
    barFrame.origin.y -= deltaHeight;
    barFrame.size.height += deltaHeight;
    
    self.frame = barFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:deltaHeight];
    }
}


/**
 解决iOS7及以上的版本上，UITextView输入中文时，在输入多行后，光标有时会上下跳动，输入文字的时候内容有时会往上跳，光标都显示不出来
 */
- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect r = [textView caretRectForPosition:textView.selectedTextRange.end];
        CGFloat caretY =  MAX(r.origin.y - textView.frame.size.height + r.size.height + 8, 0);
        if (textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
            textView.contentOffset = CGPointMake(0, caretY);
        }
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView {
    CGFloat contentHeight = [textView sizeThatFits:textView.frame.size].height;
    return contentHeight;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        //点击键盘上的发送按钮
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.inputTextView.text = @"";
            [textView resignFirstResponder];
            [self textViewDidChange:textView];
        }
        return NO;
    }
    return YES;
}

- (void)sendClicked:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(didSendText:)]) {
        [_delegate didSendText:self.inputTextView.text];
          self.inputTextView.text = @"";
        [self.inputTextView resignFirstResponder];
        [self textViewDidChange:self.inputTextView];

    }
}

#pragma mark - public

/**
 *  停止编辑
 */
- (BOOL)endEditing:(BOOL)force {
    BOOL result = [super endEditing:force];
    
    return result;
}

#pragma mark - ToolBar Default Height

+ (CGFloat)defaultHeight {
    return kVerticalPadding * 2 + kInputTextViewMinHeight;
}

@end
