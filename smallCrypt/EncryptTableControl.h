//
//  EncryptTableControl.h
//  smallCrypt
//
//  Created by Arnaud Crowther on 11/15/13.
//  Copyright (c) 2013 Arnaud Crowther. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface EncryptTableControl : UITableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate>
{
    NSString *globalWord;
    NSTimer *aTimer;
    IBOutlet UITextField *txtMessage;
    IBOutlet UITextField *txtCipher;
    IBOutlet UITextView *textView;
    //rings
    IBOutlet UIImageView *gRingWord;
    IBOutlet UIImageView *gRingKey;
    IBOutlet UIImageView *rRingWord;
    IBOutlet UIImageView *rRingKey;
    //buttons
    IBOutlet UIButton *dowork;
    IBOutlet UIButton *dosend;
    IBOutlet UIButton *docopy;
    IBOutlet UIBarButtonItem *qrBut;
    IBOutlet UIButton *smallXbutton;
}

- (IBAction)crunch:(id)sender;
- (IBAction)mail:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)qrButton:(id)sender;
- (IBAction)clearTextView:(id)sender;


@end
