/*
* PubMatic Inc. ("PubMatic") CONFIDENTIAL
* Unpublished Copyright (c) 2006-2025 PubMatic, All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
* herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
* Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
* from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
* Confidentiality and Non-disclosure agreements explicitly covering such access or to such other persons whom are directly authorized by PubMatic to access the source code and are subject to confidentiality and nondisclosure obligations with respect to the source code.
*
* The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
* information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
* OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
* LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
* TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
*/


#import "CustomNativeAdView.h"

@interface CustomNativeAdView ()
/// The custom native ad that populated this view.
@property(nonatomic) GADCustomNativeAd *customNativeAd;
@end

@implementation CustomNativeAdView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Enable clicks on the title.
    [self.titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(performClickOnTitle)]];
    self.titleLabel.userInteractionEnabled = YES;
    
    // Enable clicks on the icon.
    [self.iconView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(performClickOnIcon)]];
    self.iconView.userInteractionEnabled = YES;
    
    // Enable clicks on the main image.
    [self.mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(performClickOnMainImage)]];
    self.mainImageView.userInteractionEnabled = YES;
}

- (void)performClickOnTitle {
    [self.customNativeAd performClickOnAssetWithKey:@"Title"];
}

- (void)performClickOnIcon {
    [self.customNativeAd performClickOnAssetWithKey:@"Icon"];
}

- (void)performClickOnMainImage {
    [self.customNativeAd performClickOnAssetWithKey:@"MainImage"];
}

- (IBAction)performClickOnClickThroughText:(id)sender {
    [self.customNativeAd performClickOnAssetWithKey:@"ClickThroughText"];
}

- (void)populateCustomNativeAdView:(GADCustomNativeAd *)customNativeAd {
    self.customNativeAd = customNativeAd;
    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    self.titleLabel.text = [customNativeAd stringForKey:@"Title"];
        
    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    NSString *description = [customNativeAd stringForKey:@"description"];
    self.descriptionLabel.text = description;
    self.descriptionLabel.hidden = description.length ? NO : YES;

    NSString *clickThroughText = [customNativeAd stringForKey:@"ClickThroughText"];
    [self.clickThroughButton setTitle:clickThroughText
                                 forState:UIControlStateNormal];
    self.clickThroughButton.hidden = clickThroughText.length ? NO : YES;

    UIImage *iconImg = [customNativeAd imageForKey:@"Icon"].image;
    self.iconView.image = iconImg;
    self.iconView.hidden = iconImg ? NO : YES;
    
    UIImage *mainImg = [customNativeAd imageForKey:@"MainImage"].image;
    self.mainImageView.image = mainImg;
    self.mainImageView.hidden = mainImg ? NO : YES;
}

@end
