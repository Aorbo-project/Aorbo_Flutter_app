int resolveRequiredTravelerCount({
  required int currentRequiredCount,
  required int selectedCount,
}) {
  if (selectedCount <= 0) {
    return currentRequiredCount;
  }

  return selectedCount > currentRequiredCount ? selectedCount : currentRequiredCount;
}
