import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get welcomeBack;
  String get lblRide;
  String get signInYourAccount;

  String get thisFieldRequired;

  String get email;

  String get password;

  String get forgotPassword;

  String get logIn;

  String get orLogInWith;

  String get donHaveAnAccount;

  String get createProfile;

  String get createAccount;

  String get createYourAccountToContinue;

  String get firstName;

  String get lastName;

  String get userName;

  String get phoneNumber;

  String get alreadyHaveAnAccount;

  String get contactUs;

  String get purchase;

  String get changePassword;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordDoesNotMatch;

  String get passwordInvalid;

  String get yes;

  String get no;

  String get writeMessage;

  String get enterTheEmailAssociatedWithYourAccount;

  String get submit;

  String get language;

  String get notification;

  String get otpVeriFiCation;

  String get weHaveSentDigitCode;

  String get contactLength;

  String get about;

  String get useInCaseOfEmergency;

  String get notifyAdmin;

  String get notifiedSuccessfully;

  String get complain;

  String get pleaseEnterSubject;

  String get writeDescription;

  String get saveComplain;

  String get editProfile;

  String get gender;

  String get address;

  String get updateProfile;

  String get notChangeUsername;

  String get notChangeEmail;

  String get profileUpdateMsg;

  String get emergencyContact;

  String get areYouSureYouWantDeleteThisNumber;

  String get addContact;

  String get googleMap;

  String get save;

  String get myRides;

  String get myWallet;

  String get availableBalance;

  String get recentTransactions;

  String get moneyDeposited;

  String get addMoney;

  String get cancel;

  String get pleaseSelectAmount;

  String get amount;

  String get capacity;

  String get paymentMethod;

  String get chooseYouPaymentLate;

  String get enterPromoCode;

  String get confirm;

  String get forInstantPayment;

  String get bookNow;

  String get wallet;

  String get paymentDetail;

  String get rideId;

  String get createdAt;

  String get viewHistory;

  String get paymentDetails;

  String get paymentType;

  String get paymentStatus;

  String get priceDetail;

  String get basePrice;

  String get distancePrice;

  String get timePrice;

  String get waitTime;

  String get extraCharges;

  String get couponDiscount;

  String get total;

  String get payment;

  String get cash;

  String get updatePaymentStatus;

  String get waitingForDriverConformation;

  String get continueNewRide;

  String get payToPayment;

  String get tip;

  String get pay;

  String get howWasYourRide;

  String get wouldYouLikeToAddTip;

  String get addMoreTip;

  String get addMore;

  String get addReviews;

  String get writeYourComments;

  String get continueD;

  String get detailScreen;

  String get aboutDriver;

  String get rideHistory;

  String get myProfile;

  String get myTrips;

  String get emergencyContacts;

  String get logOut;

  String get areYouSureYouWantToLogoutThisApp;

  String get whatWouldYouLikeToGo;

  String get enterYourDestination;

  String get currentLocation;

  String get destinationLocation;

  String get chooseOnMap;

  String get profile;

  String get theme;

  String get privacyPolicy;

  String get helpSupport;

  String get termsConditions;

  String get aboutUs;

  String get lookingForNearbyDrivers;

  String get weAreLookingForNearDriversAcceptsYourRide;

  String get areYouSureYouWantToCancelThisRide;

  String get serviceDetail;

  String get get;

  String get rides;

  String get people;

  String get fare;

  String get done;

  String get availableOffers;

  String get off;

  String get sendOTP;

  String get otpVerification;

  String get enterTheCodeSendTo;

  String get didNotReceiveTheCode;

  String get resend;

  String get carModel;

  String get sos;

  String get driverReview;

  String get signInUsingYourMobileNumber;

  String get otp;

  String get newRideRequested;

  String get accepted;

  String get arriving;

  String get arrived;

  String get inProgress;

  String get cancelled;

  String get completed;

  String get pleaseEnableLocationPermission;

  String get pending;

  String get failed;

  String get paid;

  String get male;

  String get female;

  String get other;

  String get addExtraCharges;

  String get enterAmount;

  String get pleaseAddedAmount;

  String get title;

  String get charges;

  String get saveCharges;

  String get mailTo;

  String get bankDetail;

  String get bankName;

  String get bankCode;

  String get accountHolderName;

  String get accountNumber;

  String get updateBankDetail;

  String get addBankDetail;

  String get bankInfoUpdateSuccessfully;

  String get vehicleDetail;

  String get verifyDocument;

  String get setting;

  String get youAreOnlineNow;

  String get youAreOfflineNow;

  String get requests;

  String get areYouSureYouWantToCancelThisRequest;

  String get decline;

  String get accept;

  String get areYouSureYouWantToAcceptThisRequest;

  String get call;

  String get chat;

  String get applyExtraFree;

  String get areYouSureYouWantToArriving;

  String get areYouSureYouWantToArrived;

  String get enterOtp;

  String get enterTheOtpDisplayInCustomersMobileToStartTheRide;

  String get pleaseEnterValidOtp;

  String get areYouSureYouWantToCompletedThisRide;

  String get updateBankInfo;

  String get regisTRation;

  String get pleaseSelectService;

  String get userDetail;

  String get selectService;

  String get selectGender;

  String get carColor;

  String get carPlateNumber;

  String get carProductionYear;

  String get withDraw;

  String get withdrawHistory;

  String get approved;

  String get requested;

  String get updateVehicle;

  String get userNotApproveMsg;

  String get uploadFileConfirmationMsg;

  String get selectDocument;

  String get addDocument;

  String get areYouSureYouWantToDeleteThisDocument;

  String get expireDate;

  String get goDashBoard;

  String get deleteAccount;

  String get account;

  String get areYouSureYouWantPleaseReadAffect;

  String get deletingAccountEmail;

  String get areYouSureYouWantDeleteAccount;

  String get yourInternetIsNotWorking;

  String get allow;

  String get mostReliableeshhunDriverApp;

  String get toEnjoyYourRideExperiencePleaseAllowPermissions;

  String get cashCollected;

  String get areYouSureCollectThisPayment;

  String get txtURLEmpty;

  String get lblFollowUs;

  String get bankInfo;

  String get duration;

  String get paymentVia;

  String get moneyDebit;

  String get vehicleInfo;

  String get demoMsg;

  String get youCannotChangePhoneNumber;

  String get offLine;

  String get online;

  String get walletLessAmountMsg;

  String get aboutRider;

  String get pleaseEnterMessage;

  String get complainList;

  String get viewAll;

  String get pleaseSelectRating;

  String get serviceInfo;

  String get youCannotChangeService;

  String get vehicleInfoUpdateSucessfully;

  String get subscription;

  String get yourCurrentBalanceIs;

  String get yourSubscriptionPlanIsOver;

  String get perDay;

  String get renew;

  String get yourWalletDoNotHaveEnoughBalance;

  String get addWallet;

  String get yourDailyAppUseLimitHasBeenExpired;

  String get recharge;

  String get isMandatoryDocument;

  String get someRequiredDocumentAreNotUploaded;

  String get areYouCertainOffline;

  String get areYouCertainOnline;

  String get pleaseAcceptTermsOfServicePrivacyPolicy;

  String get rememberMe;

  String get agreeToThe;

  String get invoice;

  String get riderInformation;

  String get customerName;

  String get sourceLocation;

  String get invoiceNo;

  String get invoiceDate;

  String get orderedDate;

  String get totalCash;

  String get totalRide;

  String get totalWallet;

  String get totalEarning;

  String get pleaseSelectFromDateAndToDate;

  String get from;

  String get fromDate;

  String get to;

  String get toDate;

  String get ride;

  String get todayRide;

  String get weeklyOrderCount;

  String get distance;

  String get rideInformation;

  String get iAgreeToThe;

  String get today;

  String get weekly;

  String get report;

  String get earning;

  String get todayEarning;

  String get available;

  String get notAvailable;

  String get youWillReceiveNewRidersAndNotifications;

  String get youWillNotReceiveNewRidersAndNotifications;

  String get yourAccountIs;

  String get pleaseContactSystemAdministrator;

  String get youCanNotThisActionsPerformBecauseYourCurrentRideIsNotCompleted;



  String get mostReliableeshhunRiderApp;



  String get findPlace;

  String get pleaseWait;

  String get selectPlace;

  String get placeNotInArea;



  String get writeMsg;

  String get pleaseEnterMsg;





  String get driverInformation;

  String get service;

  String get nameFieldIsRequired;

  String get phoneNumberIsRequired;

  String get enterName;

  String get enterContactNumber;

  String get bookingRideForOthers;




  String get lblCarNumberPlate;

  String get lblCouponCode;



  String get lblRideInformation;

  String get lblWhereAreYou;

  String get lblDropOff;

  String get lblDistance;

  String get lblWhoRiding;

  String get lblSomeoneElse;

  String get lblYou;

  String get lblWhoRidingMsg;

  String get lblNext;

  String get lblLessWalletAmount;

  String get lblPayWhenEnds;



}
