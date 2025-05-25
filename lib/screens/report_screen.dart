// screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:t_absensi/services/api_services.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedPeriod = 'This Month';
  List<String> periods = ['This Week', 'This Month', 'Last Month', 'Custom'];

  Map<String, dynamic>? attendanceData;
  Map<String, dynamic>? leaveData;
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  DateTime customStartDate = DateTime.now().subtract(Duration(days: 30));
  DateTime customEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      int month = now.month;
      int year = now.year;

      // Adjust month/year based on selected period
      switch (selectedPeriod) {
        case 'This Week':
        case 'This Month':
          // Use current month
          break;
        case 'Last Month':
          month = now.month == 1 ? 12 : now.month - 1;
          year = now.month == 1 ? now.year - 1 : now.year;
          break;
        case 'Custom':
          month = customStartDate.month;
          year = customStartDate.year;
          break;
      }

      // Load attendance history
      final attendanceResponse = await ApiService.getAttendanceHistory(
        month: month,
        year: year,
      );

      // Load leave history
      final leaveResponse = await ApiService.getLeaveHistory();

      if (attendanceResponse['success']) {
        setState(() {
          attendanceData = attendanceResponse['data'];
          statistics = attendanceResponse['data']['statistics'];
        });
      }

      if (leaveResponse['success']) {
        setState(() {
          leaveData = leaveResponse['data'];
        });
      }
    } catch (e) {
      _showError('Failed to load report data');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance Report'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: isLoading ? null : _exportReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              SizedBox(height: 20),
              if (isLoading)
                _buildLoadingState()
              else ...[
                _buildSummaryCards(),
                SizedBox(height: 20),
                _buildAttendanceChart(),
                SizedBox(height: 20),
                _buildDetailedReport(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                items:
                    periods.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                  if (value != 'Custom') {
                    _loadReportData();
                  } else {
                    _showCustomDatePicker();
                  }
                },
              ),
            ),
          ),
          if (selectedPeriod == 'Custom') ...[
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCustomStartDate(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(customStartDate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCustomEndDate(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(customEndDate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildSkeletonCard(height: 120),
        SizedBox(height: 20),
        _buildSkeletonCard(height: 200),
        SizedBox(height: 20),
        _buildSkeletonCard(height: 300),
      ],
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (statistics == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Days',
              '${statistics!['total_work_days'] ?? 0}',
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Present Days',
              '${statistics!['present_days'] ?? 0}',
              Icons.check_circle,
              Colors.green,
            ),
            _buildSummaryCard(
              'Late Days',
              '${statistics!['late_days'] ?? 0}',
              Icons.access_time,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Absent Days',
              '${statistics!['absent_days'] ?? 0}',
              Icons.cancel,
              Colors.red,
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Hours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${statistics!['total_hours'] ?? 0}h',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Average Hours/Day',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    '${statistics!['average_hours'] ?? 0}h',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    if (attendanceData == null || attendanceData!['attendances'] == null) {
      return SizedBox.shrink();
    }

    List<dynamic> attendances = attendanceData!['attendances'];

    // Prepare chart data
    Map<String, int> statusCounts = {
      'Present': 0,
      'Late': 0,
      'Absent': 0,
      'Early Leave': 0,
    };

    for (var attendance in attendances) {
      String status = attendance['status'] ?? 'absent';
      switch (status.toLowerCase()) {
        case 'present':
          statusCounts['Present'] = statusCounts['Present']! + 1;
          break;
        case 'late':
          statusCounts['Late'] = statusCounts['Late']! + 1;
          break;
        case 'absent':
          statusCounts['Absent'] = statusCounts['Absent']! + 1;
          break;
        case 'early_leave':
          statusCounts['Early Leave'] = statusCounts['Early Leave']! + 1;
          break;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: statusCounts['Present']!.toDouble(),
                    title: '${statusCounts['Present']}',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: statusCounts['Late']!.toDouble(),
                    title: '${statusCounts['Late']}',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: statusCounts['Absent']!.toDouble(),
                    title: '${statusCounts['Absent']}',
                    color: Colors.red,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: statusCounts['Early Leave']!.toDouble(),
                    title: '${statusCounts['Early Leave']}',
                    color: Colors.purple,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildLegendItem(
                'Present',
                Colors.green,
                statusCounts['Present']!,
              ),
              _buildLegendItem('Late', Colors.orange, statusCounts['Late']!),
              _buildLegendItem('Absent', Colors.red, statusCounts['Absent']!),
              _buildLegendItem(
                'Early Leave',
                Colors.purple,
                statusCounts['Early Leave']!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDetailedReport() {
    if (attendanceData == null || attendanceData!['attendances'] == null) {
      return SizedBox.shrink();
    }

    List<dynamic> attendances = attendanceData!['attendances'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Detailed Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: attendances.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return _buildAttendanceItem(attendance);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> attendance) {
    final date = DateTime.parse(attendance['date']);
    final checkIn = attendance['check_in'];
    final checkOut = attendance['check_out'];
    final status = attendance['status'] ?? 'absent';
    final workHours = attendance['work_hours'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Date
          Container(
            width: 60,
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  DateFormat('dd').format(date),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  DateFormat('EEE').format(date),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 15),
          // Times
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (checkIn != null)
                  Row(
                    children: [
                      Icon(Icons.login, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        _formatTime(checkIn),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                if (checkOut != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.logout, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        _formatTime(checkOut),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
                if (checkIn == null && checkOut == null)
                  Text(
                    'No record',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          // Work hours
          if (workHours != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${workHours}h',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomDatePicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Custom Period'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Start Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(customStartDate),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _selectCustomStartDate,
                ),
                ListTile(
                  title: Text('End Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(customEndDate),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _selectCustomEndDate,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadReportData();
                },
                child: Text('Apply'),
              ),
            ],
          ),
    );
  }

  Future<void> _selectCustomStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customStartDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        customStartDate = picked;
        if (customEndDate.isBefore(customStartDate)) {
          customEndDate = customStartDate;
        }
      });
    }
  }

  Future<void> _selectCustomEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customEndDate,
      firstDate: customStartDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        customEndDate = picked;
      });
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select export format:'),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport('PDF');
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport('Excel');
                },
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.blue),
                title: Text('CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport('CSV');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _performExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format export functionality will be implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'early_leave':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'early_leave':
        return 'Early Leave';
      default:
        return status.toUpperCase();
    }
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    return timeString;
  }
}
