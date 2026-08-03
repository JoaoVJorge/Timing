import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/achievements/achievements_models.dart";

void main() {
  test("maps levels to tiers and clamps beyond the last one", () {
    expect(RankTierX.forLevel(1), RankTier.paper);
    expect(RankTierX.forLevel(2), RankTier.wood);
    expect(RankTierX.forLevel(3), RankTier.stone);
    expect(RankTierX.forLevel(4), RankTier.copper);
    expect(RankTierX.forLevel(5), RankTier.bronze);
    expect(RankTierX.forLevel(6), RankTier.iron);
    expect(RankTierX.forLevel(7), RankTier.silver);
    expect(RankTierX.forLevel(8), RankTier.gold);
    expect(RankTierX.forLevel(9), RankTier.platinum);
    expect(RankTierX.forLevel(10), RankTier.amethyst);
    expect(RankTierX.forLevel(11), RankTier.emerald);
    expect(RankTierX.forLevel(12), RankTier.diamond);
    expect(RankTierX.forLevel(13), RankTier.obsidian);
    expect(RankTierX.forLevel(14), RankTier.adamantium);
    expect(RankTierX.forLevel(15), RankTier.mithril);
    expect(RankTierX.forLevel(20), RankTier.mithril);
  });

  test("falls back to the first tier below the minimum level", () {
    expect(RankTierX.forLevel(0), RankTier.paper);
  });

  test("has fifteen tiers", () {
    expect(RankTier.values, hasLength(15));
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
