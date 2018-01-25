//
//  ViewModel.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/25.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "ViewModel.h"
@interface ViewModel()

@property (nonatomic, assign, readwrite) BOOL hasNewBugs;

@property (nonatomic, assign, readwrite) BOOL isLogin;

@property (nonatomic, copy, readwrite) NSString *user;

@property (nonatomic, strong, readwrite) NSArray <bugModel *>*bugs;

@property (nonatomic, assign, readwrite) BOOL isRequesting;

@end

@implementation ViewModel
- (void)updateBugsWithHtmlString:(NSString *)htmlstring
{
    NSArray *tbs = [self parseTBODYWithHtmlStr:htmlstring];
    if (tbs.count > 0) {
        NSArray *bugs = [self parseBugsWithTBODY:tbs[0]];
        self.hasNewBugs = ![self compareOriginalBugsWithBugs:bugs];
        self.bugs = bugs;
    } else {
        self.bugs = @[];
        self.hasNewBugs = false;
    }
    
    NSArray *users = [self parseUserWithHtmlStr:htmlstring];
    if (users.count > 0) {
        self.user = [self removeHTMLLableWithString:users[0]];
    } else {
        self.user = @"";
    }
    
    if (self.user.length > 0) {
        self.isLogin = YES;
    } else {
        self.isLogin = NO;
    }
}

//匹配TBODY标签内容
- (NSArray *)parseTBODYWithHtmlStr:(NSString *)html
{
    NSString *tb = @"<tbody.*(?=>)(.|\n)*?</tbody>";
    return [self matchesInString:html withPattern:tb];
}
- (NSArray *)parseUserWithHtmlStr:(NSString *)html
{
    NSString *user = @"<i class='icon-user'.*(?=>)(.|\n)?<ul class='dropdown-menu'>";
    return [self matchesInString:html withPattern:user];
}
//从TBODY标签内容中解析bug数据模型
- (NSArray *)parseBugsWithTBODY:(NSString *)tbody
{
    NSString *tr = @"<tr.*(?=>)(.|\n)*?</tr>";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:tr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray *bugs = [NSMutableArray new];
    [regExp enumerateMatchesInString:tbody options:NSMatchingReportProgress range:NSMakeRange(0, tbody.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            bugModel *bug = [bugModel new];
            NSString *string = [tbody substringWithRange:result.range];
            
            NSString *pattern = @"<input type='checkbox'.*(?=>)(.|\n)*?</td>";//bugID
            NSArray *arr = [self matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.bugID = [self removeHTMLLableWithString:arr[0]];
            }
            
            pattern = @"<span class='severity.*(?=>)(.|\n)*?<td>";//type
            arr = [self matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.type = [self removeHTMLLableWithString:arr[0]];
            }
            
            pattern = @"<td class='text-left nobr'.*(?=>)(.|\n)*?</td>";//bugDescription
            arr = [self matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.bugDescription = [self removeHTMLLableWithString:arr[0]];
            }
            [bugs addObject:bug];
        }
    }];
    return bugs;
}

//根据正则表达式匹配字符串
- (NSArray <NSString *>*)matchesInString:(NSString *)string withPattern:(NSString *)pattern
{
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray <NSTextCheckingResult *>*arr = [regExp matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    NSMutableArray *strs = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strs addObject:[string substringWithRange:obj.range]];
    }];
    return strs;
}

//去除html标签
- (NSString *)removeHTMLLableWithString:(NSString *)string
{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n"
                                                                                    options:0
                                                                                      error:nil];
    string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}
//比较是否有新的bug
- (BOOL)compareOriginalBugsWithBugs:(NSArray *)bugs
{
    BOOL isSame = true;
    for (bugModel *bug in bugs) {
        BOOL flag = false;
        for (bugModel *oBug in self.bugs) {
            if ([bug.bugID isEqualToString:oBug.bugID]) {
                flag = true;
                break;
            }
        }
        if (!flag) {
            isSame = false;
            break;
        }
    }
    return isSame;
}

@end
