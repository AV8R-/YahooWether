//
//  Forecast.h
//  YahooWether
//
//  Created by Admin on 04/07/14.
//  Copyright (c) 2014 manshilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Forecast : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSDate * formattedDate;
@property (nonatomic, retain) NSString * high;
@property (nonatomic, retain) NSString * low;
@property (nonatomic, retain) NSString * text;

@end
