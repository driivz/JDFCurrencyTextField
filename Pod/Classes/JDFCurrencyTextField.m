//
//  JDFCurrencyTextField.m
//  LivePokerManager2012
//
//  Created by Joe Fryer on 19/01/2014.
//  Copyright (c) 2014 JoeFryer. All rights reserved.
//

#import "JDFCurrencyTextField.h"



@interface JDFCurrencyTextField ()

// Formatter
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;

@end



@implementation JDFCurrencyTextField

@synthesize locale = _locale;

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self formatTextAfterEditing];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    if (keyboardType == UIKeyboardTypeDecimalPad || keyboardType == UIKeyboardTypeNumbersAndPunctuation) {
        [super setKeyboardType:keyboardType];
    }
}

- (void)setLocale:(NSLocale *)locale
{
    _locale = locale;
    self.currencyFormatter.locale = locale;
}

- (void)setDecimalValue:(NSDecimalNumber *)decimalValue
{
    self.text = [self.decimalFormatter stringFromNumber:decimalValue];
    [self formatTextAfterEditing];
}


#pragma mark - Getters

- (NSLocale *)locale
{
    if (!_locale) {
        _locale = [NSLocale currentLocale];
    }
    return _locale;
}

- (NSNumberFormatter *)currencyFormatter
{
    if (!_currencyFormatter) {
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setLocale:self.locale];
    }
    return _currencyFormatter;
}

- (NSNumberFormatter *)decimalFormatter
{
    if (!_decimalFormatter) {
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        [_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_decimalFormatter setLocale:self.locale];
        _decimalFormatter.usesGroupingSeparator = NO;
    }
    return _decimalFormatter;
}

- (NSDecimalNumber *)decimalValue
{
    NSNumberFormatter *numberFormatter;
    if (self.editing) {
        numberFormatter = self.decimalFormatter;
    } else {
        numberFormatter = self.currencyFormatter;
    }
    return [NSDecimalNumber decimalNumberWithDecimal:[[numberFormatter numberFromString:self.text] decimalValue]];
}


#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(formatTextInPreparationForEditing)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(formatTextAfterEditing)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:self];

    self.keyboardType = UIKeyboardTypeDecimalPad;
    [self formatTextAfterEditing];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:self];
}


#pragma mark - Internal

- (void)formatTextInPreparationForEditing
{
    NSString *currentString = self.text;
    if (!(currentString.length > 0)) {
        return;
    }
    
    NSNumber *number = [self.currencyFormatter numberFromString:currentString];
    if (number.doubleValue == 0) {
        super.text = @"";
    } else {
        super.text = [self.decimalFormatter stringFromNumber:number];
    }
}

- (void)formatTextAfterEditing
{
    NSString *currentString = self.text;
    
    NSNumber *number = [self.decimalFormatter numberFromString:currentString];
    if (!number) {
        number = [self.currencyFormatter numberFromString:currentString];
    }
    if (!number || currentString.length == 0) {
        number = @0;
    }
    
    super.text = [self.currencyFormatter stringFromNumber:number];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultantString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([string isEqualToString:self.currencyFormatter.minusSign]) {
        if ([string isEqualToString:resultantString]) {
            return YES;
        }
        NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[self.decimalFormatter numberFromString:textField.text] decimalValue]];
        decimalNumber = [decimalNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInteger: -1]];
        [super setText:[self.decimalFormatter stringFromNumber:decimalNumber]];
        return NO;
    } else {
        if ([resultantString isEqualToString:self.currencyFormatter.minusSign]) {
            return YES;
        }
        NSNumber *number = [self.decimalFormatter numberFromString:resultantString];
        return (number ? YES : NO) || resultantString.length == 0;
    }
}

@end
