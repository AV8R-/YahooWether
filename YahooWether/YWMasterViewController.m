//
//  YWMasterViewController.m
//  YahooWether
//
//  Created by Admin on 03.07.14.
//  Copyright (c) 2014 manshilin. All rights reserved.
//

#import "YWMasterViewController.h"
#import "YWAppDelegate.h"
#import "Forecast.h"
#import "UIImageView+AFNetworking.h"

@interface YWMasterViewController ()

@end

@implementation YWMasterViewController
@synthesize managedObjectContext;
@synthesize items = items_;
@synthesize todayForecast = todayForecast_;
@synthesize tomorrowForecast = tomorrowForecast_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self configureUI];
    [self loadData];
    [self configureUI];
    [self loadWether];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Load Data
- (IBAction)refresh:(id)sender
{
    [self loadWether];
}

-(void) loadWether
{
    NSString *string = [NSString stringWithFormat:@"%@?w=%@&u=c", BaseURLString, CityWOEIDString];
    NSURL *url = [NSURL URLWithString:string];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    [manager setResponseSerializer:[AFXMLParserResponseSerializer new]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Data: %@", responseObject);
        
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        [XMLParser setShouldProcessNamespaces:YES];
        
        // Leave these commented for now (you first need to add the delegate methods)
        XMLParser.delegate = self;
        [XMLParser parse];
        [self configureUI];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
}

-(void) loadData
{
    YWAppDelegate *appDelegate = (YWAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"formattedDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //Обработка ошибки
        NSLog(@"Error during loading data : %@", error);
        self.items = [[NSMutableArray alloc] init];
    }
    
    self.items = mutableFetchResults;
    
    NSMutableArray *deleteQueue = [[NSMutableArray alloc] init];
    
    for (Forecast *forecast in items_)
    {
        NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        
        NSDateComponents* components = [calendar components:flags fromDate:currentDate];
        
        NSDate* dateOnly = [calendar dateFromComponents:components];
        
        if ([forecast.formattedDate compare:dateOnly] == NSOrderedAscending)
            [deleteQueue addObject:forecast];
    }
    
    for(id forecast in deleteQueue)
    {
        [context deleteObject:forecast];
        [items_ removeObject:forecast];
    }
    
    [deleteQueue removeAllObjects];
}

#pragma mark - UI Configurations
-(void) configureUI
{
    if(items_)
    {
        Forecast *currentForecast;
        NSLog(@"items in array now: %lu", (unsigned long)[items_ count]);
        //Setting up UI for today
        if ([items_ count] > 0)
        {
            currentForecast = [items_ objectAtIndex:0];
    
            //self.todayDay.text = todayForecast.day;
            self.todayDate.text = [NSString stringWithFormat:@"%@, %@", currentForecast.day, currentForecast.date];
            self.todayLow.text = [NSString stringWithFormat:@"+%@", currentForecast.low];
            self.todayHigh.text = [NSString stringWithFormat:@"+%@", currentForecast.high];
            self.todayText.text = currentForecast.text;
            
            NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@.gif", BaseImageURLString, currentForecast.code]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            [self.todayImage setImageWithURLRequest:request
                                   placeholderImage:placeholderImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
                                                self.todayImage.image = image;
                                                [self.todayImage setNeedsLayout];
            
                                            } failure:nil];
        }
        else //if we don't have any forecast for today
        {
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEE, dd MMM y"];
            self.todayDate.text = [formatter stringFromDate:date];
        }
        
        //Setting up UI for tomorrow
        if([items_ count] > 1)
        {
            currentForecast = [items_ objectAtIndex:1];
    
            self.tomorrowDate.text = [NSString stringWithFormat:@"%@, %@", currentForecast.day, currentForecast.date];
            self.tommorowLow.text = [NSString stringWithFormat:@"+%@", currentForecast.low];
            self.tommorowHigh.text = [NSString stringWithFormat:@"+%@", currentForecast.high];
            self.tomorrowText.text = currentForecast.text;
            
            NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@.gif", BaseImageURLString, currentForecast.code]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
            [self.tomorrowImage setImageWithURLRequest:request
                                   placeholderImage:placeholderImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                
                                                self.tomorrowImage.image = image;
                                                [self.tomorrowImage setNeedsLayout];
                                                
                                            } failure:nil];

        }
        else //if we don't have any forecast for tomorrow
        {
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:86400];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEE, dd MMM y"];
            self.tomorrowDate.text = [formatter stringFromDate:date];
        }
    }
}

#pragma mark - xml delegate override
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    YWAppDelegate *appDelegate = (YWAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id forecast in result)
        [context deleteObject:forecast];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't clear db: %@", [error localizedDescription]);
    }

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"%@", elementName);
    if ([elementName isEqualToString:@"location"])
    {
        self.cityLabel.text = [attributeDict valueForKey:@"city"];
    }
    if([elementName isEqualToString:@"forecast"])
    {
        YWAppDelegate *appDelegate = (YWAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        NSManagedObject *forecast = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"Forecast"
                                     inManagedObjectContext:context];
        [forecast setValue:[attributeDict valueForKey:@"day"] forKey:@"day"];
        [forecast setValue:[attributeDict valueForKey:@"date"] forKey:@"date"];
        [forecast setValue:[attributeDict valueForKey:@"low"] forKey:@"low"];
        [forecast setValue:[attributeDict valueForKey:@"high"] forKey:@"high"];
        [forecast setValue:[attributeDict valueForKey:@"text"] forKey:@"text"];
        [forecast setValue:[attributeDict valueForKey:@"code"] forKey:@"code"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM y hh:mm"];
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@, %@ 04:00", [attributeDict valueForKey:@"day"],[attributeDict valueForKey:@"date"]]];
        NSLog(@"Date: %@", [date description]);
        [forecast setValue:date forKey:@"formattedDate"];
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    [items_ removeLastObject];
    [self loadData];
    [self configureUI];
}
@end
