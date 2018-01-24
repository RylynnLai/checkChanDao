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
#import<CommonCrypto/CommonDigest.h>

static NSString *chandaoURL = @"http://172.17.21.16/zentao/bug-view-%@.html";
static NSString *loginURL = @"http://172.17.21.16/zentao/user-login.html";
static NSString *bugsURL = @"http://172.17.21.16/zentao/my-bug.html";

@interface Controller()
@property (nonatomic, strong) NSStatusItem *statusItem;//状态栏图标
@property (nonatomic, strong) NSPopover *popOverView;//弹窗

@property (nonatomic, strong, readwrite) NSArray <bugModel *>*bugs;
@end

@implementation Controller

+ (instancetype)startController
{
    Controller *c = [Controller new];
    [c setUp];
    return c;
}

- (void)setUp
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem.button setImage:[NSImage imageNamed:@"logo"]];
    self.statusItem.target = self;
    self.statusItem.action = @selector(popOverView:);
    
    self.popOverView = [NSPopover new];
    self.popOverView.behavior = NSPopoverBehaviorTransient;
    self.popOverView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    self.popOverView.contentViewController = [PopOverVC new];
    [self loadSavedCookies];
}

- (void)popOverView:(NSStatusBarButton *)btn
{
    [self.popOverView showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSRectEdgeMaxY];
}

- (void)loginWithAcount:(NSString *)acount andPwd:(NSString *)pwd completionHandler:(void (^)(bool isSucceed))completion{
    //NSURLSession在2013年随着iOS7的发布一起面世，苹果对它的定位是作为NSURLConnection的替代者
    //对url中的特殊字符编码，url编码？？
    loginURL = [loginURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginURL]];
    
    NSString *json = [NSString stringWithFormat:@"account=%@&password=%@", acount, [self md5:pwd]];
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"json data:%@",json);
    
    loginRequest.HTTPBody = jsonData;
    loginRequest.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"当前线程：%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length < 200) {//登录成功，Cookie自动保存
                    [self saveCookies];
                    [self checkChanDao];
                    !completion ? : completion(true);
                } else {
                    
                }
            });
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ? : completion(false);
            });
        }
    }];
    // 每一个任务默认都是挂起的，需要调用 resume 方法
    [task resume];
}

- (void)checkChanDao
{
    bugsURL = [bugsURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *bugsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:bugsURL]];
    
    bugsRequest.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:bugsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"当前线程：%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data.length < 200) {
                    NSLog(@"没有登录，或登录过期");
                    self.bugs = @[];
                } else {
                    self.bugs = [bugModel bugsModelWithHtmlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                }
            });
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
        }
    }];
    [task resume];
}

- (void)openChanDaoWithID:(NSString *)bugID
{
    NSString *url = [NSString stringWithFormat:chandaoURL, bugID];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}


- (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)saveCookies{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey:@"zentao.cookiesave"];
    [defaults synchronize];
}
//合适的时机加载持久化后Cookie 一般都是app刚刚启动的时候
- (void)loadSavedCookies{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:@"zentao.cookiesave"]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:[NSURL URLWithString:bugsURL] mainDocumentURL:nil];
    for (NSHTTPCookie *cookie in cookies){
        NSLog(@"cookie,name:= %@,valuie = %@",cookie.name,cookie.value);
    }
}

@end
