import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/actor_stats.dart';
import '../../data/models/equipment_data.dart';
import '../../game/systems/equipment_system.dart';

/// 장비 관리 화면
class EquipmentScreen extends StatefulWidget {
  final EquipmentSystem equipmentSystem;

  const EquipmentScreen({
    super.key,
    required this.equipmentSystem,
  });

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> with SingleTickerProviderStateMixin {
  late TabController mTabController;
  EquipmentSlot mSelectedSlot = EquipmentSlot.weapon;
  EquipmentInstance? mSelectedEquipment;

  @override
  void initState() {
    super.initState();
    mTabController = TabController(length: 3, vsync: this);
    mTabController.addListener(() {
      setState(() {
        mSelectedSlot = EquipmentSlot.values[mTabController.index];
        mSelectedEquipment = null;
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
        title: const Text('장비 관리'),
        bottom: TabBar(
          controller: mTabController,
          tabs: EquipmentSlot.values.map((slot) {
            return Tab(
              text: '${slot.icon} ${slot.displayName}',
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // 현재 장착 장비
          _buildEquippedSection(),

          const Divider(height: 1, color: Colors.white24),

          // 인벤토리
          Expanded(
            child: _buildInventorySection(),
          ),

          // 선택된 장비 상세 정보
          if (mSelectedEquipment != null) _buildDetailPanel(),
        ],
      ),
    );
  }

  /// 장착 중인 장비 섹션
  Widget _buildEquippedSection() {
    final equipped = widget.equipmentSystem.GetEquipped(mSelectedSlot);

    return Container(
      padding: const EdgeInsets.all(16),
      color: DesignConstants.COLOR_SURFACE,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장착 중: ${mSelectedSlot.displayName}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: DesignConstants.FONT_SIZE_MEDIUM,
            ),
          ),
          const SizedBox(height: 8),
          if (equipped != null)
            _buildEquipmentCard(equipped, isEquipped: true)
          else
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '장착된 장비 없음',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 인벤토리 섹션
  Widget _buildInventorySection() {
    final inventory = widget.equipmentSystem.GetInventoryBySlot(mSelectedSlot);

    if (inventory.isEmpty) {
      return const Center(
        child: Text(
          '보유 장비 없음',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildEquipmentCard(inventory[index]),
        );
      },
    );
  }

  /// 장비 카드 위젯
  Widget _buildEquipmentCard(EquipmentInstance equipment, {bool isEquipped = false}) {
    final isSelected = mSelectedEquipment == equipment;
    final rarityColor = equipment.data.rarity.color;

    return GestureDetector(
      onTap: () {
        setState(() {
          mSelectedEquipment = equipment;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? rarityColor.withValues(alpha: 0.2) : Colors.white10,
          border: Border.all(
            color: isSelected ? rarityColor : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 등급 표시
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  equipment.data.slot.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 이름 및 레벨
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        equipment.data.name,
                        style: TextStyle(
                          color: rarityColor,
                          fontSize: DesignConstants.FONT_SIZE_MEDIUM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (equipment.isEquipped)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '장착',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${equipment.data.rarity.displayName} | Lv.${equipment.level}/${equipment.GetMaxLevel()}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: DesignConstants.FONT_SIZE_SMALL,
                    ),
                  ),
                ],
              ),
            ),

            // 스탯 미리보기
            _buildStatPreview(equipment.GetCurrentStats()),
          ],
        ),
      ),
    );
  }

  /// 스탯 미리보기
  Widget _buildStatPreview(ActorStats stats) {
    final List<String> statTexts = [];
    if (stats.atk > 0) statTexts.add('ATK+${stats.atk}');
    if (stats.def > 0) statTexts.add('DEF+${stats.def}');
    if (stats.hp > 0) statTexts.add('HP+${stats.hp}');
    if (stats.spd != 0) statTexts.add('SPD+${stats.spd.toStringAsFixed(1)}');
    if (stats.critRate > 0) statTexts.add('CRIT+${stats.critRate.toStringAsFixed(0)}%');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: statTexts.take(2).map((text) {
        return Text(
          text,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: DesignConstants.FONT_SIZE_SMALL,
          ),
        );
      }).toList(),
    );
  }

  /// 상세 정보 패널
  Widget _buildDetailPanel() {
    final equipment = mSelectedEquipment!;
    final stats = equipment.GetCurrentStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: DesignConstants.COLOR_SURFACE,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 및 등급
          Row(
            children: [
              Text(
                equipment.data.name,
                style: TextStyle(
                  color: equipment.data.rarity.color,
                  fontSize: DesignConstants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Lv.${equipment.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: DesignConstants.FONT_SIZE_LARGE,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 설명
          Text(
            equipment.data.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: DesignConstants.FONT_SIZE_SMALL,
            ),
          ),

          const SizedBox(height: 12),

          // 스탯 그리드
          _buildStatsGrid(stats),

          const SizedBox(height: 16),

          // 액션 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: equipment.isEquipped ? null : () => _equipItem(equipment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: equipment.isEquipped ? Colors.grey : DesignConstants.COLOR_PRIMARY,
                  ),
                  child: Text(equipment.isEquipped ? '장착 중' : '장착하기'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: equipment.CanUpgrade() ? () => _upgradeItem(equipment) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('강화'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 스탯 그리드
  Widget _buildStatsGrid(ActorStats stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (stats.hp != 0) _buildStatChip('HP', '+${stats.hp}', Colors.red),
        if (stats.atk != 0) _buildStatChip('ATK', '+${stats.atk}', Colors.orange),
        if (stats.def != 0) _buildStatChip('DEF', '+${stats.def}', Colors.blue),
        if (stats.spd != 0) _buildStatChip('SPD', '+${stats.spd.toStringAsFixed(1)}', Colors.green),
        if (stats.critRate != 0) _buildStatChip('CRIT', '+${stats.critRate.toStringAsFixed(0)}%', Colors.yellow),
        if (stats.critDmg != 0) _buildStatChip('CDMG', '+${stats.critDmg.toStringAsFixed(0)}%', Colors.purple),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _equipItem(EquipmentInstance equipment) {
    widget.equipmentSystem.Equip(equipment);
    setState(() {});
  }

  void _upgradeItem(EquipmentInstance equipment) {
    widget.equipmentSystem.UpgradeEquipment(equipment);
    setState(() {});
  }
}
