//
//  FMDBManager.h
//  FMDBTest
//
//  Created by 明镜止水 on 17/1/13.
//  Copyright © 2017年 明镜止水. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface FMDBManager : NSObject
@property (nonatomic, strong) FMDatabase *db;
+(instancetype)shareManager;

/**
 创建数据库表

 @param tableName 表名字
 @param keys 表中字段名
 @param keyTypes 表中字段类型
 */
-(void)createFMDBBaseTableName:(NSString *)tableName andKeyName:(NSArray *)keys andKeyTypes:(NSArray *)keyTypes;

/**
 向表中插入数据

 @param name 插入到的"表名"
 @param dict 插入的字段及值
 */
-(void)insertDataToTableName:(NSString *)name andDict:(NSDictionary *)dict;


/**
 查询字段

 @param name 要查询的表
 @param keys 查询的字段名
 @return 返回数组集合
 */
-(NSArray *)selectFromTableName:(NSString *)name andKeys:(NSArray *)keys;


/**
 向表中添加字段

 @param name 表名
 @param keys 字段名
 @param keyTypes 字段类型
 */
-(void)alterTableAddToTableName:(NSString *)name andKeys:(NSArray *)keys andKeyTypes:(NSArray *)keyTypes;

/**
 删除表中的字段

 @param name 表名
 @param keys 字段名
 */
-(void)dropTableName:(NSString *)name andKeys:(NSArray *)keys;

@end
