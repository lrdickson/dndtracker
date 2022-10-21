import norm/[model, sqlite]

import user

import ../database

const KIND_NONE* = 0

type
  AbilityScore* = ref object of Model
    strength*: int
    dexterity*: int
    constitution*: int
    intelligence*: int
    wisdom*: int
    charisma*: int

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

  Feature* = ref object of Model
    name*: string
    description*: string
    kind*: int
    subKind*: int
    data*: string # json

# =================== Background =========== #

type
  Background* = ref object of Model
    name*: string
    description*: string

  BackgroundFeature* = ref object of Model
    background*: Background
    feature*: Feature
    maxUses*: int
    recoveryInterval*: int

# =================== Class =========== #

type
  ParentClass* = ref object of Model
    name*: string
    description*: string

  ParentClassFeature* = ref object of Model
    parentClass*: ParentClass
    feature*: Feature
    level*: int
    maxUses*: int
    recoveryInterval*: int

  Class* = ref object of Model
    name*: string
    description*: string
    parentClass*: ParentClass
    hitDice*: int

  ClassFeature* = ref object of Model
    class*: Class
    feature*: Feature
    level*: int
    maxUses*: int
    recoveryInterval*: int

# =================== Race =========== #

type
  ParentRace* = ref object of Model
    name*: string
    description*: string
    abilityScore*: AbilityScore

  ParentRaceFeature* = ref object of Model
    feature*: Feature
    maxUses*: int
    recoveryInterval*: int

  Race* = ref object of Model
    name*: string
    description*: string
    parentRace*: ParentRace
    abilityScore*: AbilityScore

  RaceFeature* = ref object of Model
    race*: Race
    feature*: Feature
    maxUses*: int
    recoveryInterval*: int

# =================== Character =========== #

type
  Character* = ref object of Model
    user*: User
    name*: string
    background*: Background
    race*: Race
    lawful*: int
    good*: int
    experiencePoints*: int
    abilityScore*: AbilityScore
    inspiration*: bool
    proficiencyBonus*: int
    armorClass*: int
    initiative*: int
    maxHitPoints*: int
    currentHitPoints*: int
    temporaryHitPoints*: int
    backstory*: string
    data*: string # json

  CharacterClass* = ref object of Model
    character*: Character
    class*: Class
    level*: int

  CharacterFeature* = ref object of Model
    character*: Character
    feature*: Feature
    maxUses*: int
    recoveryInterval*: int

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
