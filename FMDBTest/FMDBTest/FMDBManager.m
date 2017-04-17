//
//  FMDBManager.m
//  FMDBTest
//
//  Created by 明镜止水 on 17/1/13.
//  Copyright © 2017年 明镜止水. All rights reserved.
//

#import "FMDBManager.h"


#define SQLITE_NAME @"QHWqlite.DB"

@interface FMDBManager ()
@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation FMDBManager



-(instancetype)init{
    
    self = [super init];
    if (self) {
        
        //1.获取沙盒中数据库文件名
        NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:SQLITE_NAME];
        //2.创建数据库队列
        NSLog(@"%@",fileName);
        self.db = [FMDatabase databaseWithPath:fileName];
    }
    return self;
    
}


/**
 数据库单利
 @return 返回单利
 */
+(instancetype)shareManager{
    
    static FMDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}



#pragma mark - 创建表
-(void)createFMDBBaseTableName:(NSString *)tableName andKeyName:(NSArray *)keys andKeyTypes:(NSArray *)keyTypes{
    
    if (tableName == nil) {
        NSLog(@"表名不能为空");
        return;
    }else if (keys == nil){
        NSLog(@"字段数组不能为空");
        return;
    }else if (keyTypes.count != keys.count){
        NSLog(@"字段名和字段类型个数不相等");
    }
    NSString *createStr = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",tableName];
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"%@", createStr];
    for (int i = 0; i < keys.count; i++) {
        if (keyTypes == nil) {
            [sql appendFormat:@",%@ text",keys[i]];
        }else{
            [sql appendFormat:@",%@ %@",keys[i],keyTypes[i]];
        }
        
        if (i == (keys.count - 1)) {
            [sql appendFormat:@");"];
        }
    }
    
    if ([self.db executeUpdate:sql]) {
        NSLog(@"创建表成功");
    }
}




#pragma mark - 插入数据
-(void)insertDataToTableName:(NSString *)name andDict:(NSDictionary *)dict{
    
    if (name == nil) {
        NSLog(@"表名不能为空!");
        return;
    }else if (dict == nil){
        NSLog(@"插入值字典不能为空!");
        return;
    }else;
    
    NSArray *allKeys = dict.allKeys;
    NSArray *allValues = dict.allValues;
    NSMutableString *sql = [[NSMutableString alloc] init];
    //    INSERT INTO PersonList (Name, Age, Sex, Phone, Address, Photo) VALUES (?,?,?,?,?,?)
    [sql appendFormat:@"insert into %@ (",name];
    for (int i = 0; i < allKeys.count; i++) {
        
        [sql appendFormat:@"%@",allKeys[i]];
        if (i == allKeys.count - 1) {
            [sql appendFormat:@")"];
        }else{
            [sql appendFormat:@","];
        }
        
    }
    [sql appendString:@"values("];
    for(int i=0;i<allValues.count;i++){
        [sql appendString:@"?"];
        if(i == (allValues.count-1)){
            [sql appendString:@");"];
        }else{
            [sql appendString:@","];
        }
    }
    
    if ([self.db executeUpdate:sql values:allValues error:nil]) {
        sql = nil;
        NSLog(@"插入成功");
    }
}



#pragma mark - 查询表中某个字段 或 整张表
-(NSArray *)selectFromTableName:(NSString *)name andKeys:(NSArray *)keys{
    
    if (name == nil) {
        NSLog(@"表名不能为空");
        return nil;
    }else if (keys == nil){
        NSLog(@"列表名不能为空");
    }
    //    SELECT LastName,FirstName FROM Persons
    NSMutableString *sql = [[NSMutableString alloc] init];
    if (keys == nil) {
        //当没有字段名的时候, 某人选中整个表
        [sql appendFormat:@"select * from %@",name];
    }else{
        [sql appendFormat:@"select "];
        for (int i = 0; i < keys.count; i++) {
            [sql appendFormat:@"%@",keys[i]];
            if (i == keys.count - 1) {
                [sql appendFormat:@" from %@",name];
            }else{
                [sql appendFormat:@","];
            }
        }
    }
    
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableArray *resuletSetArr = [NSMutableArray array];
    while (rs.next) {
        NSMutableDictionary *resultSetDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < [[rs.columnNameToIndexMap allKeys] count]; i++) {
            NSLog(@"字段名=%@ : 值 = %@",[rs.columnNameToIndexMap allKeys][i], [rs resultDictionary][[rs.columnNameToIndexMap allKeys][i]]);
            [resultSetDic setObject:[rs resultDictionary][[rs.columnNameToIndexMap allKeys][i]] forKey:[rs.columnNameToIndexMap allKeys][i]];
        }
        [resuletSetArr addObject:resultSetDic];
        resultSetDic = nil;
    }
    return [resuletSetArr copy];
}


#pragma mark - 删除表中某一行
-(void)deleteFromTableName:(NSString *)name andKeys:(NSDictionary *)dict{
    
    if (name == nil) {
        NSLog(@"表名不能为空");
        return;
    }
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    //    DELETE FROM Person WHERE id  in ('Wilson','','') or name in ( '');
    if (dict == nil) {
        //当dict = nil , 默认删除整张表内容
        [sql appendFormat:@"delete from %@",name];
    }else{
        
        NSArray *allKeys = [dict allKeys];
        [sql appendFormat:@"delete from %@ where ",name];
        for (int i = 0; i < allKeys.count; i++) {
            [sql appendFormat:@"%@ = '%@'",allKeys[i],dict[allKeys[i]]];
            if (i == allKeys.count - 1) {
                
            }else{
                [sql appendFormat:@" and "];
            }
        }
    }
    
    
    if ([self.db executeUpdate:sql]) {
        NSLog(@"删除成功");
        sql = nil;
    }
}

#pragma mark - 给数据库添加字段
//alter table 表名 ADD 字段 类型 NOT NULL Default 0
-(void)alterTableAddToTableName:(NSString *)name andKeys:(NSArray *)keys andKeyTypes:(NSArray *)keyTypes{
    
    if (name == nil && keys == nil) {
        NSLog(@"数据库或者表名不能为空");
        return;
    }
    for (int i = 0; i < keys.count; i++) {
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendFormat:@"alter table %@ add",name];
        [sql appendFormat:@" %@ %@",keys[i],keyTypes[i]];
        [self.db executeUpdate:sql];
        sql = nil;
    }
    
}

#pragma mark - 删除数据库字段
//alter table [表名] drop 字段名
-(void)dropTableName:(NSString *)name andKeys:(NSArray *)keys{
    
    if (name == nil && keys == nil) {
        NSLog(@"数据库或者表名不能为空");
        return;
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    //sqlite数据库系统不允许这种在数据库表中删除列的方式 (DROP COLUMN column_name)
    [sql appendFormat:@"alter table %@ drop column",name];
    for (int i = 0; i < keys.count; i++) {
        [sql appendFormat:@" %@",keys[i]];
        if(i == keys.count - 1){
            
        }else{
            [sql appendString:@","];
        }
        
    }
    [self.db executeUpdate:sql];
    sql = nil;
}







@end
