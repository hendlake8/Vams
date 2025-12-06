import '../../core/utils/logger.dart';
import '../../data/models/weapon_data.dart';
import '../vam_game.dart';

/// 무기 시스템 - 무기 장착 및 스킬 연결 관리
/// 무기는 기본 스킬을 내장하고 있으며, 무기를 장착하면 해당 스킬이 자동 활성화됨
class WeaponSystem {
  final VamGame mGame;

  // 장착된 무기
  WeaponData? mEquippedWeapon;
  int mWeaponLevel = 1;

  WeaponSystem(this.mGame);

  /// 무기 장착 - 무기의 기본 스킬을 자동으로 활성화
  void EquipWeapon(String weaponId, {int level = 1}) {
    final weaponData = DefaultWeapons.GetById(weaponId);
    if (weaponData == null) {
      Logger.e('Unknown weapon: $weaponId');
      return;
    }

    mEquippedWeapon = weaponData;
    mWeaponLevel = level;

    // 무기에 내장된 기본 스킬 활성화
    mGame.skillSystem.AddSkill(weaponData.baseSkillId, level: level);

    // 습득 스킬 목록에도 추가 (UI 표시용)
    mGame.levelSystem.mAcquiredSkills[weaponData.baseSkillId] = level;

    Logger.game('Weapon equipped: ${weaponData.name} (Skill: ${weaponData.baseSkillId})');
  }

  /// 무기 레벨업 - 기본 스킬도 함께 레벨업
  void UpgradeWeapon() {
    if (mEquippedWeapon == null) return;

    mWeaponLevel++;
    mGame.skillSystem.AddSkill(mEquippedWeapon!.baseSkillId, level: mWeaponLevel);

    // 습득 스킬 목록도 업데이트
    mGame.levelSystem.mAcquiredSkills[mEquippedWeapon!.baseSkillId] = mWeaponLevel;

    Logger.game('Weapon upgraded: ${mEquippedWeapon!.name} Lv.$mWeaponLevel');
  }

  /// 시스템 업데이트 (스킬 발동은 SkillSystem에서 처리)
  void Update(double dt) {
    // 무기 시스템은 이제 스킬 시스템에 위임하므로 별도 로직 불필요
  }

  /// 리셋
  void Reset() {
    mEquippedWeapon = null;
    mWeaponLevel = 1;
    // 기본 무기 장착
    EquipWeapon('weapon_starter_wand', level: 1);
  }

  /// 장착된 무기 정보
  WeaponData? get weapon => mEquippedWeapon;
  int get weaponLevel => mWeaponLevel;
}
