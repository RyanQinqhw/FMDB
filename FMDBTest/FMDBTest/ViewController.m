//
//  ViewController.m
//  FMDBTest
//
//  Created by 明镜止水 on 17/1/13.
//  Copyright © 2017年 明镜止水. All rights reserved.
//

#import "ViewController.h"
#import <FMDB/FMDB.h>
#import "FMDBManager.h"

//#define SQLITE_NAME @"QHWFMDB.DB"
#define QHWtableName @"qhwTest"
@interface ViewController (){
    
    BOOL flag;
    BOOL alterFlag;
    
}

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDBManager *fmdbManager;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *weight;
@property (weak, nonatomic) IBOutlet UITextField *work;



@property (weak, nonatomic) IBOutlet UITextField *readName;
@property (weak, nonatomic) IBOutlet UITextField *readAge;
@property (weak, nonatomic) IBOutlet UITextField *readWeight;
@property (weak, nonatomic) IBOutlet UITextField *readWork;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.work.enabled = NO;
    self.readWork.enabled = NO;
    
    [self createTableName];
    
}

-(void)createTableName{
    FMDBManager *fmdbManager = [FMDBManager shareManager];
    if ([fmdbManager.db open]) {
        NSLog(@"数据库打开成功");
    }else{
        NSLog(@"数据库打开失败");
    }
    
    
    NSArray *keyNames = @[@"name",@"age",@"weight"];
    NSArray *keyTypes = @[@"text",@"integer",@"text"];
    [fmdbManager createFMDBBaseTableName:QHWtableName andKeyName:keyNames andKeyTypes:keyTypes];
    
    self.fmdbManager = fmdbManager;
    

}

#pragma mark - 插入数据
-(void)insertToSqlit{
    NSDictionary *insertDict = nil;
    if (!alterFlag) {
    
        insertDict = @{@"name" : self.name.text,
                       @"age" : [NSNumber numberWithInteger:[self.age.text integerValue]],
                       @"weight" : self.weight.text};
    }else{
        insertDict = @{@"name" : self.name.text,
                       @"age" : [NSNumber numberWithInteger:[self.age.text integerValue]],
                       @"weight" : self.weight.text,
                       @"work" : self.work.text};
        
    }
    [self.fmdbManager insertDataToTableName:QHWtableName andDict:insertDict];
}

- (IBAction)insertToDataBtn:(id)sender {
    [self insertToSqlit];
}

#pragma mark - 从数据库中读取数据
- (IBAction)readDataBtn:(id)sender {
    NSArray *keyNames = nil;
    if (!alterFlag) {
        keyNames = @[@"name",@"age",@"weight"];
    }else{
        keyNames = @[@"name",@"age",@"weight",@"work"];
    }

   NSArray *selectArr = [self.fmdbManager selectFromTableName:QHWtableName andKeys:keyNames];
    for (NSMutableDictionary *MuDict in selectArr) {
        for (NSString *keyName in keyNames) {
            if ([keyName isEqualToString:@"name"]) {
                if ([MuDict[keyName] isKindOfClass:[NSNull class]]) {
                    self.readName.text = @"";
                    continue;
                }
                self.readName.text = MuDict[keyName];
            }
            if ([keyName isEqualToString:@"age"]) {
                if ([MuDict[keyName] isKindOfClass:[NSNull class]]) {
                    self.readAge.text = @"";
                    continue;
                }
                self.readAge.text = [NSString stringWithFormat:@"%@",MuDict[keyName]];
            }
            if ([keyName isEqualToString:@"weight"]) {
                if ([MuDict[keyName] isKindOfClass:[NSNull class]]) {
                    self.readWeight.text = @"";
                    continue;
                }
                self.readWeight.text = MuDict[keyName];
            }
            if ([keyName isEqualToString:@"work"]) {
                if ([MuDict[keyName] isKindOfClass:[NSNull class]]) {
                    self.readWork.text = @"";
                    continue;
                }
                self.readWork.text = MuDict[keyName];
            }
        }
    }
}

- (IBAction)alterDataBtn:(id)sender{
    alterFlag = YES;
    self.work.enabled = YES;
    self.readWork.enabled = YES;
    NSArray *addKeys = @[@"work"];
    NSArray *addKeyTypes = @[@"text"];
    [self.fmdbManager alterTableAddToTableName:QHWtableName andKeys:addKeys andKeyTypes:addKeyTypes];
}

- (IBAction)dropDataBtn:(id)sender{
    NSArray *dropKeys = @[@"work"];
    alterFlag = NO;
    self.work.enabled = NO;
    self.readWork.enabled = NO;
    self.work.text = @"";
    self.readWork.text = @"";
    [self.fmdbManager dropTableName:QHWtableName andKeys:dropKeys];
}






/*
#pragma mark - 查询表中全部字段
-(void)selectFormTableName:(NSString *)name{
    
    if (name == nil) {
        NSLog(@"表名不能为空!");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@",name];
    FMResultSet *rs = [self.db executeQuery:sql];
    
    while (rs.next) {
        
        for (int i = 0; i < [[rs.columnNameToIndexMap allKeys] count]; i++) {
            NSLog(@"字段名=%@ : 值 = %@",[rs.columnNameToIndexMap allKeys][i], [rs resultDictionary][[rs.columnNameToIndexMap allKeys][i]]);
        }
        
    }
}
*/

/*
#pragma mark - 查询表中某个字段 或 整张表
-(void)selectFromTableName:(NSString *)name andKeys:(NSArray *)keys{
    
    if (name == nil) {
        NSLog(@"表名不能为空");
        return;
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
    
    while (rs.next) {
        for (int i = 0; i < [[rs.columnNameToIndexMap allKeys] count]; i++) {
            NSLog(@"字段名=%@ : 值 = %@",[rs.columnNameToIndexMap allKeys][i], [rs resultDictionary][[rs.columnNameToIndexMap allKeys][i]]);
        }
    }
    
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
    
    
    [self.db executeUpdate:sql];
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
}

*/



@end
