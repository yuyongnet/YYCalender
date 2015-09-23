//
//  CollectionController.h
//  YYCalender
//
//  Created by yuy on 15/8/14.
//  Copyright (c) 2015年 DFKJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTimeDelegate <NSObject>

-(void)selectStartTimeDescription:(NSString *)timeStr;
-(void)selectEndTimeDescription:(NSString *)timeStr;

@end


@interface CollectionController : UIViewController

@property (nonatomic,weak)id<SelectTimeDelegate> delegate;

@end
