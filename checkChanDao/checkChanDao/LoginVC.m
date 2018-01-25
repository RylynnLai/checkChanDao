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

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

- (IBAction)loginAction:(NSButton *)sender {
    [[Controller shareController] loginWithAcount:self.acountTF.stringValue andPwd:self.pwdTF.stringValue completionHandler:^(bool isSucceed) {
        if (isSucceed) {
            [self dismissViewController:self];
        }
    }];
}

@end
