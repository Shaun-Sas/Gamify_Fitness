import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> with TickerProviderStateMixin {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int _steps = 0;
  String _status = 'Unknown';
  int _lastStepCount = 0;
  DateTime? _lastStepTime;
  bool _isInitialized = false;

  // User properties
  double _weight = 70; // kg
  double _height = 170; // cm
  int _age = 30;
  String _gender = 'Male';
  bool _isSettingsExpanded = false;
  double _strideLength = 0.762; // average stride length in meters (approx 30 inches)

  // Calculated values
  double _distance = 0; // in kilometers
  double _caloriesBurned = 0;
  double _stepsPerMinute = 0; // Current pace

  // Weekly data
  List<DailySteps> _weeklySteps = [];

  // Animation controller for the step counter
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize weekly steps data
    _initializeWeeklySteps();

    // Load saved data
    _loadSavedData();

    // Request permissions and initialize pedometer
    _requestPermissions();
  }

  void _initializeWeeklySteps() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    _weeklySteps = List.generate(7, (index) {
      final day = index + 1; // 1-7 (Monday-Sunday)
      String dayName = '';

      switch (day) {
        case 1: dayName = 'Mon'; break;
        case 2: dayName = 'Tue'; break;
        case 3: dayName = 'Wed'; break;
        case 4: dayName = 'Thu'; break;
        case 5: dayName = 'Fri'; break;
        case 6: dayName = 'Sat'; break;
        case 7: dayName = 'Sun'; break;
      }

      return DailySteps(
        day: dayName,
        steps: 0,
        isToday: day == dayOfWeek,
      );
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _weight = prefs.getDouble('weight') ?? 70;
      _height = prefs.getDouble('height') ?? 170;
      _age = prefs.getInt('age') ?? 30;
      _gender = prefs.getString('gender') ?? 'Male';
      _strideLength = prefs.getDouble('strideLength') ?? 0.762;
      _steps = prefs.getInt('steps') ?? 0;
      _lastStepCount = prefs.getInt('lastStepCount') ?? 0;

      final lastStepTimeMillis = prefs.getInt('lastStepTime');
      if (lastStepTimeMillis != null) {
        _lastStepTime = DateTime.fromMillisecondsSinceEpoch(lastStepTimeMillis);
      }

      // Load weekly steps
      for (int i = 0; i < 7; i++) {
        final steps = prefs.getInt('day_${i + 1}_steps') ?? 0;
        _weeklySteps[i] = _weeklySteps[i].copyWith(steps: steps);
      }

      // Calculate stride length if not set (approximately 45% of height in cm converted to meters)
      if (_strideLength == 0.762) {
        _strideLength = _height * 0.0045;
        _saveData();
      }

      _updateCalculations();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight', _weight);
    await prefs.setDouble('height', _height);
    await prefs.setInt('age', _age);
    await prefs.setString('gender', _gender);
    await prefs.setDouble('strideLength', _strideLength);
    await prefs.setInt('steps', _steps);
    await prefs.setInt('lastStepCount', _lastStepCount);

    if (_lastStepTime != null) {
      await prefs.setInt('lastStepTime', _lastStepTime!.millisecondsSinceEpoch);
    }

    // Save weekly steps
    for (int i = 0; i < 7; i++) {
      await prefs.setInt('day_${i + 1}_steps', _weeklySteps[i].steps);
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _initPedometer();
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied: Cannot access step counter'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initPedometer() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _pedestrianStatusStream.listen((PedestrianStatus event) {
      setState(() {
        _status = event.status;
      });
    });

    _stepCountStream.listen((StepCount event) {
      setState(() {
        // Check if this is the first reading since app start
        if (!_isInitialized) {
          _lastStepCount = event.steps;
          _isInitialized = true;
          // If we have no saved step count, start from 0
          if (_steps == 0) {
            _steps = 0;
          }
        } else {
          // Calculate the difference since the last reading
          int stepDifference = event.steps - _lastStepCount;

          // Avoid negative steps (can happen if pedometer resets)
          if (stepDifference >= 0) {
            _steps += stepDifference;

            // Calculate pace (steps per minute)
            final now = DateTime.now();
            if (_lastStepTime != null && stepDifference > 0) {
              final duration = now.difference(_lastStepTime!);
              if (duration.inSeconds > 0) {
                _stepsPerMinute = (stepDifference / duration.inSeconds) * 60;
              }
            }
            _lastStepTime = now;
          } else if (stepDifference < 0) {
            // Pedometer was reset (e.g., phone restart)
            // Keep the existing step count and start counting from the new base
          }

          _lastStepCount = event.steps;
        }

        _updateCalculations();
        _updateTodaySteps();
        _saveData();
        _animationController.forward(from: 0.0);
      });
    });
  }

  void _updateCalculations() {
    // Calculate distance in kilometers
    _distance = _steps * _strideLength / 1000;

    // Calculate calories burned
    _calculateCalories();
  }

  void _calculateCalories() {
    // More accurate calorie calculation based on weight, height, gender and age
    // MET (Metabolic Equivalent of Task) values for walking
    double walkingMET = 3.5; // Moderate pace walking

    // Adjust MET based on walking pace if available
    if (_stepsPerMinute > 0) {
      // Adjust MET based on pace:
      // Slow walking (~60-80 steps/min): MET ~2.0-3.0
      // Moderate walking (~80-110 steps/min): MET ~3.0-4.0
      // Fast walking (~110-130 steps/min): MET ~4.0-5.0
      // Very fast walking/light jogging (>130 steps/min): MET ~5.0+

      if (_stepsPerMinute < 80) {
        walkingMET = 2.5;
      } else if (_stepsPerMinute < 110) {
        walkingMET = 3.5;
      } else if (_stepsPerMinute < 130) {
        walkingMET = 4.5;
      } else {
        walkingMET = 5.5;
      }
    }

    // Calculate BMR using the Harris-Benedict equation
    double bmr;
    if (_gender == 'Male') {
      bmr = 88.362 + (13.397 * _weight) + (4.799 * _height) - (5.677 * _age);
    } else {
      bmr = 447.593 + (9.247 * _weight) + (3.098 * _height) - (4.330 * _age);
    }

    // Calculate calories burned per step (average step burns about 0.04 * weight in kg)
    double caloriesPerStep = 0.04 * _weight;

    // Apply a more accurate calculation based on MET
    // MET * weight(kg) * time(hours) = calories burned
    // For steps: (MET * weight * (steps * average time per step in hours))
    double avgMinutesPerStep = 0.0008; // Roughly 500 steps per hour
    _caloriesBurned = walkingMET * _weight * (_steps * avgMinutesPerStep / 60);

    // Apply minimum threshold to avoid unrealistic values
    if (_caloriesBurned < caloriesPerStep * _steps) {
      _caloriesBurned = caloriesPerStep * _steps;
    }
  }

  void _updateTodaySteps() {
    final today = DateTime.now().weekday - 1; // 0-6 (Monday-Sunday)
    _weeklySteps[today] = _weeklySteps[today].copyWith(steps: _steps);
  }

  void _resetSteps() {
    setState(() {
      _steps = 0;
      _distance = 0;
      _caloriesBurned = 0;
      _lastStepCount = 0;
      _lastStepTime = null;
      _updateTodaySteps();
      _saveData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main display card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Steps and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Steps column
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'STEPS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              ScaleTransition(
                                scale: Tween<double>(
                                  begin: 1.0,
                                  end: 1.2,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.elasticOut,
                                )),
                                child: Text(
                                  _steps.toString(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),

                        // Status column
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'STATUS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _status,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _status == 'walking' ? Colors.green : Colors.grey,
                                ),
                              ),
                              if (_stepsPerMinute > 0)
                                Text(
                                  '${_stepsPerMinute.toStringAsFixed(1)} steps/min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Distance and Calories display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Distance
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: Colors.blue.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'DISTANCE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_distance.toStringAsFixed(2)} km',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Calories
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.orange.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'CALORIES',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_caloriesBurned.toStringAsFixed(1)} cal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Reset button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resetSteps,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weekly progress card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Weekly Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildWeeklyChart(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Personal Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      _isSettingsExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () {
                      setState(() {
                        _isSettingsExpanded = !_isSettingsExpanded;
                      });
                    },
                  ),
                  if (_isSettingsExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSettingsField(
                            'Weight (kg)',
                            _weight.toString(),
                                (value) {
                              final weight = double.tryParse(value);
                              if (weight != null && weight > 0) {
                                setState(() {
                                  _weight = weight;
                                  _calculateCalories();
                                });
                                _saveData();
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                          _buildSettingsField(
                            'Height (cm)',
                            _height.toString(),
                                (value) {
                              final height = double.tryParse(value);
                              if (height != null && height > 0) {
                                setState(() {
                                  _height = height;
                                  // Update stride length based on height
                                  _strideLength = _height * 0.0045;
                                  _updateCalculations();
                                });
                                _saveData();
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                          _buildSettingsField(
                            'Age',
                            _age.toString(),
                                (value) {
                              final age = int.tryParse(value);
                              if (age != null && age > 0) {
                                setState(() {
                                  _age = age;
                                  _calculateCalories();
                                });
                                _saveData();
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                          _buildGenderSelector(),
                          _buildSettingsField(
                            'Stride Length (m)',
                            _strideLength.toStringAsFixed(3),
                                (value) {
                              final strideLength = double.tryParse(value);
                              if (strideLength != null && strideLength > 0) {
                                setState(() {
                                  _strideLength = strideLength;
                                  _updateCalculations();
                                });
                                _saveData();
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'These settings help calculate your distance and calorie burn more accurately based on your personal metrics.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsField(
      String label,
      String initialValue,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: initialValue),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _gender = value;
                    _calculateCalories();
                  });
                  _saveData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10000,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_weeklySteps[groupIndex].steps} steps',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _weeklySteps[value.toInt()].day,
                    style: TextStyle(
                      color: _weeklySteps[value.toInt()].isToday
                          ? Colors.blue.shade800
                          : Colors.grey.shade600,
                      fontWeight: _weeklySteps[value.toInt()].isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              interval: 2000,
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: List.generate(
          _weeklySteps.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _weeklySteps[index].steps.toDouble(),
                color: _weeklySteps[index].isToday
                    ? Colors.blue
                    : Colors.blue.shade300,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model class for daily steps
class DailySteps {
  final String day;
  final int steps;
  final bool isToday;

  DailySteps({
    required this.day,
    required this.steps,
    required this.isToday,
  });

  DailySteps copyWith({
    String? day,
    int? steps,
    bool? isToday,
  }) {
    return DailySteps(
      day: day ?? this.day,
      steps: steps ?? this.steps,
      isToday: isToday ?? this.isToday,
    );
  }
}