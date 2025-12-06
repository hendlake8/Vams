import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/patrol_data.dart';
import '../../game/systems/progress_system.dart';

/// 순찰 화면 (방치형 보상)
class PatrolScreen extends StatefulWidget {
  const PatrolScreen({super.key});

  @override
  State<PatrolScreen> createState() => _PatrolScreenState();
}

class _PatrolScreenState extends State<PatrolScreen> {
  Timer? mUpdateTimer;

  @override
  void initState() {
    super.initState();
    // 1초마다 UI 업데이트 (보상 계산용)
    mUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    mUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressSystem.instance;

    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      appBar: AppBar(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Text('순찰'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 현재 순찰 상태
            _buildCurrentPatrolSection(progress),

            const Divider(color: Colors.white24, height: 1),

            // 보상 수령 버튼
            if (progress.isPatrolling) _buildRewardSection(progress),

            const Divider(color: Colors.white24, height: 1),

            // 순찰 지역 목록
            Expanded(
              child: _buildZoneList(progress),
            ),
          ],
        ),
      ),
    );
  }

  /// 현재 순찰 상태 섹션
  Widget _buildCurrentPatrolSection(ProgressSystem progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: DesignConstants.COLOR_SURFACE,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text(
                '현재 순찰',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (progress.isPatrolling)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 6),
                      Text(
                        '순찰 중',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (progress.isPatrolling) ...[
            _buildActivePatrolCard(progress),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white38, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '순찰 지역을 선택하여 순찰을 시작하세요.\n오프라인 중에도 보상이 쌓입니다!',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 활성 순찰 카드
  Widget _buildActivePatrolCard(ProgressSystem progress) {
    final zone = progress.activePatrolZone!;
    final zoneData = DefaultPatrolZones.GetByZone(zone);
    if (zoneData == null) return const SizedBox();

    final minutes = progress.patrol.GetMinutesSinceLastCollect();
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                zone.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoneData.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '경과 시간: ${hours > 0 ? '$hours시간 ' : ''}$mins분',
                  style: const TextStyle(color: Colors.amber, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRewardChip(Icons.monetization_on, '${zoneData.goldPerMinute}/분', Colors.amber),
                    const SizedBox(width: 8),
                    _buildRewardChip(Icons.star, '${zoneData.expPerMinute}/분', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          // 중지 버튼
          IconButton(
            onPressed: () async {
              await progress.StopPatrol();
              setState(() {});
            },
            icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  /// 보상 수령 섹션
  Widget _buildRewardSection(ProgressSystem progress) {
    final rewards = progress.CalculatePatrolRewards();

    return Container(
      padding: const EdgeInsets.all(16),
      color: DesignConstants.COLOR_SURFACE.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대기 중인 보상',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 골드
              Expanded(
                child: _buildRewardDisplay(
                  Icons.monetization_on,
                  '${rewards.gold}',
                  Colors.amber,
                  '골드',
                ),
              ),
              // 경험치
              Expanded(
                child: _buildRewardDisplay(
                  Icons.star,
                  '${rewards.exp}',
                  Colors.purple,
                  '경험치',
                ),
              ),
              // 장비
              Expanded(
                child: _buildRewardDisplay(
                  Icons.inventory_2,
                  '${rewards.equipmentIds.length}',
                  Colors.cyan,
                  '장비',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 수령 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: rewards.hasRewards
                  ? () async {
                      final result = await progress.CollectPatrolRewards();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '골드 ${result.gold}, 경험치 ${result.exp}, 장비 ${result.equipmentIds.length}개 획득!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {});
                      }
                    }
                  : null,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('보상 수령'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDisplay(IconData icon, String value, Color color, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  /// 순찰 지역 목록
  Widget _buildZoneList(ProgressSystem progress) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: PatrolZone.values.length,
      itemBuilder: (context, index) {
        final zone = PatrolZone.values[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildZoneCard(progress, zone),
        );
      },
    );
  }

  /// 순찰 지역 카드
  Widget _buildZoneCard(ProgressSystem progress, PatrolZone zone) {
    final zoneData = DefaultPatrolZones.GetByZone(zone);
    if (zoneData == null) return const SizedBox();

    final isUnlocked = progress.IsPatrolZoneUnlocked(zone);
    final isActive = progress.activePatrolZone == zone;

    return GestureDetector(
      onTap: isUnlocked && !isActive
          ? () => _showZoneDetailDialog(progress, zone, zoneData)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber.withValues(alpha: 0.15)
              : isUnlocked
                  ? DesignConstants.COLOR_SURFACE
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Colors.amber
                : isUnlocked
                    ? Colors.white24
                    : Colors.grey.withValues(alpha: 0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(zone.icon, style: const TextStyle(fontSize: 24))
                    : const Icon(Icons.lock, color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        zoneData.name,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '진행 중',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isUnlocked) ...[
                    Row(
                      children: [
                        _buildRewardChip(Icons.monetization_on, '${zoneData.goldPerMinute}/분', Colors.amber),
                        const SizedBox(width: 8),
                        _buildRewardChip(Icons.star, '${zoneData.expPerMinute}/분', Colors.purple),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Lv.${zoneData.unlockLevel} 해금',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            // 화살표 또는 잠금
            Icon(
              isUnlocked ? Icons.chevron_right : Icons.lock_outline,
              color: isUnlocked ? Colors.white54 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  /// 지역 상세 다이얼로그
  void _showZoneDetailDialog(ProgressSystem progress, PatrolZone zone, PatrolZoneData zoneData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(zone.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                zoneData.name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zoneData.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.monetization_on, '골드 획득량', '${zoneData.goldPerMinute}/분', Colors.amber),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.star, '경험치 획득량', '${zoneData.expPerMinute}/분', Colors.purple),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.inventory_2, '장비 드롭률', '${(zoneData.equipDropChance * 100).toInt()}%/시간', Colors.cyan),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (progress.isPatrolling) {
                await progress.ChangePatrolZone(zone);
              } else {
                await progress.StartPatrol(zone);
              }
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: Text(progress.isPatrolling ? '지역 변경' : '순찰 시작'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
