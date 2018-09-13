//
//  QiniuUploadHelper.m
//  meb3.0
//
//  Created by hz on 16/4/6.
//  Copyright © 2016年 hz. All rights reserved.
//

#import "QiniuUploadHelper.h"

@implementation QiniuUploadHelper

static id _instance = nil;

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance= [super allocWithZone:zone];
        
    });
    
    return _instance;
}

+ (instancetype)sharedUploadHelper {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc] init];
        
        QiniuUploadHelper *helper = _instance;
        helper.baseURL = QiNiu_baseURL;
        helper.safeBaseURL = QiNiu_safe_BaseURL;
        helper.getTokenURL = QiNiu_getTokenURL;
    });
    
    return _instance;
    
}

- (id)copyWithZone:(NSZone*)zone {
    
    return _instance;
    
}

@end
