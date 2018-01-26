//
//  LoginVC.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "LoginVC.h"
#import "Controller.h"

@interface LoginVC ()
@property (weak) IBOutlet NSTextField *acountTF;
@property (weak) IBOutlet NSTextField *pwdTF;

@property (nonatomic, strong) NSProgressIndicator *indicator;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:self.indicator];
    
    [[Controller shareController] addObserver:self forKeyPath:NSStringFromSelector(@selector(isRequesting)) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [[Controller shareController] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isRequesting))];
}

- (IBAction)loginAction:(NSButton *)sender {
    [[Controller shareController] loginWithAcount:self.acountTF.stringValue andPwd:self.pwdTF.stringValue completionHandler:^(bool isSucceed) {
        if (isSucceed) {
            [self dismissViewController:self];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"登录失败";
            alert.informativeText = @"请检查账号或密码是否正确！";
            alert.icon = [NSImage imageNamed:@"empty"];
            
            [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:nil];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isRequesting))]) {
        self.indicator.hidden = ![Controller shareController].isRequesting;
    }
}

- (NSProgressIndicator *)indicator
{
    if (!_indicator) {
        _indicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.view.bounds.size.width / 2 - 10, 10, 20, 20)];
        [_indicator setStyle:NSProgressIndicatorStyleSpinning];
        [_indicator startAnimation:nil];
        _indicator.hidden = YES;
    }
    return _indicator;
}

@end
