import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/challenge_data.dart';
import '../../game/systems/challenge_system.dart';

/// 도전 선택 화면
class ChallengeScreen extends StatefulWidget {
  final ChallengeSystem challengeSystem;
  final void Function(String challengeId) onChallengeSelected;

  const ChallengeScreen({
    super.key,
    required this.challengeSystem,
    required this.onChallengeSelected,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> with SingleTickerProviderStateMixin {
  late TabController mTabController;
  ChallengeType mSelectedType = ChallengeType.endless;

  @override
  void initState() {
    super.initState();
    mTabController = TabController(length: ChallengeType.values.length, vsync: this);
    mTabController.addListener(() {
      setState(() {
        mSelectedType = ChallengeType.values[mTabController.index];
      });
    });
  }

  @override
  void dispose() {
    mTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      appBar: AppBar(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Text('도전 모드'),
        bottom: TabBar(
          controller: mTabController,
          isScrollable: true,
          tabs: ChallengeType.values.map((type) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, size: 16, color: type.color),
                  const SizedBox(width: 4),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // 도전 타입 설명
          _buildTypeDescription(),

          // 도전 목록
          Expanded(
            child: _buildChallengeList(),
          ),
        ],
      ),
    );
  }

  /// 도전 타입 설명
  Widget _buildTypeDescription() {
    String description;
    switch (mSelectedType) {
      case ChallengeType.endless:
        description = '끝없이 밀려오는 적들을 상대하세요. 최대한 많은 웨이브를 버텨보세요!';
        break;
      case ChallengeType.timeAttack:
        description = '제한된 시간 내에 최대한 많은 적을 처치하세요!';
        break;
      case ChallengeType.survival:
        description = '강화된 적들 사이에서 생존하세요. 제한 시간을 버텨야 합니다!';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: mSelectedType.color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(mSelectedType.icon, color: mSelectedType.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: mSelectedType.color,
                fontSize: DesignConstants.FONT_SIZE_SMALL,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 도전 목록
  Widget _buildChallengeList() {
    final challenges = DefaultChallenges.GetByType(mSelectedType);

    if (challenges.isEmpty) {
      return const Center(
        child: Text(
          '준비 중인 도전입니다',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChallengeCard(challenges[index]),
        );
      },
    );
  }

  /// 도전 카드
  Widget _buildChallengeCard(ChallengeData challenge) {
    final status = widget.challengeSystem.GetStatus(challenge);
    final record = widget.challengeSystem.GetRecord(challenge.id);
    final isLocked = status == ChallengeStatus.locked;
    final isCleared = status == ChallengeStatus.cleared;

    return GestureDetector(
      onTap: isLocked ? null : () => _showChallengeDetail(challenge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey.withValues(alpha: 0.2)
              : challenge.type.color.withValues(alpha: 0.1),
          border: Border.all(
            color: isLocked
                ? Colors.grey
                : isCleared
                    ? Colors.greenAccent
                    : challenge.type.color,
            width: isCleared ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 이름 + 난이도
            Row(
              children: [
                // 잠금/클리어 아이콘
                if (isLocked)
                  const Icon(Icons.lock, color: Colors.grey, size: 20)
                else if (isCleared)
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
                else
                  Icon(challenge.type.icon, color: challenge.type.color, size: 20),

                const SizedBox(width: 8),

                // 이름
                Expanded(
                  child: Text(
                    challenge.name,
                    style: TextStyle(
                      color: isLocked ? Colors.grey : Colors.white,
                      fontSize: DesignConstants.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 난이도 별
                Row(
                  children: List.generate(
                    challenge.difficulty.stars,
                    (i) => Icon(
                      Icons.star,
                      color: isLocked ? Colors.grey : challenge.difficulty.color,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 설명
            Text(
              challenge.description,
              style: TextStyle(
                color: isLocked ? Colors.grey : Colors.white70,
                fontSize: DesignConstants.FONT_SIZE_SMALL,
              ),
            ),

            const SizedBox(height: 12),

            // 클리어 조건
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: isLocked ? Colors.grey : Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  challenge.condition.GetDescription(),
                  style: TextStyle(
                    color: isLocked ? Colors.grey : Colors.amber,
                    fontSize: DesignConstants.FONT_SIZE_SMALL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // 최고 기록 (클리어/플레이 기록이 있을 때)
            if (record != null) ...[
              const SizedBox(height: 8),
              _buildRecordRow(challenge, record),
            ],

            // 잠금 조건
            if (isLocked) ...[
              const SizedBox(height: 8),
              _buildUnlockCondition(challenge),
            ],
          ],
        ),
      ),
    );
  }

  /// 기록 표시
  Widget _buildRecordRow(ChallengeData challenge, ChallengeRecord record) {
    String bestText;
    switch (challenge.type) {
      case ChallengeType.endless:
        bestText = '최고 웨이브: ${record.bestWave}';
        break;
      case ChallengeType.timeAttack:
        bestText = '최고 처치: ${record.bestKills}';
        break;
      case ChallengeType.survival:
        bestText = '최고 생존: ${record.bestTime}초';
        break;
    }

    return Row(
      children: [
        const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 14),
        const SizedBox(width: 4),
        Text(
          bestText,
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: DesignConstants.FONT_SIZE_SMALL,
          ),
        ),
        if (record.isCleared && record.clearedAt != null) ...[
          const Spacer(),
          Text(
            '클리어: ${_formatDate(record.clearedAt!)}',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: DesignConstants.FONT_SIZE_SMALL,
            ),
          ),
        ],
      ],
    );
  }

  /// 잠금 조건 표시
  Widget _buildUnlockCondition(ChallengeData challenge) {
    final List<String> conditions = [];

    if (widget.challengeSystem.playerLevel < challenge.unlockLevel) {
      conditions.add('레벨 ${challenge.unlockLevel} 필요');
    }

    if (challenge.prerequisiteId != null) {
      final prereq = DefaultChallenges.GetById(challenge.prerequisiteId!);
      if (prereq != null) {
        conditions.add('${prereq.name} 클리어 필요');
      }
    }

    return Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.grey, size: 14),
        const SizedBox(width: 4),
        Text(
          conditions.join(' / '),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: DesignConstants.FONT_SIZE_SMALL,
          ),
        ),
      ],
    );
  }

  /// 도전 상세/시작 다이얼로그
  void _showChallengeDetail(ChallengeData challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: Row(
          children: [
            Icon(challenge.type.icon, color: challenge.type.color),
            const SizedBox(width: 8),
            Text(
              challenge.name,
              style: TextStyle(color: challenge.type.color),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명
              Text(
                challenge.description,
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 16),

              // 클리어 조건
              const Text(
                '클리어 조건',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                challenge.condition.GetDescription(),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 16),

              // 변경자 (난이도 조절)
              if (challenge.modifier.GetModifierTexts().isNotEmpty) ...[
                const Text(
                  '난이도 변경',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...challenge.modifier.GetModifierTexts().map((text) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(text, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // 보상
              const Text(
                '클리어 보상',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...challenge.rewards.map((reward) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(_getRewardIcon(reward.type), color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _getRewardText(reward),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);  // 다이얼로그 닫기
              Navigator.pop(context);  // 도전 선택 화면 닫기
              widget.onChallengeSelected(challenge.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: challenge.type.color,
            ),
            child: const Text('도전 시작', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(ChallengeRewardType type) {
    switch (type) {
      case ChallengeRewardType.gold:
        return Icons.monetization_on;
      case ChallengeRewardType.gem:
        return Icons.diamond;
      case ChallengeRewardType.equipment:
        return Icons.shield;
      case ChallengeRewardType.exp:
        return Icons.trending_up;
    }
  }

  String _getRewardText(ChallengeReward reward) {
    switch (reward.type) {
      case ChallengeRewardType.gold:
        return '${reward.amount} 골드';
      case ChallengeRewardType.gem:
        return '${reward.amount} 보석';
      case ChallengeRewardType.equipment:
        return '장비 1개';
      case ChallengeRewardType.exp:
        return '${reward.amount} 경험치';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
