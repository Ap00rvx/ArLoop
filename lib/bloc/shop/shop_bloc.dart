import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/vendor/shop_service.dart';
import '../../models/vendor/shop.dart';

part 'shop_events.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc() : super(const ShopState()) {
    on<InitialShopEvent>(_initialShopEvent);
    on<SetShopAuthTokenEvent>(_setShopAuthTokenEvent);
    on<ClearShopAuthTokenEvent>(_clearShopAuthTokenEvent);

    // Shop Details Events
    on<GetShopDetailsEvent>(_getShopDetailsEvent);
    on<UpdateShopServicesEvent>(_updateShopServicesEvent);
    on<UpdateShopTagsEvent>(_updateShopTagsEvent);

    // Statistics Events
    on<GetShopStatisticsEvent>(_getShopStatisticsEvent);

    // Announcement Events
    on<AddAnnouncementEvent>(_addAnnouncementEvent);
    on<GetActiveAnnouncementsEvent>(_getActiveAnnouncementsEvent);
    on<UpdateAnnouncementStatusEvent>(_updateAnnouncementStatusEvent);

    // Holiday Events
    on<AddHolidayEvent>(_addHolidayEvent);

    // Certification Events
    on<AddCertificationEvent>(_addCertificationEvent);





  }

  //* InitialShopEvent
  Future<void> _initialShopEvent(
    InitialShopEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(status: ShopStatus.initial));
  }

  //* SetShopAuthTokenEvent
  Future<void> _setShopAuthTokenEvent(
    SetShopAuthTokenEvent event,
    Emitter<ShopState> emit,
  ) async {
    ShopService.setAuthToken(event.token);
    emit(
      state.copyWith(
        status: ShopStatus.success,
        message: 'Authentication token set successfully',
      ),
    );
  }

  //* ClearShopAuthTokenEvent
  Future<void> _clearShopAuthTokenEvent(
    ClearShopAuthTokenEvent event,
    Emitter<ShopState> emit,
  ) async {
    ShopService.clearAuthToken();
    emit(
      state.copyWith(
        status: ShopStatus.success,
        message: 'Authentication token cleared',
      ),
    );
  }

  //* GetShopDetailsEvent
  Future<void> _getShopDetailsEvent(
    GetShopDetailsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isShopLoading: true));

    try {
      final response = await ShopService.getShopDetails();

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ShopStatus.success,
            shop: response.data,
            isShopLoading: false,
            message: 'Shop details loaded successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isShopLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to get shop details: $e',
          isShopLoading: false,
        ),
      );
    }
  }

  //* UpdateShopServicesEvent
  Future<void> _updateShopServicesEvent(
    UpdateShopServicesEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isUpdatingServices: true));

    try {
      final response = await ShopService.updateShopServices(
        services: event.services,
      );

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ShopStatus.success,
            shop: response.data,
            isUpdatingServices: false,
            message: 'Shop services updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isUpdatingServices: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to update shop services: $e',
          isUpdatingServices: false,
        ),
      );
    }
  }

  //* UpdateShopTagsEvent
  Future<void> _updateShopTagsEvent(
    UpdateShopTagsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isUpdatingTags: true));

    try {
      final response = await ShopService.updateShopTags(tags: event.tags);

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ShopStatus.success,
            shop: response.data,
            isUpdatingTags: false,
            message: 'Shop tags updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isUpdatingTags: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to update shop tags: $e',
          isUpdatingTags: false,
        ),
      );
    }
  }

  //* GetShopStatisticsEvent
  Future<void> _getShopStatisticsEvent(
    GetShopStatisticsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isStatisticsLoading: true));

    try {
      final response = await ShopService.getShopStatistics();

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ShopStatus.success,
            statistics: response.data,
            isStatisticsLoading: false,
            message: 'Shop statistics loaded successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isStatisticsLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to get shop statistics: $e',
          isStatisticsLoading: false,
        ),
      );
    }
  }

  //* AddAnnouncementEvent
  Future<void> _addAnnouncementEvent(
    AddAnnouncementEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isAddingAnnouncement: true));

    try {
      final response = await ShopService.addAnnouncement(
        title: event.title,
        message: event.message,
        type: event.type,
        endDate: event.endDate,
      );

      if (response.isSuccess && response.data != null) {
        final updatedAnnouncements = [...state.announcements, response.data!];
        emit(
          state.copyWith(
            status: ShopStatus.success,
            announcements: updatedAnnouncements,
            isAddingAnnouncement: false,
            message: 'Announcement added successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isAddingAnnouncement: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to add announcement: $e',
          isAddingAnnouncement: false,
        ),
      );
    }
  }

  //* GetActiveAnnouncementsEvent
  Future<void> _getActiveAnnouncementsEvent(
    GetActiveAnnouncementsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isAnnouncementsLoading: true));

    try {
      final response = await ShopService.getActiveAnnouncements();

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: ShopStatus.success,
            announcements: response.data!,
            isAnnouncementsLoading: false,
            message: 'Active announcements loaded successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isAnnouncementsLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to get active announcements: $e',
          isAnnouncementsLoading: false,
        ),
      );
    }
  }

  //* UpdateAnnouncementStatusEvent
  Future<void> _updateAnnouncementStatusEvent(
    UpdateAnnouncementStatusEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isUpdatingAnnouncementStatus: true));

    try {
      final response = await ShopService.updateAnnouncementStatus(
        announcementId: event.announcementId,
        isActive: event.isActive,
      );

      if (response.isSuccess && response.data != null) {
        final updatedAnnouncements = state.announcements.map((announcement) {
          if (announcement.id == event.announcementId) {
            return response.data!;
          }
          return announcement;
        }).toList();

        emit(
          state.copyWith(
            status: ShopStatus.success,
            announcements: updatedAnnouncements,
            isUpdatingAnnouncementStatus: false,
            message: 'Announcement status updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isUpdatingAnnouncementStatus: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to update announcement status: $e',
          isUpdatingAnnouncementStatus: false,
        ),
      );
    }
  }

  //* AddHolidayEvent
  Future<void> _addHolidayEvent(
    AddHolidayEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isAddingHoliday: true));

    try {
      final response = await ShopService.addHoliday(
        date: event.date,
        reason: event.reason,
        isRecurring: event.isRecurring,
      );

      if (response.isSuccess && response.data != null) {
        final updatedHolidays = [...state.holidays, response.data!];
        emit(
          state.copyWith(
            status: ShopStatus.success,
            holidays: updatedHolidays,
            isAddingHoliday: false,
            message: 'Holiday added successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isAddingHoliday: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to add holiday: $e',
          isAddingHoliday: false,
        ),
      );
    }
  }

  //* AddCertificationEvent
  Future<void> _addCertificationEvent(
    AddCertificationEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(state.copyWith(isAddingCertification: true));

    try {
      final response = await ShopService.addCertification(
        name: event.name,
        issuedBy: event.issuedBy,
        issuedDate: event.issuedDate,
        certificateNumber: event.certificateNumber,
        expiryDate: event.expiryDate,
        documentUrl: event.documentUrl,
      );

      if (response.isSuccess && response.data != null) {
        final updatedCertifications = [...state.certifications, response.data!];
        emit(
          state.copyWith(
            status: ShopStatus.success,
            certifications: updatedCertifications,
            isAddingCertification: false,
            message: 'Certification added successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ShopStatus.failure,
            error: response.message,
            isAddingCertification: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ShopStatus.failure,
          error: 'Failed to add certification: $e',
          isAddingCertification: false,
        ),
      );
    }
  }









}
