//
//  CollectionController.m
//  YYCalender
//
//  Created by yuy on 15/8/14.
//  Copyright (c) 2015年 DFKJ. All rights reserved.
//

#import "CollectionController.h"

#import "MyCollectionViewCell.h"

@interface CollectionController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView    * _collectionView;   //日历显示的界面
    UIView              *_headerView;
    
    int                 currentNumber;      //第一次选中的日期索引值
    int                 nextNumber;         //第二次选中的日期的索引值，但要保证大于第一次选中的值才能生效
    BOOL                isClickTime;//是否是当前月，第一次点击时设为YES
    int                 currentYear;//当前页的年
    int                 currentMonth;//当前页的月
    int                 currentDay;//当前页的日
    int                 currentWeek;//当前页的日是周几
    
    int                 nowYear;//今天的年份
    int                 nowMonth;//今天的月份
    int                 nowDay;//今天的日期
    int                 nowWeek;//今天是周几
    
    int                 oneWeek;//每月一号是周几
//    int                 changeYear;//改变后的年
//    int                 changeMonth;//改变后的月
    int                 changeDay;//改变后的日
    int                 sumDays;//当前月的总天数
    
    int                 leftMonth;  //左右年月日期
    int                 rightMonth;
    int                 leftYear;
    int                 rightYear;
    
    NSString            *yinliMonth; //阴历日期
    NSString            *yinliDay;
    
                                        //存放阴历的数组
    NSArray             *chineseYears;//天干地支
    NSArray             *chineseMonths;//阴历月份
    NSArray             *chineseDays;//阴历day
}
@end

@implementation CollectionController
static int  clickNumber=1;
- (void)viewDidLoad {
    [super viewDidLoad];
    clickNumber=1;
    
    //获取天干地支等阴历具体日期
    [self getChineseCalendar];
    [self getNowDate];
  
    //计算当前月的总天数
    sumDays =  [self getCurrentMonthHavesDaysWithYear:currentYear WithMonth:currentMonth];
    //计算当前月一号是周几
    oneWeek = [self getCurrentTimeIsWeekendsWithYear:currentYear WithMonth:currentMonth WithDay:changeDay];
    
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
      self.view.backgroundColor=[UIColor clearColor];
    [self initCollectionView];
    
    _headerView=[[UIView  alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth-20, 30)];
    _headerView.backgroundColor=[UIColor redColor];
}

