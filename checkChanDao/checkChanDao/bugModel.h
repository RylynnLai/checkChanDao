//
//  bugModel.h
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface bugModel : NSObject
@property (nonatomic, copy) NSString *bugID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *bugDescription;

+ (NSArray *)bugsModelWithHtmlString:(NSString *)htmlstring;

@end
