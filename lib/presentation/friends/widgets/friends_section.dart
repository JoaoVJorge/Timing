import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/friend_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/friends/widgets/friends_shared.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";

class FriendsSection extends StatelessWidget {
  const FriendsSection({
    required this.friends,
    required this.onShare,
    required this.onRemove,
    super.key,
  });

  final List<FriendEntity> friends;
  final VoidCallback onShare;
  final ValueChanged<FriendEntity> onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        title: _title(context, friends.length),
        action: friends.length > 5 ? _seeAll(context) : null,
      ),
      const Gap(12),
      if (friends.isEmpty)
        _EmptyFriendsCard(onShare: onShare)
      else
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.colorTokens.surfaceShadow.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Column(
            children: [
              for (int index = 0; index < friends.length; index++) ...[
                _FriendRow(
                  profile: friends[index],
                  index: index,
                  onRemove: () => onRemove(friends[index]),
                ),
                if (index < friends.length - 1)
                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 14,
                    color: context.colorTokens.divider,
                  ),
              ],
            ],
          ),
        ),
    ],
  );

  String _title(BuildContext context, int count) =>
      switch (context.languageCode) {
        "es" => "Tus amigos ($count)",
        "pt" => "Seus amigos ($count)",
        _ => "Your friends ($count)",
      };

  String _seeAll(BuildContext context) => switch (context.languageCode) {
    "es" => "Ver todos",
    "pt" => "Ver todos",
    _ => "View all",
  };
}

class _FriendRow extends StatefulWidget {
  const _FriendRow({
    required this.profile,
    required this.index,
    required this.onRemove,
  });

  final FriendEntity profile;
  final int index;
  final VoidCallback onRemove;

  @override
  State<_FriendRow> createState() => _FriendRowState();
}

class _FriendRowState extends State<_FriendRow>
    with SingleTickerProviderStateMixin {
  static const double _revealWidth = 72;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: -_revealWidth,
    upperBound: 0,
    value: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value = (_controller.value + details.delta.dx).clamp(
      -_revealWidth,
      0,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final double target = _controller.value < -_revealWidth / 2
        ? -_revealWidth
        : 0;
    _controller.animateTo(target, curve: Curves.easeOutCubic);
  }

  void _onTapDelete() {
    _controller.animateTo(0, curve: Curves.easeOutCubic);
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Stack(
      children: [
        if (_controller.value < 0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _onTapDelete,
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorTokens.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: context.colorTokens.primaryForeground,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Transform.translate(
            offset: Offset(_controller.value, 0),
            child: child,
          ),
        ),
      ],
    ),
    child: Container(
      color: context.colorTokens.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          GroupMemberAvatar(
            name: widget.profile.name,
            colorValue: widget.profile.colorValue,
            size: 40,
          ),
          const Gap(10),
          Expanded(
            child: FriendNameBlock(
              name: widget.profile.name,
              handle: widget.profile.handle,
            ),
          ),
          const Gap(10),
          _FriendStatusChip(
            label: _statusLabel(context, widget.index),
            index: widget.index,
          ),
        ],
      ),
    ),
  );

  String _statusLabel(BuildContext context, int index) {
    if (index < 2) {
      return "Online";
    }
    return switch (context.languageCode) {
      "es" => "Hace ${index + 1} min",
      "pt" => "Há ${index + 1} min",
      _ => "${index + 1} min ago",
    };
  }
}

class _FriendStatusChip extends StatelessWidget {
  const _FriendStatusChip({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color color = index < 2
        ? context.colorTokens.success
        : context.colorTokens.textHint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyFriendsCard extends StatelessWidget {
  const _EmptyFriendsCard({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Column(
      children: [
        Container(
          width: 88,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            Icons.diversity_3_rounded,
            color: context.colorTokens.primary,
            size: 42,
          ),
        ),
        const Gap(14),
        Text(
          _emptyTitle(context),
          textAlign: TextAlign.center,
          style: context.textStyles.extraBold20.copyWith(
            color: context.colorTokens.textBody,
            fontSize: 17,
          ),
        ),
        const Gap(6),
        Text(
          _emptySubtitle(context),
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textHint,
            height: 1.28,
          ),
        ),
        const Gap(18),
        FriendShareButton(onTap: onShare, label: _shareLabel(context)),
      ],
    ),
  );

  String _emptyTitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Aún no tienes amigos",
    "pt" => "Você ainda não tem amigos",
    _ => "You do not have friends yet",
  };

  String _emptySubtitle(BuildContext context) => switch (context.languageCode) {
    "es" => "Busca personas arriba o comparte tu código de invitación.",
    "pt" => "Busque pessoas acima ou compartilhe seu código de convite.",
    _ => "Search people above or share your invite code.",
  };

  String _shareLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Compartir código",
    "pt" => "Compartilhar código",
    _ => "Share code",
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (action != null)
        Text(
          action!,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
    ],
  );
}
