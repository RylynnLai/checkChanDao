//
//  Controller.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "Controller.h"
#import <AppKit/AppKit.h>
#import "PopOverVC.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSImage+ColorMask.h"

static NSString *chandaoURL = @"http://172.17.21.16/zentao/bug-view-%@.html";
static NSString *loginURL = @"http://172.17.21.16/zentao/user-login.html";
static NSString *bugsURL = @"http://172.17.21.16/zentao/my-bug.html";

@interface Controller()<NSUserNotificationCenterDelegate>
@property (nonatomic, strong) NSStatusItem *statusItem;//状态栏图标
@property (nonatomic, strong) NSPopover *popOverView;//弹窗

@property (nonatomic, strong, readwrite) ViewModel *viewModel;
@property (nonatomic, assign, readwrite) BOOL isResuesting;
@end

@implementation Controller

+ (instancetype)shareController{
    static dispatch_once_t pred;
    static Controller *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [Controller new];
    });
    return sharedInstance;
}

- (void)start
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem.button setImage:[NSImage imageNamed:@"logo"]];
    self.statusItem.target = self;
    self.statusItem.action = @selector(popOverView:);
    
    self.popOverView = [NSPopover new];
    self.popOverView.behavior = NSPopoverBehaviorTransient;
    self.popOverView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.popOverView.contentViewController = [PopOverVC new];
    
    self.viewModel = [ViewModel new];
    
    //添加一个全局的鼠标左键点击事件，关闭popoverview
    __weak typeof (self) weakself = self;
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown handler:^(NSEvent * _Nonnull event) {
        if (weakself.popOverView.isShown) {
            [weakself.popOverView close];
        }
    }];
    
    [self loadSavedCookies];
    
    [self.viewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(isLogin)) options:NSKeyValueObservingOptionNew context:nil];
    [self.viewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(hasNewBugs)) options:NSKeyValueObservingOptionNew context:nil];
    
    [self checkChanDao];
    [self startTimer];
}
//定时扫描禅道
- (void)startTimer
{
    [NSTimer scheduledTimerWithTimeInterval:300 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self checkChanDao];
    }];
}

- (void)popOverView:(NSStatusBarButton *)btn
{
    [self.popOverView showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSRectEdgeMaxY];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isLogin))]) {
        NSImage *logo = [NSImage imageNamed:@"logo"];
        if ([Controller shareController].viewModel.isLogin) {
            [self.statusItem.button setImage:logo];
        } else {
            NSColor *color = [NSColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9];
            [self.statusItem.button setImage:[logo ucsRenderingImageWithColor:color]];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(hasNewBugs))]) {
        if ([Controller shareController].viewModel.hasNewBugs) {
            [self sendNotice];
        }
    }
}

- (void)loginWithAcount:(NSString *)acount andPwd:(NSString *)pwd completionHandler:(void (^)(bool isSucceed))completion{
    //NSURLSession在2013年随着iOS7的发布一起面世，苹果对它的定位是作为NSURLConnection的替代者
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginURL]];
    
    NSString *json = [NSString stringWithFormat:@"account=%@&password=%@", acount, [self md5:pwd]];
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    loginRequest.HTTPBody = jsonData;
    loginRequest.HTTPMethod = @"POST";
    
    self.isResuesting = YES;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"当前线程：%@",[NSThread currentThread]);
        self.isResuesting = NO;
        if (data && (error == nil)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length < 200) {//登录成功，Cookie自动保存
                    [self saveCookies];
                    [self checkChanDao];
                    !completion ? : completion(true);
                } else {
                    [self.viewModel updateBugsWithHtmlString:nil];
                    !completion ? : completion(false);
                }
            });
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewModel updateBugsWithHtmlString:nil];
                !completion ? : completion(false);
            });
        }
    }];
    // 每一个任务默认都是挂起的，需要调用 resume 方法
    [task resume];
}

- (void)logout
{
    [self clearCookies];
}

- (void)checkChanDao
{
    bugsURL = [bugsURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *bugsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:bugsURL]];
    
    bugsRequest.HTTPMethod = @"GET";
    self.isResuesting = YES;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:bugsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"当前线程：%@",[NSThread currentThread]);
        self.isResuesting = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewModel updateBugsWithHtmlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        });
    }];
    [task resume];
}

- (void)openChanDaoWithID:(NSString *)bugID
{
    NSString *url = [NSString stringWithFormat:chandaoURL, bugID];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)sendNotice {
    NSUserNotification *localNotify = [[NSUserNotification alloc] init];
    
    localNotify.title = @"禅道";//标题
    localNotify.subtitle = @"你有新的bug";//副标题
    
    localNotify.informativeText = @"王八蛋王八蛋丰亚会";
    localNotify.soundName = NSUserNotificationDefaultSoundName;
    
    localNotify.contentImage = [NSImage imageNamed:@"empty"];//显示在弹窗右边的提示。
    
    //只有当用户设置为提示模式时，才会显示按钮.不设置的话，默认为yes
    localNotify.hasActionButton = YES;
    localNotify.actionButtonTitle = @"确定";
    localNotify.otherButtonTitle = @"取消";
    
    [localNotify setValue:@YES forKey:@"_showsButtons"]; //需要显示按钮
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:localNotify];
    //设置通知的代理
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

#pragma mark - md5编码
- (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

#pragma mark - 处理登录cookies
- (void)clearCookies
{
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"zentao.cookiesave"];
    [defaults synchronize];
}

- (void)saveCookies{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey:@"zentao.cookiesave"];
    [defaults synchronize];
}
//合适的时机加载持久化后Cookie 一般都是app刚刚启动的时候
- (void)loadSavedCookies{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"zentao.cookiesave"]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:[NSURL URLWithString:bugsURL] mainDocumentURL:nil];
}

#pragma mark - NSUserNotificationCenterDelegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    
}
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    //点击通知后，这个方法回调
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:bugsURL]];
}
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}
@end
