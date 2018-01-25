//
//  Controller.h
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModel.h"

@interface Controller : NSObject
@property (nonatomic, strong, readonly) ViewModel *viewModel;
@property (nonatomic, assign, readonly) BOOL isResuesting;
/**
 单例

 @return 单例
 */
+ (instancetype)shareController;

/**
 初始化状态栏图标，及其他设置
 */
- (void)start;

/**
 检查禅道bug列表
 */
- (void)checkChanDao;

/**
 登录

 @param acount 账号
 @param pwd 密码
 @param completion 登录事件完成处理
 */
- (void)loginWithAcount:(NSString *)acount andPwd:(NSString *)pwd completionHandler:(void (^)(bool isSucceed))completion;

- (void)logout;

/**
 用Safari打开禅道bug详情页面

 @param bugID 禅道bugID
 */
- (void)openChanDaoWithID:(NSString *)bugID;

//- (void)sendNotice;
@end
