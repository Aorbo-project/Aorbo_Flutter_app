import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> faqList = [
    {
      "question": "How do I know if a trek organizer is trustworthy?",
      "answer":
          "We carefully vet every trek organizer on Aorbo Treks to ensure they meet our high standards of safety, reliability, and quality service. 🌟 Your adventure and trust are our priorities!",
    },
    {
      "question": "Will you arrange the stays during the trek?",
      "answer":
          "All our treks include certified guides, first-aid kits, and 24/7 emergency support.",
    },
    {
      "question": "Can I customize my trek itinerary?",
      "answer":
          "Yes, cancellation and rescheduling are allowed up to 48 hours before departure.",
    },
  ];

  List<bool> expandedList = [];
  List<String?> _faqReactions = []; // 'yes', 'no', or null

  @override
  void initState() {
    super.initState();
    expandedList = List<bool>.filled(faqList.length, false);
    _faqReactions = List<String?>.filled(faqList.length, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background light blue extension
          Container(
            height: 8.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Header Container
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 4.h, bottom: 1.h),
                  padding: EdgeInsets.only(left: 2.h, right: 2.h, top: 4.h),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.w),
                      topRight: Radius.circular(6.w),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 1.h),
                        child: Text(
                          "Frequently Asked Questions",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: FontSize.s14,
                            color: CommonColors.blackColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ...faqList.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> faq = entry.value;

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: index == 0 && !expandedList[index]
                                  ? BorderSide(
                                      color: CommonColors.grey_AEAEAE,
                                      width: 1,
                                    )
                                  : BorderSide(
                                      color: CommonColors.transferent,
                                      width: 0,
                                    ),
                              bottom: !expandedList[index]
                                  ? BorderSide(
                                      color: CommonColors.grey_AEAEAE,
                                      width: 1,
                                    )
                                  : BorderSide(
                                      color: CommonColors.transferent,
                                      width: 0,
                                    ),
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: CommonColors.transparent),
                            child: ExpansionTile(
                              title: SizedBox(
                                height: 7.h,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    faq['question'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: FontSize.s10,
                                      color: CommonColors.blackColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                expandedList[index]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: CommonColors.blackColor,
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  for (
                                    int i = 0;
                                    i < expandedList.length;
                                    i++
                                  ) {
                                    expandedList[i] = false; // collapse all
                                  }
                                  expandedList[index] =
                                      expanded; // expand current only
                                });
                              },
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        faq['answer'],
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s10,
                                          color: CommonColors.grey_AEAEAE,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "Is this Information Useful?",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: FontSize.s11,
                                        ),
                                      ),
                                      SizedBox(height: 1.5.h),
                                      Container(
                                        width: 40.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_faqReactions[index] ==
                                                      'yes') {
                                                    _faqReactions[index] = null;
                                                  } else {
                                                    _faqReactions[index] =
                                                        'yes';
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.thumb_up,
                                                    color:
                                                        _faqReactions[index] ==
                                                            'yes'
                                                        ? CommonColors.materialGreen
                                                        : CommonColors
                                                              .grey_AEAEAE,
                                                  ),
                                                  SizedBox(height: 0.5.h),
                                                  Text(
                                                    "Yes",
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          _faqReactions[index] ==
                                                              'yes'
                                                          ? CommonColors.materialGreen
                                                          : CommonColors
                                                                .grey_AEAEAE,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_faqReactions[index] ==
                                                      'no') {
                                                    _faqReactions[index] = null;
                                                  } else {
                                                    _faqReactions[index] = 'no';
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.thumb_down,
                                                    color:
                                                        _faqReactions[index] ==
                                                            'no'
                                                        ? CommonColors.materialRed
                                                        : CommonColors
                                                              .grey_AEAEAE,
                                                  ),
                                                  SizedBox(height: 0.5.h),
                                                  Text(
                                                    "No",
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          _faqReactions[index] ==
                                                              'no'
                                                          ? CommonColors.materialRed
                                                          : CommonColors
                                                                .grey_AEAEAE,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_faqReactions[index] == 'no') ...[
                                        SizedBox(height: 1.5.h),
                                        CommonButton(
                                          fontSize: FontSize.s11,
                                          width: 43.w,
                                          isFullWidth: false,
                                          textColor: CommonColors.whiteColor,
                                          fontFamily: 'Poppins',
                                          text: "Chat with us",
                                          onPressed: () {
                                            Get.toNamed('/chatboat');
                                          },
                                          gradient: CommonColors.filterGradient,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CommonBottomNav(
      //   selectedIndex: selectedIndex,
      //   onIndexChanged: (index) {
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      //   selectedIconColor: CommonColors.appYellowColor,
      //   unselectedIconColor: CommonColors.blackColor,
      // ),
    );
  }
}
