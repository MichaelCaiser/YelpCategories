//
//  CollectionViewController.h
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"
#import <CoreLocation/CoreLocation.h>
@interface CategoryViewController : UICollectionViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    
    
}
-(void) RunSearch;
extern NSMutableDictionary *searchOptions;

@end
