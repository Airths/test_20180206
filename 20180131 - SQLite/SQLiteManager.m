//
//  SQLiteManager.m
//  20180131 - SQLite
//
//  Created by Airths on 18/1/31.
//  Copyright © 2018年 QiShon. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>



@interface SQLiteManager ()

@property (nonatomic, assign) sqlite3* database;

@end



@implementation SQLiteManager
#pragma mark - 构造单例
static SQLiteManager* _instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self)
    {
        if(nil == _instance)
        {
            _instance = [super allocWithZone:zone];
        }
        return _instance;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

// 获取单例
+ (instancetype)shareManager
{
    return [[self alloc] init];
}

#pragma mark - Public Method
#pragma mark - 打开/创建数据库
- (bool)openDB {
    
    if (self.database) {
        return YES;
    }
    
    // app内数据库文件存放路径,一般存放在沙盒中
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *DBPath = [documentPath stringByAppendingPathComponent:@"appDB.sqlite"];
    NSLog(@"%s, %d, DBPath = %@", __func__, __LINE__, DBPath);
    
    /*
    sqlite3_open(const char *filename, sqlite3 **ppDb)
    param1.filename:数据库路径
    param2.ppDb:数据库对象
    */
    // 创建(指定路径不存在数据库文件) / 打开(已存在数据库文件)数据库文件
    int result = sqlite3_open(DBPath.UTF8String, &_database);
    if (SQLITE_OK == result) {
        NSLog(@"Open SQLite Database success");
        [self createTable];
        return YES;
    } else {
        NSLog(@"Open SQLite Database failure");
        return NO;
    }
}

#pragma mark - 关闭数据库
- (bool)closeDB {
    
    int result = sqlite3_close(self.database);
    if (SQLITE_OK == result) {
        self.database = nil;
        NSLog(@"Close SQLite Database success");
        return YES;
    } else {
        NSLog(@"Close SQLite Database failure");
        return NO;
    }
}

#pragma mark - 创建表
- (bool)createTable {
    
    //创建表的SQL语句
    //用户 表
    NSString *createUserTable = @"CREATE TABLE IF NOT EXISTS 't_User' ( 'ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'name' TEXT,'age' INTEGER,'icon' TEXT);";
    //车 表
    NSString *createCarTable = @"CREATE TABLE IF NOT EXISTS 't_Car' ('ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'type' TEXT,'output' REAL,'master' TEXT)";
    //项目中一般不会只有一个表
    NSArray *SQL_ARR = [NSArray arrayWithObjects:createUserTable, createCarTable, nil];
    return [self createTableExecSQL:SQL_ARR];
}

- (bool)createTableExecSQL:(NSArray *)SQL_ARR{
    
    for (NSString *SQL in SQL_ARR) {
        if (![self execSQL:SQL]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 更新
- (bool)updateIcon {
    
    NSString* name = @"name_6";
    NSString* icon = @"http://qiuxuewei.com/newIcon.png";
    NSString *SQL = [NSString stringWithFormat:@"UPDATE 't_User' SET icon='%@' WHERE name = '%@'", icon, name];
    if ([[SQLiteManager shareManager] execSQL:SQL]) {
        NSLog(@"修改数据成功");
        return YES;
    } else {
        NSLog(@"修改数据失败");
        return NO;
    }
}

#pragma mark - 删除数据
- (bool)deleteIcon {
    
    NSString* name = @"name_6";
    NSString* SQL = [NSString stringWithFormat:@"DELETE FROM 't_User' WHERE name = '%@'", name];
    if ([[SQLiteManager shareManager] execSQL:SQL]) {
        NSLog(@"删除数据成功");
        return YES;
    } else {
        NSLog(@"删除数据失败");
        return NO;
    }
}

#pragma mark - 插入数据
// 项目中的model自定义对象可以自定义一个将自身插入数据库的方法
- (bool)insertSelfToDB{
    
    //插入对象的SQL语句
    NSString* name = @"";
    long age = 10;
    NSString* icon = @"";
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO 't_User' (name, age, icon) VALUES ('%@', %ld, '%@');", name, age, icon];
    return [[SQLiteManager shareManager] execSQL:insertSQL];
}

#pragma mark - 查询数据库中数据
- (NSArray *)querySQL:(NSString *)SQL{
    
    /*
        sqlite3_prepare_v2(
                            sqlite3 *db,            // param1.数据库对象
                            const char *zSql,       // param2.查询语句
                            int nByte,              // param3.查询语句的长度:-1
                            sqlite3_stmt **ppStmt,  // param4.句柄(游标对象)
                            const char **pzTail
                           )
    */
    // 准备查询
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(self.database, SQL.UTF8String, -1, &stmt, nil);
    if (SQLITE_OK != result) {
        NSLog(@"准备查询失败!");
        return NULL;
    }
    
    // 准备查询成功,开始查询数据
    // 定义一个存放数据字典的可变数组
    NSMutableArray *dictArrM = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        // 一共获取表中所有列数(字段数)
        int columnCount = sqlite3_column_count(stmt);
        // 定义存放字段数据的字典
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < columnCount; i++) {
            // 取出i位置列的字段名,作为字典的键key
            const char *cKey = sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithUTF8String:cKey];
            //取出i位置存储的值,作为字典的值value
            const char *cValue = (const char *)sqlite3_column_text(stmt, i);
            NSString *value = [NSString stringWithUTF8String:cValue];
            //将此行数据 中此字段中key和value包装成 字典
            [dict setObject:value forKey:key];
        }
        [dictArrM addObject:dict];
    }
    return dictArrM;
}

#pragma mark - 附注
// 在自定义模型中有必要定义个工厂方法可将数据库对应表中所有数据取出,以模型数组的形式输出
+ (NSArray *)allUserFromDB{
    //查询表中所有数据的SQL语句
    NSString *SQL = @"SELECT name, age, icon FROM 't_User'";
    //取出数据库用户表中所有数据
    NSArray *allUserDictArr = [[SQLiteManager shareManager] querySQL:SQL];
    NSLog(@"%@",allUserDictArr);
    //将字典数组转化为模型数组
    NSMutableArray *modelArrM = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in allUserDictArr) {
        //[modelArrM addObject:[[User alloc] initWithDict:dict]];
    }
    return modelArrM;
}

#pragma 执行SQL语句
- (bool)execSQL:(NSString *)SQL {
    
    /*
     sqlite3_exec(
     sqlite3 *, // 数据库对象
     const char *sql, // 需要执行的SQL语句
     int (*callback)(void *, int, char **, char **), // 回调函数
     void *,  // 回调函数的第一个参数
     char **errmsg // 错误信息
     )
     */
    return sqlite3_exec(self.database, SQL.UTF8String, nil, nil, nil) == SQLITE_OK;
}

@end
















