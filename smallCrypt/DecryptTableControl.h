//
//  DecryptTableControl.h
//  smallCrypt
//
//  Created by Arnaud Crowther on 11/15/13.
//  Copyright (c) 2013 Arnaud Crowther. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecryptTableControl : UITableViewController<UIAlertViewDelegate, UITextViewDelegate>
{
    IBOutlet UITextField *txtMessage;
    IBOutlet UITextField *txtCipher;
    IBOutlet UITextView *textView;
    NSString *globalWord;
    NSTimer *aTimer;
    //text fields
    //IBOutlet UITextField *inWord;
    //IBOutlet UITextField *inKey;
    //IBOutlet UITextView *textViewD;
    //rings
    IBOutlet UIImageView *gRingWord;
    IBOutlet UIImageView *gRingKey;
    IBOutlet UIImageView *rRingWord;
    IBOutlet UIImageView *rRingKey;
    //buttons
    IBOutlet UIButton *dowork;
    IBOutlet UIButton *doclear;
    IBOutlet UIButton *smallX;
}

- (IBAction)crunch:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)clearTextView:(id)sender;

@end