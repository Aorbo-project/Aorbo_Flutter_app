import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/utils/screen_constants.dart';

/// "Select state of residence" bottom sheet — shared by every screen that
/// needs a state picker (booking traveller info, account profile edit).
/// Operates on [StateListData] objects directly rather than name strings,
/// so callers never need a separate name->id re-lookup after selection.
/// No search box — the list is short (~32 states) and a focused TextField
/// being torn down mid-pop was itself a source of framework assertion
/// crashes, so plain scroll is both simpler and more robust here.
Future<void> showStateSelectionBottomSheet({
  required BuildContext context,
  required List<StateListData> stateList,
  required int? selectedStateId,
  required ValueChanged<StateListData> onStateSelected,
}) async {
  // The selected state is returned THROUGH Navigator.pop's result rather
  // than invoked directly from the ListTile's onTap. Calling a callback
  // that triggers the CALLER's setState/setModalState synchronously while
  // this sheet's route is still mid-pop rebuilds the parent tree before
  // this route's elements finish deactivating, which trips
  // InheritedElement.debugDeactivated's `_dependents.isEmpty` assertion
  // (framework.dart). Awaiting the pop first guarantees this sheet is
  // fully torn down before onStateSelected ever runs.
  final selected = await showModalBottomSheet<StateListData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
    ),
    builder: (sheetContext) {
      return SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.75,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.separated(
                  itemCount: stateList.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFFE2E8F0), height: 1),
                  itemBuilder: (context, index) {
                    final state = stateList[index];
                    final isSelected = state.id == selectedStateId;
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
                      onTap: () => Navigator.pop(sheetContext, state),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  // Runs only after the sheet's route has fully finished popping.
  if (selected != null) {
    onStateSelected(selected);
  }
}
