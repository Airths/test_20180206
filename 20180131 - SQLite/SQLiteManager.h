//
//  SQLiteManager.h
//  20180131 - SQLite
//
//  Created by Airths on 18/1/31.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SQLiteManager : NSObject

+ (instancetype)shareManager;

- (bool)openDB;

@end
