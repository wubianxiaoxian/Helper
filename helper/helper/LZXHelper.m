//
//  LZXHelper.m
//  Connotation
//
//  Created by LZXuan on 14-12-20.
//  Copyright (c) 2014年 LZXuan. All rights reserved.
//

#import "LZXHelper.h"
#import "NSString+Hashing.h"
@implementation LZXHelper
+ (NSString *)dateStringFromNumberTimer:(NSString *)timerStr {
    //转化为Double
    double t = [timerStr doubleValue];
    //计算出距离1970的NSDate
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];
    //转化为 时间格式化字符串
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //转化为 时间字符串
    return [df stringFromDate:date];
}
//动态 计算行高
//根据字符串的实际内容的多少 在固定的宽度和字体的大小，动态的计算出实际的高度
+ (CGFloat)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontSize:(CGFloat)size{
    if ([LZXHelper getCurrentIOS] >= 7.0) {
        //iOS7之后
        /*
         第一个参数: 预设空间 宽度固定  高度预设 一个最大值
         第二个参数: 行间距 如果超出范围是否截断
         第三个参数: 属性字典 可以设置字体大小
         */
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        //返回计算出的行高
        return rect.size.height;
        
    }else {
        //iOS7之前
        /*
         1.第一个参数  设置的字体固定大小
         2.预设 宽度和高度 宽度是固定的 高度一般写成最大值
         3.换行模式 字符换行
         */
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(textWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        return textSize.height;//返回 计算出得行高
    }
}

//获取iOS版本号
+ (double)getCurrentIOS {
    return [[[UIDevice currentDevice] systemVersion] doubleValue];
}
+ (CGSize)getScreenSize {
    return [[UIScreen mainScreen] bounds].size;
}
//获得当前系统时间到指定时间的时间差字符串,传入目标时间字符串和格式
+(NSString*)stringNowToDate:(NSString*)toDate formater:(NSString*)formatStr
{
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    if (formatStr) {
        [formater setDateFormat:formatStr];
    }
    else{
        [formater setDateFormat:[NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
    }
    NSDate *date=[formater dateFromString:toDate];
    
    return [self stringNowToDate:date];
    
}
//获得到指定时间的时间差字符串,格式在此方法内返回前自己根据需要格式化
+(NSString*)stringNowToDate:(NSDate*)toDate
{
    //创建日期 NSCalendar对象
    NSCalendar *cal = [NSCalendar currentCalendar];
    //得到当前时间
    NSDate *today = [NSDate date];
    
    //用来得到具体的时差,位运算
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ;
    
    if (toDate && today) {//不为nil进行转化
        NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:toDate options:0 ];
        
        //NSString *dateStr=[NSString stringWithFormat:@"%d年%d月%d日%d时%d分%d秒",[d year],[d month], [d day], [d hour], [d minute], [d second]];
        NSString *dateStr=[NSString stringWithFormat:@"%02ld:%02ld:%02ld",[d hour], [d minute], [d second]];
        return dateStr;
    }
    return @"";
}
+ (NSString *)getFullCacheFilePathWithName:(NSString *)fileName{
    //1.拼接缓存路径 MyCaChes是自己创建的一个目录
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/MyCaches"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //2.判断自己的缓存目录是否存在
    if ([fm fileExistsAtPath:myCachePath]) {
        //不存在那么就创建一个MyCaches
        BOOL ret = [fm createDirectoryAtPath:myCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!ret) {
            NSLog(@"缓存目录创建失败");
        }
    }
    //拼接问价的全路径
    return [myCachePath stringByAppendingFormat:@"/%@",fileName];
}
//判断 缓存文件 是否超时
//url是一个网址
+ (BOOL)isOutTimeOfFileWithUrl:(NSString *)url{
    NSString *fileName = [url MD5Hash];
    //获取url 对应的缓存文件的地址
    NSString *fileCache = [LZXHelper getFullCacheFilePathWithName:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dict = [fm attributesOfItemAtPath:fileCache error:nil];
    //获取当前文件的上次修改时间
    NSDate *pastDate = [dict fileModificationDate];
    //时间差 获取上次修改时间和当前现在时间的时间差 单位s
    NSTimeInterval subTimer = [pastDate timeIntervalSinceNow];
    //一般缓存文件 超时时间 设置为 1小时 60*60s
    //时间差是正的
    if (subTimer<0) {
        subTimer = -subTimer;
    }
    if (subTimer>60*60) {//超时
        return YES;
    }
    else{
        return NO;//没有超时
    }
}
@end


