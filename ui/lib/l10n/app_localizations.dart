import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @languageAndTheme.
  ///
  /// In en, this message translates to:
  /// **'Language & Theme'**
  String get languageAndTheme;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Event Manager'**
  String get appTitle;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @pleaseEnterOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your old password'**
  String get pleaseEnterOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmPassword;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @newPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordMismatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get changePasswordSuccess;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @newEventNotifications.
  ///
  /// In en, this message translates to:
  /// **'New Events'**
  String get newEventNotifications;

  /// No description provided for @newEventNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when new events are created'**
  String get newEventNotificationsSubtitle;

  /// No description provided for @eventReminders.
  ///
  /// In en, this message translates to:
  /// **'Event Reminders'**
  String get eventReminders;

  /// No description provided for @eventRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive reminders before an event starts'**
  String get eventRemindersSubtitle;

  /// No description provided for @systemUpdates.
  ///
  /// In en, this message translates to:
  /// **'System Updates'**
  String get systemUpdates;

  /// No description provided for @systemUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about maintenance or important changes'**
  String get systemUpdatesSubtitle;

  /// No description provided for @systemAdministrator.
  ///
  /// In en, this message translates to:
  /// **'System Administrator'**
  String get systemAdministrator;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @pleaseLoginToUseFeatures.
  ///
  /// In en, this message translates to:
  /// **'Please log in to use all features'**
  String get pleaseLoginToUseFeatures;

  /// No description provided for @loginOrRegister.
  ///
  /// In en, this message translates to:
  /// **'Login or Register'**
  String get loginOrRegister;

  /// No description provided for @couldNotOpenSupportPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open support page'**
  String get couldNotOpenSupportPage;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @internalEventManager.
  ///
  /// In en, this message translates to:
  /// **'Internal Event Management Application'**
  String get internalEventManager;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginToManageEvents.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your events'**
  String get loginToManageEvents;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @participationPerformance.
  ///
  /// In en, this message translates to:
  /// **'Participation Performance'**
  String get participationPerformance;

  /// No description provided for @highlightEvents.
  ///
  /// In en, this message translates to:
  /// **'Highlight Events'**
  String get highlightEvents;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @preRegistered.
  ///
  /// In en, this message translates to:
  /// **'Pre-registered'**
  String get preRegistered;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @generalAdmission.
  ///
  /// In en, this message translates to:
  /// **'General Admission'**
  String get generalAdmission;

  /// No description provided for @attended.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get attended;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @guestWithCount.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestWithCount;

  /// No description provided for @searchGuests.
  ///
  /// In en, this message translates to:
  /// **'Search guests...'**
  String get searchGuests;

  /// No description provided for @showingGuestsInLast365Days.
  ///
  /// In en, this message translates to:
  /// **'Showing guests from the last 365 days'**
  String get showingGuestsInLast365Days;

  /// No description provided for @reportsAndStatistics.
  ///
  /// In en, this message translates to:
  /// **'📊 Reports & Statistics'**
  String get reportsAndStatistics;

  /// No description provided for @eventOverview.
  ///
  /// In en, this message translates to:
  /// **'Event Overview'**
  String get eventOverview;

  /// No description provided for @totalEvents.
  ///
  /// In en, this message translates to:
  /// **'Total Events'**
  String get totalEvents;

  /// No description provided for @attendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get attendees;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @eventStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Event Status Distribution'**
  String get eventStatusDistribution;

  /// No description provided for @monthlyEventCount.
  ///
  /// In en, this message translates to:
  /// **'Monthly Event Count'**
  String get monthlyEventCount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName} 👋'**
  String helloUser(Object userName);

  /// No description provided for @todayIs.
  ///
  /// In en, this message translates to:
  /// **'Today: {date}'**
  String todayIs(Object date);

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @addGuest.
  ///
  /// In en, this message translates to:
  /// **'Add Guest'**
  String get addGuest;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @noUpcomingEventsIn7Days.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events in the next 7 days.'**
  String get noUpcomingEventsIn7Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Failed to load data: {error}'**
  String loadingError(Object error);

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No matching events.'**
  String get noEvents;

  /// No description provided for @showingEvents365.
  ///
  /// In en, this message translates to:
  /// **'Showing events in the last 365 days'**
  String get showingEvents365;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'🗑️ Event deleted'**
  String get eventDeleted;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'❌ Delete error: {error}'**
  String deleteError(Object error);

  /// No description provided for @eventListTitle.
  ///
  /// In en, this message translates to:
  /// **'Event List'**
  String get eventListTitle;

  /// No description provided for @createEventSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event created successfully!'**
  String get createEventSuccess;

  /// No description provided for @remainingDays.
  ///
  /// In en, this message translates to:
  /// **'{d}d remaining'**
  String remainingDays(Object d);

  /// No description provided for @remainingHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h remaining'**
  String remainingHours(Object h);

  /// No description provided for @remainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m remaining'**
  String remainingMinutes(Object m);

  /// No description provided for @remainingSeconds.
  ///
  /// In en, this message translates to:
  /// **'{s}s remaining'**
  String remainingSeconds(Object s);

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {formattedDate}'**
  String completedOn(Object formattedDate);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @checkInfo.
  ///
  /// In en, this message translates to:
  /// **'Please check your information again'**
  String get checkInfo;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully!'**
  String get updateSuccess;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error: {error}'**
  String updateError(Object error);

  /// No description provided for @eventInfo.
  ///
  /// In en, this message translates to:
  /// **'Event Information'**
  String get eventInfo;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventName;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Event Location'**
  String get eventLocation;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @changeStartTime.
  ///
  /// In en, this message translates to:
  /// **'Change start time'**
  String get changeStartTime;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @changeEndTime.
  ///
  /// In en, this message translates to:
  /// **'Change end time'**
  String get changeEndTime;

  /// No description provided for @currentImages.
  ///
  /// In en, this message translates to:
  /// **'Current Images'**
  String get currentImages;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'This event has no images yet.'**
  String get noImages;

  /// No description provided for @updateEvent.
  ///
  /// In en, this message translates to:
  /// **'Update Event'**
  String get updateEvent;

  /// No description provided for @couldNotLoadEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load event details.'**
  String get couldNotLoadEventDetails;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescription;

  /// No description provided for @noEventName.
  ///
  /// In en, this message translates to:
  /// **'No event name'**
  String get noEventName;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownStatus;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Time not specified'**
  String get unknownTime;

  /// No description provided for @sameDayTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{startTime} - {endTime}'**
  String sameDayTimeFormat(Object startTime, Object endTime);

  /// No description provided for @differentDayFormat.
  ///
  /// In en, this message translates to:
  /// **'{startDate} - {endDate}'**
  String differentDayFormat(Object startDate, Object endDate);

  /// No description provided for @fullDayFormat.
  ///
  /// In en, this message translates to:
  /// **'EEEE, dd/MM/yyyy'**
  String get fullDayFormat;

  /// No description provided for @attendanceStats.
  ///
  /// In en, this message translates to:
  /// **'📈 Attendance Statistics'**
  String get attendanceStats;

  /// No description provided for @registeredUsers.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredUsers;

  /// No description provided for @checkedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked-in'**
  String get checkedIn;

  /// No description provided for @absentees.
  ///
  /// In en, this message translates to:
  /// **'Absentees'**
  String get absentees;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'📍 Venue'**
  String get venue;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get addressCopied;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenMaps;

  /// No description provided for @noSpecificLocation.
  ///
  /// In en, this message translates to:
  /// **'No specific location provided'**
  String get noSpecificLocation;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'🧾 Event Description'**
  String get eventDescription;

  /// No description provided for @defaultEventDescription.
  ///
  /// In en, this message translates to:
  /// **'This event is for networking, sharing, and connecting the community.'**
  String get defaultEventDescription;

  /// No description provided for @eventImages.
  ///
  /// In en, this message translates to:
  /// **'📸 Event Images'**
  String get eventImages;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'⭐ Reviews & Ratings'**
  String get reviewsAndRatings;

  /// No description provided for @xReviews.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String xReviews(Object count);

  /// No description provided for @showMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'Show more reviews...'**
  String get showMoreReviews;

  /// No description provided for @writeYourReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review:'**
  String get writeYourReview;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about the event...'**
  String get shareYourThoughts;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'🎭 Event Type'**
  String get eventType;

  /// No description provided for @eventTypeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Event'**
  String get eventTypeOpen;

  /// No description provided for @eventTypeLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited Event'**
  String get eventTypeLimited;

  /// No description provided for @eventTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private Event'**
  String get eventTypePrivate;

  /// No description provided for @maxGuests.
  ///
  /// In en, this message translates to:
  /// **'Maximum Guests'**
  String get maxGuests;

  /// No description provided for @minGuestsWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Must have at least 2 guests.'**
  String get minGuestsWarning;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed Event Description'**
  String get detailedDescription;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the event description'**
  String get pleaseEnterDescription;

  /// No description provided for @guestDistributionByEventType.
  ///
  /// In en, this message translates to:
  /// **'Guest Distribution by Event Type'**
  String get guestDistributionByEventType;

  /// No description provided for @guestContactRequired.
  ///
  /// In en, this message translates to:
  /// **'Guest contact information is required (email or phone).'**
  String get guestContactRequired;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events available to add guests to.'**
  String get noUpcomingEvents;

  /// No description provided for @guestEventRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an event for the guest.'**
  String get guestEventRequired;

  /// No description provided for @guestCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Guest created successfully!'**
  String get guestCreateSuccess;

  /// No description provided for @guestCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating guest: {error}'**
  String guestCreateError(Object error);

  /// No description provided for @addGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Guest'**
  String get addGuestTitle;

  /// No description provided for @noGuestsFound.
  ///
  /// In en, this message translates to:
  /// **'No guests found.'**
  String get noGuestsFound;

  /// No description provided for @guestFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get guestFullNameLabel;

  /// No description provided for @guestNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Guest name is required.'**
  String get guestNameRequired;

  /// No description provided for @guestEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get guestEmailLabel;

  /// No description provided for @guestPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get guestPhoneLabel;

  /// No description provided for @guestEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get guestEventLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noGuestContact.
  ///
  /// In en, this message translates to:
  /// **'No contact info'**
  String get noGuestContact;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @filterGuests.
  ///
  /// In en, this message translates to:
  /// **'Filter guests'**
  String get filterGuests;

  /// No description provided for @refineGuestList.
  ///
  /// In en, this message translates to:
  /// **'Refine your guest list'**
  String get refineGuestList;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Hãy thử thay đổi bộ lọc để xem thêm kết quả'**
  String get tryAdjustingFilters;

  /// No description provided for @eventListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View, manage, and organize your upcoming events easily.'**
  String get eventListSubtitle;

  /// No description provided for @eventListOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Viewing cached events list only.'**
  String get eventListOfflineSubtitle;

  /// No description provided for @guestListOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing cached guests list only.'**
  String get guestListOfflineSubtitle;

  /// No description provided for @reportOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and analyze your event performance.'**
  String get reportOverviewSubtitle;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing cached data; editing is disabled.'**
  String get offlineBanner;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found.'**
  String get noEventsFound;

  /// No description provided for @performanceTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Xem và phân tích sự thay đổi trong hiệu suất sự kiện'**
  String get performanceTrendSubtitle;

  /// No description provided for @monthlyEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and analyze your event per monthly.'**
  String get monthlyEventSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
