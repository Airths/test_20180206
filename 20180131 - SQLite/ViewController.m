//
//  ViewController.m
//  20180131 - SQLite
//
//  Created by Airths on 18/1/31.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "ViewController.h"
#import "SQLiteManager.h"



@interface ViewController ()

@property (nonatomic, strong) SQLiteManager* manager;

@end



@implementation ViewController
#pragma mark - setter && getter
- (SQLiteManager *)manager {
    
    if (!_manager) {
        _manager = [SQLiteManager shareManager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.manager openDB];
}

@end