-(void)initCollectionView
{
    
    UICollectionViewFlowLayout * flayLayout=[[UICollectionViewFlowLayout alloc]init];
    flayLayout.minimumLineSpacing=0;   //行与行之间的距离
    flayLayout.minimumInteritemSpacing=0;//列与列之间的距离
    //设置单元格的尺寸
   // flayLayout.itemSize = CGSizeMake(80, 80);
    //设置头视图高度
    flayLayout.headerReferenceSize = CGSizeMake(0, 40);
    [flayLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView =[[UICollectionView alloc]initWithFrame:CGRectMake((KScreenWidth-280)/2, 0, 280, 270) collectionViewLayout:flayLayout];
    _collectionView.backgroundColor=[UIColor redColor];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
    
}

#pragma mark UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//定义展示UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ((sumDays+oneWeek-1)%7==0)
    {
        collectionView.frame=CGRectMake((KScreenWidth-280)/2, 0, 280,40*((sumDays+oneWeek-1)/7+1));
    }
    else
    {
        collectionView.frame=CGRectMake((KScreenWidth-280)/2, 0, 280,40*((sumDays+oneWeek-1)/7+2));
    }
    
    return sumDays+(oneWeek-1);
}
//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identify=@"cell";
    MyCollectionViewCell * cell=[collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
   
   // [cell sizeToFit];
    if (!cell) {
    }
    if (indexPath.row>=oneWeek-1)//当前月一号前不显示
    {
        cell.layer.borderColor=[UIColor blackColor].CGColor;
        cell.layer.borderWidth=0.5;
        cell.backgroundColor=[UIColor whiteColor];
        cell.gongliLb.text=[NSString stringWithFormat:@"%ld",indexPath.row+1-oneWeek+1];
        //阴历的显示
        yinliDay=[self getCurrentTimeYinLiTimeWithYear:currentYear WithMonth:currentMonth WithDay:indexPath.row+1-oneWeek+1];
        if ([ yinliDay isEqualToString:@"初一"])
        {
            cell.nongliLb.text=[NSString stringWithFormat:@"%@",yinliMonth];
        }
        else
        {
            cell.nongliLb.text=[NSString stringWithFormat:@"%@",yinliDay];
        }
        
        
        if (nextNumber==0&&currentNumber==indexPath.row&&isClickTime)
        {
            cell.nongliLb.text=@"入住";
            cell.backgroundColor=[UIColor greenColor];
        }
        
        //选中起始日期和结束日期要改变颜色
        if (indexPath.row>=currentNumber&&indexPath.row<=nextNumber&&currentNumber!=nextNumber)//||(currentYear==nowYear&&currentMonth==nowMonth&&indexPath.row+1-oneWeek+1==currentDay)
        {
            cell.backgroundColor=[UIColor greenColor];
            if (currentNumber==indexPath.row)
            {
                 cell.nongliLb.text=@"入住";
            }
            if (nextNumber==indexPath.row)
            {
                cell.nongliLb.text=@"退房";
            }
        }
    }
    else
    {
        cell.gongliLb.text=@"";
        cell.nongliLb.text=@"";
        cell.layer.borderColor=[UIColor whiteColor].CGColor;
        cell.layer.borderWidth=0;
        cell.backgroundColor=[UIColor redColor];
    }
        return cell;
}
#pragma mark  头部显示的内容
//头部显示的内容
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * headerView=[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    //[headerView addSubview:_headerView];
    headerView.backgroundColor=[UIColor purpleColor];
    for (UIView * view in [headerView subviews])
    {
        if ([view isKindOfClass:[UILabel
             class]])
        {
            [view removeFromSuperview];
        }
        if ([view isKindOfClass:[UIButton
                                 class]])
        {
            [view removeFromSuperview];
        }
        
    }
    UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 40)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=[NSString stringWithFormat:@"%d年%d月",currentYear,currentMonth];
    [headerView addSubview:label];
    
    //左侧月份
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0,0, 60, 40);
    [button setTitle:[NSString stringWithFormat:@"%d月",leftMonth] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(miniusMonthClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    //右侧月份
    UIButton * button1=[UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame=CGRectMake(220,0, 60, 40);
    [button1 setTitle:[NSString stringWithFormat:@"%d月",rightMonth] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(addMonthClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button1];
    
    return  headerView;
}


#pragma  mark UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小（返回CGSize：宽度和高度）
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(40, 40);
   // return CGSizeMake(90, 110);
}
//定义每个UICollectionView 区距上、左、下、右的间距（返回UIEdgeInsets：上、左、下、右）

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

////定义每个UICollectionView 纵向和横向的的间距
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0;
//}

//UICollectionView被选中时调用的方法

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentYear<nowYear||(currentYear==nowYear&&currentMonth<nowMonth)||(currentYear==nowYear&&currentMonth==nowMonth&&nowDay>indexPath.row+1-oneWeek+1))//如果时间在今天之前不能点击
    {
        NSLog(@"选取的时间在今天之前，无效");
    }
    else
    {
        isClickTime=YES;
        if (clickNumber>2)//大于二时重新计算置1 //大于二时不能点击了，此时已经选中了两个节点
        {
            currentNumber=0;
            nextNumber=0;
            clickNumber=1;
            
        }
        //else
        //{
            if (clickNumber==1) //第一次点击时
            {
                currentNumber=indexPath.row;
            }
            else
            {
                if (currentNumber>=indexPath.row)  //当前点击的日期在上一次的前面
                {
                    currentNumber=indexPath.row;
                    clickNumber=1;
                }
                else
                {
                    nextNumber=indexPath.row;
                    //选中俩个节点的具体时间
                    NSLog([NSString stringWithFormat:@"%d年%d月%d日---%d年%d月%d日",currentYear,currentMonth,currentNumber-(oneWeek-1)+1,currentYear,currentMonth,nextNumber-(oneWeek-1)+1]);
                }
            }
            
            [_collectionView reloadData];
            clickNumber++;
            
            NSLog(@"选择%ld",indexPath.row);
       // }
        if (nextNumber==0)
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(selectStartTimeDescription:)] ) {
                
                [self.delegate selectStartTimeDescription:[NSString stringWithFormat:@"%d年%d月%d日",currentYear,currentMonth,currentNumber-(oneWeek-1)+1]];
            }
        }
        else
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(selectEndTimeDescription:)] ) {
                
                [self.delegate selectEndTimeDescription:[NSString stringWithFormat:@"%d年%d月%d日",currentYear,currentMonth,nextNumber-(oneWeek-1)+1]];
            }
        }
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark  月份加减的处理
-(void)miniusMonthClick:(UIButton *)sender
{
    NSLog(@"减少一个月份");
    isClickTime=NO;
    clickNumber=1;
    currentNumber=0;
    nextNumber=0;
    currentYear=leftYear;
    currentMonth=leftMonth;
    
    //计算当前月的总天数
    sumDays =  [self getCurrentMonthHavesDaysWithYear:currentYear WithMonth:currentMonth];
    //计算当前月一号是周几
    oneWeek = [self getCurrentTimeIsWeekendsWithYear:currentYear WithMonth:currentMonth WithDay:changeDay];
    [self getLeftAndRightMonthWithCurrentYear:currentYear WithCurrentMonth:currentMonth];
   
    [_collectionView reloadData];
}
-(void)addMonthClick:(UIButton *)sender
{
    NSLog(@"增加一个月份");
    isClickTime=NO;
    clickNumber=1;
    currentNumber=0;
    nextNumber=0;
    currentYear=rightYear;
    currentMonth=rightMonth;
    
    //计算当前月的总天数
    sumDays =  [self getCurrentMonthHavesDaysWithYear:currentYear WithMonth:currentMonth];
    //计算当前月一号是周几
    oneWeek = [self getCurrentTimeIsWeekendsWithYear:currentYear WithMonth:currentMonth WithDay:changeDay];
    
    [self getLeftAndRightMonthWithCurrentYear:currentYear WithCurrentMonth:currentMonth];
    
    [_collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 计算当前的日期，年月日和周几
-(void)getNowDate
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [[NSDateComponents alloc] init] ;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    nowWeek = [comps weekday];
    nowYear=[comps year];
    nowMonth= [comps month];
    nowDay = [comps day];
    currentYear=nowYear;
    currentMonth=nowMonth;
    currentDay=nowDay;
    currentWeek=nowWeek;
    changeDay=1;
    
    [self getLeftAndRightMonthWithCurrentYear:currentYear WithCurrentMonth:currentMonth];
    
}
#pragma mark  计算左右键显示的月份
-(void)getLeftAndRightMonthWithCurrentYear:(int)year WithCurrentMonth:(int)month
{
    if (month>1&&month<12)
    {
        leftMonth=month-1;
        rightMonth=month+1;
        leftYear=year;
        rightYear=year;
    }
    else
    {
        if (month==1)
        {
            leftMonth=12;
            rightMonth=month+1;
            leftYear=year-1;
            rightYear=year;
        }
        else
        {
            leftMonth=month-1;
            rightMonth=1;
            leftYear=year;
            rightYear=year+1;
        }
    }
}
#pragma mark 计算当前月有多少天
-(int)getCurrentMonthHavesDaysWithYear:(int)year WithMonth:(int)month
{
    int days;
    days=0;
    if (month==1||month==3||month==5||month==7||month==8||month==10||month==12)
    {
        days=31;
    }
    else if (month==4||month==6||month==9||month==11)
    {
        days=30;
    }
    else
    {
        if (0==year%100)
        {
            if (0==year%400)
            {
                days=29;
            }
            else
            {
                days=28;
            }
        }
        else
        {
            if (0==year%4)
            {
                days=29;
            }
            else
            {
                days=28;
            }
        }
    }
    return days;
}
/**
 *  计算当前月的某一天（默认填一号）是星期几
 *
 *  @return 无
 */
#pragma mark 计算当前月的某一天（默认填一号）是星期几
-(int)getCurrentTimeIsWeekendsWithYear:(long)year WithMonth:(long)month WithDay:(long)day
{
    //获取日期
    NSArray * arrWeek=[NSArray arrayWithObjects:@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];
    
    NSString* timeStr = [NSString stringWithFormat:@"%ld-%ld-%ld 17:40:50",year,month,day];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:timeStr]; //------------将字符串按formatter转成nsdate
    // NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [[NSDateComponents alloc] init] ;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    oneWeek = [comps weekday];
    currentYear=[comps year];
    currentMonth = [comps month];   //当前年月
    int days = [comps day];
    //    m_labDate.text=[NSString stringWithFormat:@"%d年%d月",year,month];
    //    m_labToday.text=[NSString stringWithFormat:@"%d",day];
    //    m_labWeek.text=[NSString stringWithFormat:@"%@",[arrWeek objectAtIndex:week]];
    
    //得到阴历日期
  //  NSString * str=  [self getChineseCalendarWithDate:date];
    return [comps weekday];
}

