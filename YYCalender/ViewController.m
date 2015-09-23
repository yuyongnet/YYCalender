//
//  ViewController.m
//  YYCalender
//
//  Created by yuy on 15/8/14.
//  Copyright (c) 2015年 DFKJ. All rights reserved.
// 测试中

#import "ViewController.h"
#import "CollectionController.h"

@interface ViewController ()<SelectTimeDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor greenColor];
    
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(70,150, KScreenWidth-140, 50);
    button.backgroundColor=[UIColor redColor];
    [button setTitle:@"ShowCalender" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showCalenderClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
  
        CollectionController * cC= [[CollectionController alloc] init];
    cC.view.backgroundColor=[UIColor blueColor];
        cC.delegate=self;
        cC.view.frame = CGRectMake(0, 250, KScreenWidth, KScreenHeight);
        [self addChildViewController:cC];
        [self.view addSubview:cC.view];


}
-(void)selectStartTimeDescription:(NSString *)timeStr
{
    NSLog(@"%@",[NSString stringWithFormat:@"入住日期:%@",timeStr]);
}
-(void)selectEndTimeDescription:(NSString *)timeStr
{
    NSLog(@"%@",[NSString stringWithFormat:@"退房日期:%@",timeStr]);
}

-(void)showCalenderClick:(UIButton *)sender
{
    CollectionController * clv=[[CollectionController alloc]init];
    [self.navigationController pushViewController:clv animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
