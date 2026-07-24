import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/utils/screen_constants.dart';

/// "Select state of residence" bottom sheet — shared by every screen that
/// needs a state picker (booking traveller info, account profile edit).
/// Operates on [StateListData] objects directly rather than name strings,
/// so callers never need a separate name->id re-lookup after selection.
Future<void> showStateSelectionBottomSheet({
  required BuildContext context,
  required List<StateListData> stateList,
  required int? selectedStateId,
  required ValueChanged<StateListData> onStateSelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
    ),
    builder: (sheetContext) => _StateSelectionSheet(
      stateList: stateList,
      selectedStateId: selectedStateId,
      onStateSelected: onStateSelected,
    ),
  );
}

/// A real StatefulWidget (not a StatefulBuilder over an externally-owned
/// controller) so the framework disposes searchController at exactly the
/// right point in this widget's own lifecycle — no manual timing, no race
/// with a still-pending focus/animation callback touching a controller
/// someone already called dispose() on from outside.
class _StateSelectionSheet extends StatefulWidget {
  const _StateSelectionSheet({
    required this.stateList,
    required this.selectedStateId,
    required this.onStateSelected,
  });

  final List<StateListData> stateList;
  final int? selectedStateId;
  final ValueChanged<StateListData> onStateSelected;

  @override
  State<_StateSelectionSheet> createState() => _StateSelectionSheetState();
}

class _StateSelectionSheetState extends State<_StateSelectionSheet> {
  late final TextEditingController _searchController;
  late List<StateListData> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = List.from(widget.stateList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 2.5.h,
          left: 5.w,
          right: 5.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(bottom: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select state of residence',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: const Color(0xFF94A3B8), size: 5.w),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(fontSize: FontSize.s11, color: const Color(0xFF0F172A)),
                      cursorColor: const Color(0xFF0F7B6C),
                      decoration: InputDecoration(
                        hintText: 'Search state',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(fontSize: FontSize.s10, color: const Color(0xFF94A3B8)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtered = widget.stateList
                              .where((s) => (s.name ?? '').toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No states match your search.',
                        style: GoogleFonts.poppins(fontSize: FontSize.s10, color: const Color(0xFF64748B)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFE2E8F0), height: 1),
                      itemBuilder: (context, index) {
                        final state = _filtered[index];
                        final isSelected = state.id == widget.selectedStateId;
                        return ListTile(
                          title: Text(
                            state.name ?? '',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected ? const Color(0xFF0F7B6C) : const Color(0xFF0F172A),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0F7B6C))
                              : null,
                          onTap: () {
                            widget.onStateSelected(state);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
