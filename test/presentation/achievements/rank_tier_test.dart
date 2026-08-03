import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/achievements/achievements_models.dart";

void main() {
  test("maps levels to tiers and clamps beyond the last one", () {
    expect(RankTierX.forLevel(1), RankTier.bronze);
    expect(RankTierX.forLevel(2), RankTier.silver);
    expect(RankTierX.forLevel(3), RankTier.gold);
    expect(RankTierX.forLevel(4), RankTier.platinum);
    expect(RankTierX.forLevel(5), RankTier.diamond);
    expect(RankTierX.forLevel(12), RankTier.diamond);
  });

  test("falls back to the first tier below the minimum level", () {
    expect(RankTierX.forLevel(0), RankTier.bronze);
  });

  test("tier minimum levels are strictly increasing", () {
    final List<int> minLevels = RankTier.values
        .map((tier) => tier.minLevel)
        .toList();
    for (int index = 1; index < minLevels.length; index++) {
      expect(minLevels[index], greaterThan(minLevels[index - 1]));
    }
  });
}
