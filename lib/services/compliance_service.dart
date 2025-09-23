import '../models/shift.dart';

class ComplianceService {
  // Simple compliance score out of 100.
  // -10 for each overlap, -5 for each unconfirmed shift, min 0, max 100.
  static int score(final List<Shift> shifts) {
    int s = 100;
    for (int i = 0; i < shifts.length; i++) {
      for (int j = i + 1; j < shifts.length; j++) {
        if (shifts[i].overlaps(shifts[j])) s -= 10;
      }
      if (!shifts[i].confirmed) s -= 5;
    }
    return s.clamp(0, 100);
  }
}

