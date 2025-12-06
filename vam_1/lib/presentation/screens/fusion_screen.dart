import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/equipment_data.dart';
import '../../game/systems/equipment_system.dart';

/// 장비 합성 화면
class FusionScreen extends StatefulWidget {
  final EquipmentSystem equipmentSystem;

  const FusionScreen({
    super.key,
    required this.equipmentSystem,
  });

  @override
  State<FusionScreen> createState() => _FusionScreenState();
}

class _FusionScreenState extends State<FusionScreen> {
  // 선택된 재료 장비 (최대 3개)
  final List<EquipmentInstance> mSelectedMaterials = [];

  // 현재 선택 중인 슬롯/등급 필터
  EquipmentSlot? mFilterSlot;
  EquipmentRarity? mFilterRarity;

  // 합성 결과 (성공 시)
  EquipmentInstance? mFusionResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      appBar: AppBar(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Text('장비 합성'),
      ),
      body: Column(
        children: [
          // 합성 슬롯 영역
          _buildFusionSlots(),

          const Divider(height: 1, color: Colors.white24),

          // 합성 버튼
          _buildFusionButton(),

          const Divider(height: 1, color: Colors.white24),

          // 재료 선택 영역
          Expanded(
            child: _buildMaterialSelection(),
          ),
        ],
      ),
    );
  }

  /// 합성 슬롯 UI (3개 재료 + 결과)
  Widget _buildFusionSlots() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: DesignConstants.COLOR_SURFACE,
      child: Column(
        children: [
          const Text(
            '동일 등급 장비 3개 → 상위 등급 1개',
            style: TextStyle(
              color: Colors.white70,
              fontSize: DesignConstants.FONT_SIZE_SMALL,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 재료 슬롯 1
              _buildMaterialSlot(0),
              const SizedBox(width: 8),
              const Text('+', style: TextStyle(color: Colors.white54, fontSize: 20)),
              const SizedBox(width: 8),
              // 재료 슬롯 2
              _buildMaterialSlot(1),
              const SizedBox(width: 8),
              const Text('+', style: TextStyle(color: Colors.white54, fontSize: 20)),
              const SizedBox(width: 8),
              // 재료 슬롯 3
              _buildMaterialSlot(2),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: Colors.amber, size: 24),
              const SizedBox(width: 16),
              // 결과 슬롯
              _buildResultSlot(),
            ],
          ),
        ],
      ),
    );
  }

  /// 재료 슬롯
  Widget _buildMaterialSlot(int index) {
    final hasMaterial = index < mSelectedMaterials.length;
    final material = hasMaterial ? mSelectedMaterials[index] : null;

    return GestureDetector(
      onTap: hasMaterial
          ? () {
              setState(() {
                mSelectedMaterials.removeAt(index);
                mFusionResult = null;
                _updateFilter();
              });
            }
          : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: hasMaterial
              ? material!.data.rarity.color.withValues(alpha: 0.3)
              : Colors.white10,
          border: Border.all(
            color: hasMaterial ? material!.data.rarity.color : Colors.white24,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: hasMaterial
            ? Stack(
                children: [
                  Center(
                    child: Text(
                      material!.data.slot.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  // 제거 버튼
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.white24,
                  size: 24,
                ),
              ),
      ),
    );
  }

  /// 결과 슬롯
  Widget _buildResultSlot() {
    final hasResult = mFusionResult != null;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: hasResult
            ? mFusionResult!.data.rarity.color.withValues(alpha: 0.3)
            : Colors.amber.withValues(alpha: 0.1),
        border: Border.all(
          color: hasResult ? mFusionResult!.data.rarity.color : Colors.amber,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasResult
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mFusionResult!.data.slot.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  mFusionResult!.data.rarity.displayName,
                  style: TextStyle(
                    color: mFusionResult!.data.rarity.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  /// 합성 버튼
  Widget _buildFusionButton() {
    final canFuse = mSelectedMaterials.length == 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canFuse && mFusionResult == null ? _performFusion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            mFusionResult != null ? '합성 완료!' : '합성하기 (3개 필요)',
            style: const TextStyle(
              fontSize: DesignConstants.FONT_SIZE_MEDIUM,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// 재료 선택 영역
  Widget _buildMaterialSelection() {
    // 합성 가능한 장비만 필터링
    List<EquipmentInstance> availableItems = widget.equipmentSystem.inventory
        .where((e) =>
            !e.isEquipped &&
            e.data.rarity != EquipmentRarity.legendary &&
            !mSelectedMaterials.contains(e))
        .toList();

    // 필터 적용
    if (mFilterSlot != null) {
      availableItems = availableItems.where((e) => e.data.slot == mFilterSlot).toList();
    }
    if (mFilterRarity != null) {
      availableItems = availableItems.where((e) => e.data.rarity == mFilterRarity).toList();
    }

    // 등급별 그룹화
    final Map<EquipmentRarity, List<EquipmentInstance>> groupedItems = {};
    for (final item in availableItems) {
      groupedItems.putIfAbsent(item.data.rarity, () => []);
      groupedItems[item.data.rarity]!.add(item);
    }

    if (availableItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 48),
            const SizedBox(height: 16),
            Text(
              mFilterSlot != null || mFilterRarity != null
                  ? '조건에 맞는 장비가 없습니다'
                  : '합성 가능한 장비가 없습니다',
              style: const TextStyle(color: Colors.white38, fontSize: 16),
            ),
            if (mFilterSlot != null || mFilterRarity != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    mFilterSlot = null;
                    mFilterRarity = null;
                  });
                },
                child: const Text('필터 초기화'),
              ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: groupedItems.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 등급 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key.displayName} (${entry.value.length}개)',
                    style: TextStyle(
                      color: entry.key.color,
                      fontSize: DesignConstants.FONT_SIZE_MEDIUM,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 장비 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                return _buildMaterialCard(entry.value[index]);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  /// 재료 카드
  Widget _buildMaterialCard(EquipmentInstance equipment) {
    final isSelected = mSelectedMaterials.contains(equipment);
    final canSelect = mSelectedMaterials.length < 3 && _canAddMaterial(equipment);
    final rarityColor = equipment.data.rarity.color;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          setState(() {
            mSelectedMaterials.remove(equipment);
            mFusionResult = null;
            _updateFilter();
          });
        } else if (canSelect) {
          setState(() {
            mSelectedMaterials.add(equipment);
            mFusionResult = null;
            _updateFilter();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? rarityColor.withValues(alpha: 0.3)
              : canSelect
                  ? Colors.white10
                  : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? rarityColor
                : canSelect
                    ? Colors.white24
                    : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      equipment.data.slot.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 이름
                Text(
                  equipment.data.name,
                  style: TextStyle(
                    color: canSelect || isSelected ? Colors.white : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 레벨
                Text(
                  'Lv.${equipment.level}',
                  style: TextStyle(
                    color: canSelect || isSelected ? rarityColor : Colors.white24,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            // 선택 체크
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 재료 추가 가능 여부 확인
  bool _canAddMaterial(EquipmentInstance equipment) {
    if (mSelectedMaterials.isEmpty) return true;

    // 첫 번째 재료와 같은 슬롯/등급이어야 함
    final first = mSelectedMaterials.first;
    return equipment.data.slot == first.data.slot &&
        equipment.data.rarity == first.data.rarity;
  }

  /// 필터 업데이트
  void _updateFilter() {
    if (mSelectedMaterials.isEmpty) {
      mFilterSlot = null;
      mFilterRarity = null;
    } else {
      mFilterSlot = mSelectedMaterials.first.data.slot;
      mFilterRarity = mSelectedMaterials.first.data.rarity;
    }
  }

  /// 합성 실행
  void _performFusion() {
    final result = widget.equipmentSystem.FuseEquipments(mSelectedMaterials);

    setState(() {
      if (result != null) {
        mFusionResult = result;
        mSelectedMaterials.clear();
        _showFusionSuccessDialog(result);
      } else {
        _showFusionFailDialog();
      }
    });
  }

  /// 합성 성공 다이얼로그
  void _showFusionSuccessDialog(EquipmentInstance result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              '합성 성공!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result.data.rarity.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: result.data.rarity.color),
              ),
              child: Column(
                children: [
                  Text(
                    result.data.slot.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.data.name,
                    style: TextStyle(
                      color: result.data.rarity.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    result.data.rarity.displayName,
                    style: TextStyle(
                      color: result.data.rarity.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                mFusionResult = null;
              });
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 합성 실패 다이얼로그
  void _showFusionFailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(
              '합성 실패',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          '합성 조건을 확인해주세요.\n동일 슬롯, 동일 등급의 장비 3개가 필요합니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
