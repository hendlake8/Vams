import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/equipment_data.dart';
import '../../data/models/progress_data.dart';
import '../../data/models/skill_data.dart';
import '../../game/systems/progress_system.dart';

/// 장비 관리 화면 (로비용 - ProgressSystem 사용)
class EquipmentManagementScreen extends StatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  State<EquipmentManagementScreen> createState() => _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen> {
  EquipmentSlot mSelectedSlot = EquipmentSlot.weapon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      appBar: AppBar(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Text('장비 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 슬롯 탭
            _buildSlotTabs(),

            // 장착된 장비 표시
            _buildEquippedSection(),

            const Divider(color: Colors.white24, height: 1),

            // 하단: 인벤토리
            Expanded(
              child: _buildInventorySection(),
            ),
          ],
        ),
      ),
    );
  }

  /// 슬롯 탭
  Widget _buildSlotTabs() {
    return Container(
      color: DesignConstants.COLOR_SURFACE,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: EquipmentSlot.values.map((slot) {
          final isSelected = slot == mSelectedSlot;
          return GestureDetector(
            onTap: () => setState(() => mSelectedSlot = slot),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? DesignConstants.COLOR_PRIMARY.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: DesignConstants.COLOR_PRIMARY, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSlotIcon(slot),
                    color: isSelected ? DesignConstants.COLOR_PRIMARY : Colors.white54,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSlotName(slot),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 장착된 장비 섹션
  Widget _buildEquippedSection() {
    final progress = ProgressSystem.instance;
    final equippedInstance = progress.GetEquippedItem(mSelectedSlot);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장착 중',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (equippedInstance != null)
            _buildEquipmentCard(equippedInstance, isEquipped: true)
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white38, size: 32),
                  SizedBox(width: 12),
                  Text(
                    '장비가 장착되지 않음',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 인벤토리 섹션
  Widget _buildInventorySection() {
    final progress = ProgressSystem.instance;
    final inventory = progress.equipmentInventory;

    // 현재 슬롯에 맞는 장비만 필터링
    final filteredInventory = inventory.where((instance) {
      final equipData = DefaultEquipments.GetById(instance.equipmentId);
      return equipData?.slot == mSelectedSlot;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '인벤토리',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${filteredInventory.length})',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredInventory.isEmpty
                ? const Center(
                    child: Text(
                      '해당 슬롯의 장비가 없습니다.',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredInventory.length,
                    itemBuilder: (context, index) {
                      final instance = filteredInventory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildEquipmentCard(instance, isEquipped: false),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 장비 카드
  Widget _buildEquipmentCard(EquipmentInstanceData instance, {required bool isEquipped}) {
    final equipData = DefaultEquipments.GetById(instance.equipmentId);
    if (equipData == null) return const SizedBox();

    final rarityColor = _getRarityColor(equipData.rarity);
    final skillData = equipData.skillId != null
        ? DefaultSkills.GetById(equipData.skillId!)
        : null;

    return GestureDetector(
      onTap: isEquipped ? null : () => _equipItem(instance),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rarityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped
                ? DesignConstants.COLOR_PRIMARY
                : rarityColor.withValues(alpha: 0.5),
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSlotIcon(equipData.slot),
                color: rarityColor,
                size: 32,
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
                      Expanded(
                        child: Text(
                          equipData.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lv.${instance.level}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 스탯 표시
                  _buildStatsRow(equipData.stats, instance.level),
                  if (skillData != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '스킬: ${skillData.name}',
                      style: TextStyle(
                        color: skillData.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 액션 버튼
            if (isEquipped)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _unequipItem(),
              )
            else
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => _equipItem(instance),
              ),
          ],
        ),
      ),
    );
  }

  /// 스탯 표시 행
  Widget _buildStatsRow(EquipmentStats stats, int level) {
    final multiplier = 1.0 + (level - 1) * 0.1;
    final statsList = <Widget>[];

    if (stats.hp > 0) {
      statsList.add(_buildStatChip('HP', '+${(stats.hp * multiplier).round()}', Colors.green));
    }
    if (stats.atk > 0) {
      statsList.add(_buildStatChip('ATK', '+${(stats.atk * multiplier).round()}', Colors.red));
    }
    if (stats.def > 0) {
      statsList.add(_buildStatChip('DEF', '+${(stats.def * multiplier).round()}', Colors.blue));
    }

    return Wrap(
      spacing: 8,
      children: statsList,
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }

  /// 장비 장착
  void _equipItem(EquipmentInstanceData instance) async {
    await ProgressSystem.instance.EquipItem(instance.instanceId, mSelectedSlot);
    setState(() {});
  }

  /// 장비 해제
  void _unequipItem() async {
    await ProgressSystem.instance.UnequipItem(mSelectedSlot);
    setState(() {});
  }

  IconData _getSlotIcon(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return Icons.bolt;
      case EquipmentSlot.armor:
        return Icons.shield;
      case EquipmentSlot.accessory:
        return Icons.stars;
    }
  }

  String _getSlotName(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:
        return '무기';
      case EquipmentSlot.armor:
        return '방어구';
      case EquipmentSlot.accessory:
        return '장신구';
    }
  }

  Color _getRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return Colors.grey;
      case EquipmentRarity.uncommon:
        return Colors.green;
      case EquipmentRarity.rare:
        return Colors.blue;
      case EquipmentRarity.epic:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.orange;
    }
  }
}