#pragma mark 获得当前是阴历的日期
-(NSString *)getCurrentTimeYinLiTimeWithYear:(long)year WithMonth:(long)month WithDay:(long)day
{
    NSString* timeStr = [NSString stringWithFormat:@"%ld-%ld-%ld 17:40:50",year,month,day];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:timeStr]; //------------将字符串按
    
    return [self getChineseCalendarWithDate:date];
}

#pragma mark 用来进行转换的阴历日期
-(void)getChineseCalendar
{
     chineseYears = [NSArray arrayWithObjects:
                               @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                               @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                               @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                               @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                               @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                               @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    
    
    chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];

}

#pragma mark 公历转阴历的方法
-(NSString*)getChineseCalendarWithDate:(NSDate *)date{
    
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
   // NSLog(@"%ld_%ld_%ld  %@",(long)localeComp.year,(long)localeComp.month,(long)localeComp.day, localeComp.date);
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
   yinliMonth= [chineseMonths objectAtIndex:localeComp.month-1];
    yinliDay = [chineseDays objectAtIndex:localeComp.day-1];
    
    NSString *chineseCal_str =[NSString stringWithFormat: @"%@_%@_%@",y_str,yinliMonth,yinliDay];
    
    return [chineseDays objectAtIndex:localeComp.day-1];
}


@end
