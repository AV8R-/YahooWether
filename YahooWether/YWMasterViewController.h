//
//  YWMasterViewController.h
//  YahooWether
//
//  Created by Admin on 03.07.14.
//  Copyright (c) 2014 manshilin. All rights reserved.
//

static NSString * const BaseURLString = @"http://weather.yahooapis.com/forecastrss";
static NSString * const CityWOEIDString = @"919163"; //@"2442047" //WOEID for Los Angeles;
static NSString * const BaseImageURLString = @"http://l.yimg.com/a/i/us/we/52/";

#import <UIKit/UIKit.h>
#import "Forecast.h"

@interface YWMasterViewController : UIViewController<NSXMLParserDelegate>
{
    NSMutableArray *items_;
}
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *todayDate;
@property (weak, nonatomic) IBOutlet UILabel *todayLow;
@property (weak, nonatomic) IBOutlet UILabel *todayHigh;
@property (weak, nonatomic) IBOutlet UILabel *todayText;
@property (weak, nonatomic) IBOutlet UIImageView *todayImage;

@property (weak, nonatomic) IBOutlet UILabel *tomorrowDate;
@property (weak, nonatomic) IBOutlet UILabel *tommorowLow;
@property (weak, nonatomic) IBOutlet UILabel *tommorowHigh;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowText;
@property (weak, nonatomic) IBOutlet UIImageView *tomorrowImage;

-(IBAction)refresh:(id)sender;

-(void) loadWether;
-(void) loadData;
-(void) configureUI;

@end
