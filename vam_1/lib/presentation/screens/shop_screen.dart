import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/equipment_data.dart';
import '../../data/models/shop_data.dart';
import '../../game/systems/progress_system.dart';

/// 상점 화면
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController mTabController;
  ShopTab mSelectedTab = ShopTab.featured;

  @override
  void initState() {
    super.initState();
    mTabController = TabController(length: ShopTab.values.length, vsync: this);
    mTabController.addListener(() {
      setState(() {
        mSelectedTab = ShopTab.values[mTabController.index];
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
    final progress = ProgressSystem.instance;

    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      appBar: AppBar(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        title: const Text('상점'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: mTabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          tabs: ShopTab.values.map((tab) {
            return Tab(
              icon: Icon(tab.icon, size: 20),
              text: tab.displayName,
            );
          }).toList(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 재화 표시
            _buildCurrencyBar(progress),

            // 상점 아이템 목록
            Expanded(
              child: TabBarView(
                controller: mTabController,
                children: ShopTab.values.map((tab) {
                  return _buildItemGrid(progress, tab);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 재화 표시 바
  Widget _buildCurrencyBar(ProgressSystem progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: DesignConstants.COLOR_SURFACE,
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildCurrencyDisplay(Icons.monetization_on, progress.gold, Colors.amber),
          const SizedBox(width: 16),
          _buildCurrencyDisplay(Icons.diamond, progress.gems, Colors.cyan),
        ],
      ),
    );
  }

  Widget _buildCurrencyDisplay(IconData icon, int amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            _formatNumber(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// 아이템 그리드
  Widget _buildItemGrid(ProgressSystem progress, ShopTab tab) {
    final items = DefaultShopItems.GetByTab(tab);

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '준비 중입니다.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildShopItemCard(progress, items[index]);
      },
    );
  }

  /// 상점 아이템 카드
  Widget _buildShopItemCard(ProgressSystem progress, ShopItemData item) {
    final canPurchase = progress.CanPurchaseItem(item);
    final remaining = progress.GetRemainingPurchases(item);

    return GestureDetector(
      onTap: () => _showItemDetailDialog(progress, item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignConstants.COLOR_SURFACE,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canPurchase ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘 및 타입
            Row(
              children: [
                _buildItemIcon(item),
                const Spacer(),
                if (item.purchaseLimit > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: remaining > 0 ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.isDailyReset ? '일일 $remaining회' : '$remaining회',
                      style: TextStyle(
                        color: remaining > 0 ? Colors.green : Colors.red,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 이름
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 설명
            Expanded(
              child: Text(
                item.description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // 보상 미리보기
            _buildRewardPreview(item),
            const SizedBox(height: 8),
            // 가격
            _buildPriceButton(item, canPurchase),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(ShopItemData item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case ShopItemType.equipment:
        icon = Icons.shield;
        color = Colors.purple;
        break;
      case ShopItemType.currency:
        icon = item.goldAmount != null ? Icons.monetization_on : Icons.diamond;
        color = item.goldAmount != null ? Colors.amber : Colors.cyan;
        break;
      case ShopItemType.special:
        icon = Icons.card_giftcard;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildRewardPreview(ShopItemData item) {
    List<Widget> rewards = [];

    if (item.goldAmount != null && item.goldAmount! > 0) {
      rewards.add(_buildMiniReward(Icons.monetization_on, '${item.goldAmount}', Colors.amber));
    }
    if (item.gemsAmount != null && item.gemsAmount! > 0) {
      rewards.add(_buildMiniReward(Icons.diamond, '${item.gemsAmount}', Colors.cyan));
    }
    if (item.expAmount != null && item.expAmount! > 0) {
      rewards.add(_buildMiniReward(Icons.star, '${item.expAmount}', Colors.purple));
    }
    if (item.equipmentId != null) {
      final equipData = DefaultEquipments.GetById(item.equipmentId!);
      if (equipData != null) {
        rewards.add(_buildMiniReward(Icons.shield, equipData.rarity.displayName, equipData.rarity.color));
      }
    }

    if (rewards.isEmpty) {
      return const SizedBox(height: 20);
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: rewards,
    );
  }

  Widget _buildMiniReward(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPriceButton(ShopItemData item, bool canPurchase) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: canPurchase
            ? item.priceType.color.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canPurchase
              ? item.priceType.color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.priceType != PriceType.free) ...[
            Icon(item.priceType.icon, color: canPurchase ? item.priceType.color : Colors.grey, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            item.priceType == PriceType.free ? '무료' : '${item.price}',
            style: TextStyle(
              color: canPurchase ? item.priceType.color : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 아이템 상세 다이얼로그
  void _showItemDetailDialog(ProgressSystem progress, ShopItemData item) {
    final canPurchase = progress.CanPurchaseItem(item);
    final remaining = progress.GetRemainingPurchases(item);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignConstants.COLOR_SURFACE,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            _buildItemIcon(item),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // 획득 보상
            const Text(
              '획득 보상',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDetailRewards(item),

            if (item.purchaseLimit > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    item.isDailyReset
                        ? '일일 ${item.purchaseLimit}회 한정 (남은 횟수: $remaining)'
                        : '${item.purchaseLimit}회 한정 (남은 횟수: $remaining)',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton.icon(
            onPressed: canPurchase
                ? () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    navigator.pop();
                    final result = await progress.PurchaseItem(item);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: result.success ? Colors.green : Colors.red,
                        ),
                      );
                      setState(() {});
                    }
                  }
                : null,
            icon: Icon(item.priceType.icon),
            label: Text(
              item.priceType == PriceType.free ? '받기' : '${item.price} 구매',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: item.priceType.color,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRewards(ShopItemData item) {
    List<Widget> rewards = [];

    if (item.goldAmount != null && item.goldAmount! > 0) {
      rewards.add(_buildDetailRewardRow(Icons.monetization_on, '골드', '+${item.goldAmount}', Colors.amber));
    }
    if (item.gemsAmount != null && item.gemsAmount! > 0) {
      rewards.add(_buildDetailRewardRow(Icons.diamond, '보석', '+${item.gemsAmount}', Colors.cyan));
    }
    if (item.expAmount != null && item.expAmount! > 0) {
      rewards.add(_buildDetailRewardRow(Icons.star, '경험치', '+${item.expAmount}', Colors.purple));
    }
    if (item.equipmentId != null) {
      final equipData = DefaultEquipments.GetById(item.equipmentId!);
      if (equipData != null) {
        rewards.add(_buildDetailRewardRow(
          Icons.shield,
          equipData.name,
          equipData.rarity.displayName,
          equipData.rarity.color,
        ));
      }
    }
    if (item.id == 'random_equipment') {
      rewards.add(_buildDetailRewardRow(Icons.help_outline, '랜덤 장비', '1개', Colors.orange));
    }
    if (item.id == 'rare_equipment_box') {
      rewards.add(_buildDetailRewardRow(Icons.help_outline, '희귀+ 랜덤 장비', '1개', Colors.blue));
    }

    if (rewards.isEmpty) {
      return const Text('정보 없음', style: TextStyle(color: Colors.white54));
    }

    return Column(children: rewards);
  }

  Widget _buildDetailRewardRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
