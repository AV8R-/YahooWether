//
//  YWDetailViewController.h
//  YahooWether
//
//  Created by Admin on 03.07.14.
//  Copyright (c) 2014 manshilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
