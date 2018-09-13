//
//  QiniuUploadHelper.h
//  meb3.0
//
//  Created by hz on 16/4/6.
//  Copyright © 2016年 hz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QiNiu_baseURL @"https://cdn-ssl.meb.com/"
#define QiNiu_safe_BaseURL @"https://si.meb.com/"
#define QiNiu_getTokenURL @"https://ygapidev.meb.com/api/app/v1.0/home/getqiniutoken"

@interface QiniuUploadHelper : NSObject

@property(copy,nonatomic)void(^singleSuccessBlock)(NSString *);

@property(copy,nonatomic)void(^singleFailureBlock)(void);

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *safeBaseURL;
@property (strong, nonatomic) NSString *getTokenURL;

+ (instancetype)sharedUploadHelper;

@end
