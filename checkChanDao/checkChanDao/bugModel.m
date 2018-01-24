//
//  bugModel.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "bugModel.h"

@implementation bugModel
+ (NSArray *)bugsModelWithHtmlString:(NSString *)htmlstring
{
    NSArray *tbs = [bugModel parseTBODYWithHtmlStr:htmlstring];
    if (tbs.count > 0) {
        return [bugModel parseBugsWithTBODY:tbs[0]];
    }
    return @[];
}

+ (NSArray *)parseTBODYWithHtmlStr:(NSString *)html
{
    NSString *tb = @"<tbody.*(?=>)(.|\n)*?</tbody>";
    return [bugModel matchesInString:html withPattern:tb];
}

+ (NSArray *)parseBugsWithTBODY:(NSString *)tbody
{
    NSString *tr = @"<tr.*(?=>)(.|\n)*?</tr>";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:tr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray *bugs = [NSMutableArray new];
    [regExp enumerateMatchesInString:tbody options:NSMatchingReportProgress range:NSMakeRange(0, tbody.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            bugModel *bug = [bugModel new];
            NSString *string = [tbody substringWithRange:result.range];
            
            NSString *pattern = @"<input type='checkbox'.*(?=>)(.|\n)*?</td>";//bugID
            NSArray *arr = [bugModel matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.bugID = [bugModel removeHTMLLableWithString:arr[0]];
            }
            
            pattern = @"<span class='severity.*(?=>)(.|\n)*?<td>";//type
            arr = [bugModel matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.type = [bugModel removeHTMLLableWithString:arr[0]];
            }
            
            pattern = @"<td class='text-left nobr'.*(?=>)(.|\n)*?</td>";//bugDescription
            arr = [bugModel matchesInString:string withPattern:pattern];
            if (arr.count > 0) {
                bug.bugDescription = [bugModel removeHTMLLableWithString:arr[0]];
            }
            [bugs addObject:bug];
        }
    }];
    return bugs;
}

+ (NSArray <NSString *>*)matchesInString:(NSString *)string withPattern:(NSString *)pattern
{
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray <NSTextCheckingResult *>*arr = [regExp matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    NSMutableArray *strs = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strs addObject:[string substringWithRange:obj.range]];
    }];
    return strs;
}

+ (NSString *)removeHTMLLableWithString:(NSString *)string
{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n"
                                                                                    options:0
                                                                                      error:nil];
    string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}


@end
