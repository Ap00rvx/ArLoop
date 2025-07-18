part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class InitialShopEvent extends ShopEvent {}

// Shop Details Events
class GetShopDetailsEvent extends ShopEvent {}

class UpdateShopServicesEvent extends ShopEvent {
  final List<String> services;

  const UpdateShopServicesEvent(this.services);

  @override
  List<Object> get props => [services];
}

class UpdateShopTagsEvent extends ShopEvent {
  final List<String> tags;

  const UpdateShopTagsEvent(this.tags);

  @override
  List<Object> get props => [tags];
}

// Statistics Events
class GetShopStatisticsEvent extends ShopEvent {}

// Announcement Events
class AddAnnouncementEvent extends ShopEvent {
  final String title;
  final String message;
  final String type;
  final DateTime? endDate;

  const AddAnnouncementEvent({
    required this.title,
    required this.message,
    this.type = 'info',
    this.endDate,
  });

  @override
  List<Object?> get props => [title, message, type, endDate];
}

class GetActiveAnnouncementsEvent extends ShopEvent {}

class UpdateAnnouncementStatusEvent extends ShopEvent {
  final String announcementId;
  final bool isActive;

  const UpdateAnnouncementStatusEvent({
    required this.announcementId,
    required this.isActive,
  });

  @override
  List<Object> get props => [announcementId, isActive];
}

// Holiday Events
class AddHolidayEvent extends ShopEvent {
  final DateTime date;
  final String reason;
  final bool isRecurring;

  const AddHolidayEvent({
    required this.date,
    required this.reason,
    this.isRecurring = false,
  });

  @override
  List<Object> get props => [date, reason, isRecurring];
}

// Certification Events
class AddCertificationEvent extends ShopEvent {
  final String name;
  final String issuedBy;
  final DateTime issuedDate;
  final String certificateNumber;
  final DateTime? expiryDate;
  final String? documentUrl;

  const AddCertificationEvent({
    required this.name,
    required this.issuedBy,
    required this.issuedDate,
    required this.certificateNumber,
    this.expiryDate,
    this.documentUrl,
  });

  @override
  List<Object?> get props => [
    name,
    issuedBy,
    issuedDate,
    certificateNumber,
    expiryDate,
    documentUrl,
  ];
}

// Token Management Events
class SetShopAuthTokenEvent extends ShopEvent {
  final String token;

  const SetShopAuthTokenEvent(this.token);

  @override
  List<Object> get props => [token];
}

class ClearShopAuthTokenEvent extends ShopEvent {}
