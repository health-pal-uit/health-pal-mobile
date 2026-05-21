import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:da1/src/features/user/advisor/domain/expert.dart';

class AdvisorBookingScreen extends StatefulWidget {
  final Expert expert;

  const AdvisorBookingScreen({super.key, required this.expert});

  @override
  State<AdvisorBookingScreen> createState() => _AdvisorBookingScreenState();
}

class _AdvisorBookingScreenState extends State<AdvisorBookingScreen> {
  late final Dio _dio;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCallType = 'audio';
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  late final List<DateTime> _availableDates;
  final List<TimeOfDay> _timeSlots = const [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 13, minute: 30),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 15, minute: 30),
    TimeOfDay(hour: 16, minute: 30),
  ];

  @override
  void initState() {
    super.initState();
    _setupDio();
    _generateDates();

    // Auto-select first available feature if default isn't preferred
    if (!widget.expert.canDoVideo && _selectedCallType == 'video') {
      _selectedCallType = 'audio';
    }
  }

  void _setupDio() {
    final secureStorage = const FlutterSecureStorage();
    final localDataSource = AuthLocalDataSourceImpl(storage: secureStorage);
    _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await localDataSource.getToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  void _generateDates() {
    final today = DateTime.now();
    _availableDates = List.generate(
      14,
      (index) => today.add(Duration(days: index)),
    );
    _selectedDate = _availableDates.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ hẹn!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final localDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (localDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chọn thời gian trong quá khứ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final scheduledAtUtc = localDateTime.toUtc().toIso8601String();

      final payload = {
        "expert_id": widget.expert.id,
        "call_type": _selectedCallType,
        "scheduled_at": scheduledAtUtc,
        "client_note": _noteController.text.trim(),
      };

      final response = await _dio.post('/bookings/me', data: payload);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String errMsg = 'Có lỗi xảy ra, vui lòng thử lại sau.';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errMsg = e.response?.data['message'].toString() ?? errMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpertSummary(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 16),
                  _buildDateSelector(),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Available Time'),
                  const SizedBox(height: 16),
                  _buildTimeSelector(),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Communication Method'),
                  const SizedBox(height: 16),
                  _buildCallTypeSelector(),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Notes for Expert (Optional)'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Describe your symptoms or what you want to discuss...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildExpertSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                widget.expert.avatarUrl != null
                    ? NetworkImage(widget.expert.avatarUrl!)
                    : null,
            child:
                widget.expert.avatarUrl == null
                    ? Icon(Icons.person, color: AppColors.primary)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expert.fullname ?? widget.expert.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.expert.roleName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        itemBuilder: (context, index) {
          final date = _availableDates[index];
          final isSelected =
              _selectedDate?.day == date.day &&
              _selectedDate?.month == date.month;
          final isToday = index == 0;

          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedDate = date;
                  _selectedTime = null; // reset time when changing date
                }),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          _timeSlots.map((time) {
            final isToday =
                _selectedDate?.day == DateTime.now().day &&
                _selectedDate?.month == DateTime.now().month;
            final isPastTime =
                isToday &&
                (time.hour < DateTime.now().hour ||
                    (time.hour == DateTime.now().hour &&
                        time.minute <= DateTime.now().minute));

            final isSelected = _selectedTime == time;

            return InkWell(
              onTap:
                  isPastTime
                      ? null
                      : () => setState(() => _selectedTime = time),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary
                          : (isPastTime ? Colors.grey[100] : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : (isPastTime
                                ? Colors.grey[200]!
                                : Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  time.format(context),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.white
                            : (isPastTime ? Colors.grey[400] : Colors.black87),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCallTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildCallTypeOption(
            'chat',
            Icons.chat_bubble_outline,
            'Chat',
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCallTypeOption(
            'audio',
            Icons.call_outlined,
            'Audio',
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCallTypeOption(
            'video',
            Icons.videocam_outlined,
            'Video',
            widget.expert.canDoVideo,
          ),
        ),
      ],
    );
  }

  Widget _buildCallTypeOption(
    String type,
    IconData icon,
    String label,
    bool isEnabled,
  ) {
    final isSelected = _selectedCallType == type;

    return GestureDetector(
      onTap:
          isEnabled
              ? () => setState(() => _selectedCallType = type)
              : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This call type is not supported.'),
                  ),
                );
              },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.primary
                      : (isEnabled ? Colors.grey[600] : Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected
                        ? AppColors.primary
                        : (isEnabled ? Colors.grey[800] : Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Est.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.expert.tokenPerMinute * 30} Tokens',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '/ 30 mins',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
