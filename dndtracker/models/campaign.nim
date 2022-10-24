import norm/[model, sqlite]

import user

import ../database

const KIND_NONE* = 0

# =================== Spell =========== #

type
  SpellSchoolKind* = enum
    conjuration = 1

  Spell* = ref object of Model
    name*: string
    level*: int
    school*: int
    castingTime*: int
    distance*: int
    verbal*: bool
    somatic*: bool
    material*: string
    duration*: int
    description*: string

# =================== Item =========== #

  ItemKind* = enum
    itemOther = 1,
    armor,
    weapon,
    tool,

  Item* = ref object of Model
    name*: string
    description*: string
    kind*: int
    cost*: int
    weight*: int
    data*: string # json

# =================== Feature =========== #

type
  FeatureKind* = enum
    featureOther = 1,
    speed,
    armorProf,
    weaponProf,
    toolProf,
    savingThrowProf,
    skillProf,
    damageResistance,
    damageImmunity,
    conditionImmunity,
    sense,
    language,
    action,

  AbilityScoreKind* = enum
    strength = 1,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma

  SpeedKind* = enum
    walk = 1,
    burrow,
    climb,
    fly,
    swim,

  RecoveryKind* = enum
    recoveryOther = 1,
    action,
    shortRest,
    longRest,

  Feature* = ref object of Model
    name*: string
    description*: string
    kind*: int
    subKind*: int
    recovery*: int
    data*: string # json

# =================== Group =========== #

  GroupKind* = enum
    groupOther* = 1,
    background,
    race,
    subRace,
    class,
    subClass,
    feat,

  Group* = ref object of Model
    name*: string
    description*: string
    kind*: int
    optionGroup*: OptionGroup

  OptionGroup* = ref object of Model
    name*: string
    description*: string
    group*: Group

  GroupFeature* = ref object of Model
    group*: Group
    feature*: Feature
    level*: int
    data*: string # json

# =================== StatBlock =========== #

type
  SizeKind* = enum
    tiny = 1,
    small,
    medium,
    large,
    huge,

  StatBlock* = ref object of Model
    size*: int
    lawful*: int
    good*: int
    armorClass*: int
    strength*: int
    dexterity*: int
    constitution*: int
    intelligence*: int
    wisdom*: int
    charisma*: int
    proficiencyBonus*: int
    data*: string # json

# =================== Character =========== #

type
  Character* = ref object of Model
    user*: User
    name*: string
    statBlock*: StatBlock
    background*: Background
    experiencePoints*: int
    inspiration*: bool
    initiative*: int
    maxHitPoints*: int
    currentHitPoints*: int
    temporaryHitPoints*: int
    exhaustion*: int
    backstory*: string
    data*: string # json

  CharacterGroup* = ref object of Model
    character*: Character
    group*: Group
    level*: int

  CharacterFeature* = ref object of Model
    character*: Character
    group*: Group
    feature*: Feature
    maxUses*: int
    remainUses*: int
    data*: string

  PreparedSpell* = ref object of Model
    character*: Character
    feature*: Feature
    spell*: Spell

  AvailableSpell* = ref object of Model
    character*: Character
    feature*: Feature
    spell*: Spell

  CharacterItem* = ref object of Model
    character*: Character
    item*: Item
    quantity*: int
    data*: string # json

proc newCharacter*(user: User): Character =
  Character(user: user)

proc newCharacter*: Character =
  newCharacter(newUser())

proc addCharacter*(user: User) =
  let db = getDatabase()
  var character = newCharacter(user)
  db.insert(character)
