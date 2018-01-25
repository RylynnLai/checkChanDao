//
//  ViewModel.h
//  checkChanDao
//
//  Created by LLZ on 2018/1/25.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bugModel.h"

@interface ViewModel : NSObject

@property (nonatomic, assign, readonly) BOOL hasNewBugs;

@property (nonatomic, assign, readonly) BOOL isLogin;

@property (nonatomic, copy, readonly) NSString *user;

@property (nonatomic, strong, readonly) NSArray <bugModel *>*bugs;

@property (nonatomic, assign, readonly) BOOL isRequesting;

- (void)updateBugsWithHtmlString:(NSString *)htmlstring;

@end
