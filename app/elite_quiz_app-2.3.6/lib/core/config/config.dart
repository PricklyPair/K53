import 'package:flutter/material.dart';
import 'package:flutterquiz/features/wallet/models/payout_method.dart';
import 'package:google_fonts/google_fonts.dart';

export 'colors.dart';

/// === Config ===
const appName = 'Elite Quiz';
const packageName = 'com.wrteam.flutterquiz';

/// Add your panel url here
// NOTE: make sure to not add '/' at the end of url
// NOTE: make sure to check if admin panel is http or https
const panelUrl = 'https://elitequiz.wrteam.me';

/// === Branding ===
///

/// Default App Theme : light or dark
const Brightness defaultTheme = Brightness.light;

// Phone Login, default country code AND max length of phone number allowed
const defaultCountryCodeForPhoneLogin = 'IN';
const maxPhoneNumberLength = 16;

final TextStyle kFonts = GoogleFonts.nunito();
final TextTheme kTextTheme = GoogleFonts.nunitoTextTheme();

/// === Assets ===

// if you want to change the logo format like png, jpg, etc.
const kAppLogo = 'app_logo.svg';
const kSplashLogo = 'splash_logo.svg';
const kOrgLogo = 'org_logo.svg';
const kPlaceholder = 'placeholder.png';
// make it false, if you don't want to show org logo in the splash screen
const kShowOrgLogo = true;

// Sounds
const kSoundClickEvent = 'click.mp3';
const kSoundRightAnswer = 'right.mp3';
const kSoundWrongAnswer = 'wrong.mp3';

// Predefined messages for 1v1 and group battle
const predefinedMessages = [
  'Hello..!!',
  'How are you..?',
  'Fine..!!',
  'Have a nice day..',
  'Well played',
  'What a performance..!!',
  'Thanks..',
  'Welcome..',
  'Merry Christmas',
  'Happy new year',
  'Happy Diwali',
  'Good night',
  'Hurry Up',
  'Dudeeee',
];

// Exam Rules are shown before starting any exam
const examRules = [
  'I will not copy and give this exam with honesty',
  'If you lock your phone then exam will complete automatically',
  "If you minimize application or open other application and don't come back to application with in 5 seconds then exam will complete automatically",
  'Screen recording is prohibited',
  'In Android screenshot capturing is prohibited',
  'In ios, if you take screenshot then rules will violate and it will inform to examiner',
];

// Wallet - shown in wallet screen, before redeeming coins
List<String> payoutRequestNote(
  String payoutRequestCurrency,
  String amount,
  String coins,
) {
  /// Change this texts as per your requirement
  return [
    'Minimum Redeemable amount is $payoutRequestCurrency $amount ($coins Coins).',
    'Payout will take 3 - 5 working days',
  ];
}

/// Wallet - Payout Methods for redeeming coins. you can add any Payment method you want,
/// like, Paypal, UPI, Bank Transfer, Crypto, Paytm, etc.
const _paymentPath = 'assets/config/payment_methods';
const payoutMethods = [
  //Paypal
  PayoutMethod(
    image: '$_paymentPath/paypal.svg',
    type: 'Paypal',
    inputs: [
      (
        name: 'Enter paypal id', // Name for the field
        isNumber: false, // If input is number or not
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  //Paytm
  PayoutMethod(
    image: '$_paymentPath/paytm.svg',
    type: 'Paytm',
    inputs: [(name: 'Enter mobile number', isNumber: true, maxLength: 10)],
  ),

  //UPI
  PayoutMethod(
    image: '$_paymentPath/upi.svg',
    type: 'UPI',
    inputs: [
      (
        name: 'Enter UPI id',
        isNumber: false,
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  /// Example: Bank Transfer
  // PayoutMethod(
  //   inputs: [
  //     (
  //       name: 'Enter Bank Name',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //     (
  //       name: 'Enter Account Number',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //     (
  //       name: 'Enter IFSC Code',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //   ],
  //   image: '$_paymentImgsPath/paytm.svg',
  //   type: 'Bank Transfer',
  // ),
];
