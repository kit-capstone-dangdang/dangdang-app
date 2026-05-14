import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'package:flutter/material.dart';

class BloodSugarForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final BloodSugarRecord? initialRecord;

  const BloodSugarForm({
    super.key,
    required this.title,
    required this.buttonText,
    this.initialRecord,
  });

  @override
  State<BloodSugarForm> createState() =>
      _BloodSugarFormState();
}

class _BloodSugarFormState
    extends State<BloodSugarForm> {
  final TextEditingController sugarController =
      TextEditingController();

  final TextEditingController memoController =
      TextEditingController();

  String selectedType = '식전';

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();

  final List<String> types = [
    '공복',
    '식전',
    '식후',
    '취침전',
  ];

  @override
  void initState() {
    super.initState();

    final record = widget.initialRecord;

    if (record != null) {
      sugarController.text =
          record.bloodSugar.toString();

      memoController.text = record.memo;

      selectedType = record.mealState;

      selectedDate = record.dateTime;

      selectedTime = TimeOfDay(
        hour: record.dateTime.hour,
        minute: record.dateTime.minute,
      );
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatTime(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0
            ? 12
            : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am ? '오전' : '오후';

    return '$period ${hour.toString().padLeft(2, '0')}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),

        title: Text(
          widget.title,

          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),

                /// 혈당 입력
                Center(
                  child: Column(
                    children: [
                      Text(
                        '혈당 수치 입력',

                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: 250,

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          crossAxisAlignment:
                              CrossAxisAlignment.end,

                          children: [
                            SizedBox(
                              width: 140,

                              child: TextField(
                                controller:
                                    sugarController,

                                onChanged: (_) {
                                  setState(() {});
                                },

                                keyboardType:
                                    TextInputType.number,

                                textAlign:
                                    TextAlign.center,

                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      sugarController
                                              .text
                                              .isEmpty
                                          ? const Color(
                                            0xFFDDDDDD,
                                          )
                                          : Colors.black,
                                ),

                                decoration:
                                    const InputDecoration(
                                      hintText: '000',

                                      hintStyle:
                                          TextStyle(
                                            color: Color(
                                              0xFFDDDDDD,
                                            ),
                                          ),

                                      enabledBorder:
                                          UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(
                                                  color:
                                                      Color(
                                                        0xFF2962FF,
                                                      ),
                                                  width:
                                                      3,
                                                ),
                                          ),

                                      focusedBorder:
                                          UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(
                                                  color:
                                                      Color(
                                                        0xFF2962FF,
                                                      ),
                                                  width:
                                                      3,
                                                ),
                                          ),
                                    ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    bottom: 12,
                                  ),

                              child: Text(
                                'mg/dL',

                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// 측정 시점
                Row(
                  children: const [
                    Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF2962FF),
                    ),

                    SizedBox(width: 10),

                    Text(
                      '측정 시점',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: types.map((type) {
                    final bool isSelected =
                        selectedType == type;

                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                              right: 8,
                            ),

                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = type;
                            });
                          },

                          child: Container(
                            height: 52,

                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(
                                        0xFF2962FF,
                                      )
                                      : Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),

                              border: Border.all(
                                color: const Color(
                                  0xFFE5E7EB,
                                ),
                              ),

                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color:
                                              const Color(
                                                0xFF2962FF,
                                              ).withOpacity(
                                                0.25,
                                              ),
                                          blurRadius:
                                              12,
                                          offset:
                                              const Offset(
                                                0,
                                                4,
                                              ),
                                        ),
                                      ]
                                      : null,
                            ),

                            child: Center(
                              child: Text(
                                type,

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w600,

                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors
                                              .grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 34),

                /// 날짜 시간
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Color(
                                  0xFF2962FF,
                                ),
                              ),

                              SizedBox(width: 8),

                              Text(
                                '날짜',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          GestureDetector(
                            onTap: pickDate,

                            child: Container(
                              height: 62,

                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),

                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF5F6F8,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [
                                  Expanded(
                                    child: Text(
                                      formatDate(
                                        selectedDate,
                                      ),

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  const Icon(
                                    Icons
                                        .calendar_today_outlined,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Color(
                                  0xFF2962FF,
                                ),
                              ),

                              SizedBox(width: 8),

                              Text(
                                '시간',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          GestureDetector(
                            onTap: pickTime,

                            child: Container(
                              height: 62,

                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),

                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF5F6F8,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [
                                  Expanded(
                                    child: Text(
                                      formatTime(
                                        selectedTime,
                                      ),

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  const Icon(
                                    Icons
                                        .access_time_outlined,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                /// 메모
                const Text(
                  '메모 (선택)',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  height: 120,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: TextField(
                    controller: memoController,

                    maxLines: null,

                    decoration: const InputDecoration(
                      hintText: '특이사항을 입력하세요',

                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 66,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2962FF),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),

                    child: Text(
                      widget.buttonText,

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}