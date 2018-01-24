//
//  Controller.h
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bugModel.h"

@interface Controller : NSObject

@property (nonatomic, strong, readonly) NSArray <bugModel *>*bugs;

+ (instancetype)startController;
- (void)checkChanDao;
- (void)loginWithAcount:(NSString *)acount andPwd:(NSString *)pwd completionHandler:(void (^)(bool isSucceed))completion;
- (void)openChanDaoWithID:(NSString *)bugID;
@end
