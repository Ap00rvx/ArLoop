part of 'shop_bloc.dart';

enum ShopStatus { initial, loading, success, failure }

class ShopState extends Equatable {
  final ShopStatus status;
  final String? error;
  final String? message;

  // Shop Details
  final Shop? shop;
  final bool isShopLoading;

  // Statistics
  final ShopStatistics? statistics;
  final bool isStatisticsLoading;

  // Announcements
  final List<Announcement> announcements;
  final bool isAnnouncementsLoading;
  final bool isAddingAnnouncement;
  final bool isUpdatingAnnouncementStatus;

  // Holidays
  final List<Holiday> holidays;
  final bool isAddingHoliday;

  // Certifications
  final List<Certification> certifications;
  final bool isAddingCertification;

  // Services & Tags
  final bool isUpdatingServices;
  final bool isUpdatingTags;

  const ShopState({
    this.status = ShopStatus.initial,
    this.error,
    this.message,
    this.shop,
    this.isShopLoading = false,
    this.statistics,
    this.isStatisticsLoading = false,
    this.announcements = const [],
    this.isAnnouncementsLoading = false,
    this.isAddingAnnouncement = false,
    this.isUpdatingAnnouncementStatus = false,
    this.holidays = const [],
    this.isAddingHoliday = false,
    this.certifications = const [],
    this.isAddingCertification = false,
    this.isUpdatingServices = false,
    this.isUpdatingTags = false,
  });

  @override
  List<Object?> get props => [
        status,
        error,
        message,
        shop,
        isShopLoading,
        statistics,
        isStatisticsLoading,
        announcements,
        isAnnouncementsLoading,
        isAddingAnnouncement,
        isUpdatingAnnouncementStatus,
        holidays,
        isAddingHoliday,
        certifications,
        isAddingCertification,
        isUpdatingServices,
        isUpdatingTags,
      ];

  bool get isInitial => status == ShopStatus.initial;
  bool get isLoading => status == ShopStatus.loading;
  bool get isSuccess => status == ShopStatus.success;
  bool get isFailure => status == ShopStatus.failure;

  ShopState copyWith({
    ShopStatus? status,
    String? error,
    String? message,
    Shop? shop,
    bool? isShopLoading,
    ShopStatistics? statistics,
    bool? isStatisticsLoading,
    List<Announcement>? announcements,
    bool? isAnnouncementsLoading,
    bool? isAddingAnnouncement,
    bool? isUpdatingAnnouncementStatus,
    List<Holiday>? holidays,
    bool? isAddingHoliday,
    List<Certification>? certifications,
    bool? isAddingCertification,
    bool? isUpdatingServices,
    bool? isUpdatingTags,
  }) {
    return ShopState(
      status: status ?? this.status,
      error: error,
      message: message,
      shop: shop ?? this.shop,
      isShopLoading: isShopLoading ?? this.isShopLoading,
      statistics: statistics ?? this.statistics,
      isStatisticsLoading: isStatisticsLoading ?? this.isStatisticsLoading,
      announcements: announcements ?? this.announcements,
      isAnnouncementsLoading: isAnnouncementsLoading ?? this.isAnnouncementsLoading,
      isAddingAnnouncement: isAddingAnnouncement ?? this.isAddingAnnouncement,
      isUpdatingAnnouncementStatus: isUpdatingAnnouncementStatus ?? this.isUpdatingAnnouncementStatus,
      holidays: holidays ?? this.holidays,
      isAddingHoliday: isAddingHoliday ?? this.isAddingHoliday,
      certifications: certifications ?? this.certifications,
      isAddingCertification: isAddingCertification ?? this.isAddingCertification,
      isUpdatingServices: isUpdatingServices ?? this.isUpdatingServices,
      isUpdatingTags: isUpdatingTags ?? this.isUpdatingTags,
    );
  }
}