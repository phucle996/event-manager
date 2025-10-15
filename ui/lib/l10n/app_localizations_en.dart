// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get profile => 'Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get languageAndTheme => 'Language & Theme';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get aboutApp => 'About App';

  @override
  String get logout => 'Logout';

  @override
  String get appTitle => '🎉 Event Manager';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get pleaseEnterOldPassword => 'Please enter your old password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your new password';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get newPasswordMismatch => 'New passwords do not match';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get error => 'Error';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get newEventNotifications => 'New Events';

  @override
  String get newEventNotificationsSubtitle =>
      'Receive notifications when new events are created';

  @override
  String get eventReminders => 'Event Reminders';

  @override
  String get eventRemindersSubtitle =>
      'Receive reminders before an event starts';

  @override
  String get systemUpdates => 'System Updates';

  @override
  String get systemUpdatesSubtitle =>
      'Receive notifications about maintenance or important changes';

  @override
  String get systemAdministrator => 'System Administrator';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get department => 'Department';

  @override
  String get joinDate => 'Join Date';

  @override
  String get account => 'Account';

  @override
  String get other => 'Other';

  @override
  String get guest => 'Guest';

  @override
  String get pleaseLoginToUseFeatures => 'Please log in to use all features';

  @override
  String get loginOrRegister => 'Login or Register';

  @override
  String get couldNotOpenSupportPage => 'Could not open support page';

  @override
  String get loggedOutSuccessfully => 'Logged out successfully';

  @override
  String get internalEventManager => 'Internal Event Management Application';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get loginToManageEvents => 'Log in to manage your events';

  @override
  String get username => 'Username';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get overview => 'Overview';

  @override
  String get participationPerformance => 'Participation Performance';

  @override
  String get highlightEvents => 'Highlight Events';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get preRegistered => 'Pre-registered';

  @override
  String get registered => 'Registered';

  @override
  String get generalAdmission => 'General Admission';

  @override
  String get attended => 'Attended';

  @override
  String get absent => 'Absent';

  @override
  String get guestWithCount => 'Guest';

  @override
  String get searchGuests => 'Search guests...';

  @override
  String get showingGuestsInLast365Days =>
      'Showing guests from the last 365 days';

  @override
  String get reportsAndStatistics => '📊 Reports & Statistics';

  @override
  String get eventOverview => 'Event Overview';

  @override
  String get totalEvents => 'Total Events';

  @override
  String get attendees => 'Attendees';

  @override
  String get completed => 'Completed';

  @override
  String get eventStatusDistribution => 'Event Status Distribution';

  @override
  String get monthlyEventCount => 'Monthly Event Count';

  @override
  String get home => 'Home';

  @override
  String get guests => 'Guests';

  @override
  String get reports => 'Reports';

  @override
  String helloUser(Object userName) {
    return 'Hello, $userName 👋';
  }

  @override
  String todayIs(Object date) {
    return 'Today: $date';
  }

  @override
  String get events => 'Events';

  @override
  String get addGuest => 'Add Guest';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get noUpcomingEventsIn7Days =>
      'No upcoming events in the next 7 days.';

  @override
  String get allTime => 'All time';

  @override
  String get createEvent => 'Create Event';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisYear => 'This year';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String loadingError(Object error) {
    return '⚠️ Failed to load data: $error';
  }

  @override
  String get noEvents => 'No matching events.';

  @override
  String get showingEvents365 => 'Showing events in the last 365 days';

  @override
  String get eventDeleted => '🗑️ Event deleted';

  @override
  String deleteError(Object error) {
    return '❌ Delete error: $error';
  }

  @override
  String get eventListTitle => '📅 Event List';

  @override
  String get createEventSuccess => 'Event created successfully!';

  @override
  String remainingDays(Object d) {
    return '${d}d remaining';
  }

  @override
  String remainingHours(Object h) {
    return '${h}h remaining';
  }

  @override
  String remainingMinutes(Object m) {
    return '${m}m remaining';
  }

  @override
  String remainingSeconds(Object s) {
    return '${s}s remaining';
  }

  @override
  String completedOn(Object formattedDate) {
    return 'Completed on $formattedDate';
  }

  @override
  String get delete => 'Delete';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get checkInfo => 'Please check your information again';

  @override
  String get updateSuccess => 'Event updated successfully!';

  @override
  String updateError(Object error) {
    return 'Update error: $error';
  }

  @override
  String get eventInfo => 'Event Information';

  @override
  String get eventName => 'Event Name';

  @override
  String get eventLocation => 'Event Location';

  @override
  String get start => 'Start';

  @override
  String get changeStartTime => 'Change start time';

  @override
  String get end => 'End';

  @override
  String get changeEndTime => 'Change end time';

  @override
  String get currentImages => 'Current Images';

  @override
  String get noImages => 'This event has no images yet.';

  @override
  String get updateEvent => 'Update Event';

  @override
  String get couldNotLoadEventDetails => 'Could not load event details.';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Share';

  @override
  String get noDescription => 'No description available.';

  @override
  String get noEventName => 'No event name';

  @override
  String get unknownStatus => 'Unknown';

  @override
  String get unknownTime => 'Time not specified';

  @override
  String sameDayTimeFormat(Object startTime, Object endTime) {
    return '$startTime - $endTime';
  }

  @override
  String differentDayFormat(Object startDate, Object endDate) {
    return '$startDate - $endDate';
  }

  @override
  String get fullDayFormat => 'EEEE, dd/MM/yyyy';

  @override
  String get attendanceStats => '📈 Attendance Statistics';

  @override
  String get registeredUsers => 'Registered';

  @override
  String get checkedIn => 'Checked-in';

  @override
  String get absentees => 'Absentees';

  @override
  String get venue => '📍 Venue';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get addressCopied => 'Address copied to clipboard';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get couldNotOpenMaps => 'Could not open Google Maps';

  @override
  String get noSpecificLocation => 'No specific location provided';

  @override
  String get eventDescription => '🧾 Event Description';

  @override
  String get defaultEventDescription =>
      'This event is for networking, sharing, and connecting the community.';

  @override
  String get eventImages => '📸 Event Images';

  @override
  String get reviewsAndRatings => '⭐ Reviews & Ratings';

  @override
  String xReviews(Object count) {
    return '($count reviews)';
  }

  @override
  String get showMoreReviews => 'Show more reviews...';

  @override
  String get writeYourReview => 'Write your review:';

  @override
  String get shareYourThoughts => 'Share your thoughts about the event...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get eventType => '🎭 Event Type';

  @override
  String get eventTypeOpen => 'Open Event';

  @override
  String get eventTypeLimited => 'Limited Event';

  @override
  String get eventTypePrivate => 'Private Event';

  @override
  String get maxGuests => 'Maximum Guests';

  @override
  String get minGuestsWarning => '⚠️ Must have at least 2 guests.';

  @override
  String get detailedDescription => 'Detailed Event Description';

  @override
  String get pleaseEnterDescription => 'Please enter the event description';

  @override
  String get guestDistributionByEventType => 'Guest Distribution by Event Type';

  @override
  String get guestContactRequired =>
      'Guest contact information is required (email or phone).';

  @override
  String get noUpcomingEvents =>
      'No upcoming events available to add guests to.';

  @override
  String get guestEventRequired => 'Please select an event for the guest.';

  @override
  String get guestCreateSuccess => 'Guest created successfully!';

  @override
  String guestCreateError(Object error) {
    return 'Error creating guest: $error';
  }

  @override
  String get addGuestTitle => 'Add Guest';

  @override
  String get noGuestsFound => 'No guests found.';

  @override
  String get guestFullNameLabel => 'Full Name';

  @override
  String get guestNameRequired => 'Guest name is required.';

  @override
  String get guestEmailLabel => 'Email';

  @override
  String get guestPhoneLabel => 'Phone Number';

  @override
  String get guestEventLabel => 'Event';

  @override
  String get save => 'Save';

  @override
  String get noGuestContact => 'No contact info';

  @override
  String get loadMore => 'Load more';
}
