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
    value*: string # json

# =================== Background =========== #

type
  Background* = ref object of Model
    name*: string
    description*: string

  BackgroundFeature* = ref object of Model
    background*: Background
    feature*: Feature

# =================== Class =========== #

type
  Class* = ref object of Model
    name*: string
    hitDice*: int

  ClassFeature* = ref object of Model
    class*: Class
    feature*: Feature
    level*: int

  SubClass* = ref object of Model
    name*: string
    class*: Class

  SubClassFeature* = ref object of Model
    subClass*: SubClass
    feature*: Feature
    level*: int

# =================== Race =========== #

type
  Race* = ref object of Model
    name*: string
    description*: string
    abilityScore*: AbilityScore

  RaceFeature* = ref object of Model
    race*: Race
    feature*: Feature

  SubRace* = ref object of Model
    name*: string
    race*: Race
    description*: string
    abilityScore*: AbilityScore

  SubRaceFeature* = ref object of Model
    subRace*: SubRace
    feature*: Feature

# =================== StatBlock =========== #

type
  StatBlock* = ref object of Model
    lawful*: int
    good*: int
    armorClass*: int
    maxHitPoints*: int
    abilityScore*: AbilityScore

  StatBlockFeature* = ref object of Model
    statBlock*: StatBlock
    feature*: Feature

# =================== Character =========== #

type
  Character* = ref object of Model
    user*: User
    name*: string
    background*: Background
    race*: Race
    subRace*: SubRace
    experiencePoints*: int
    inspiration*: bool
    proficiencyBonus*: int
    initiative*: int
    currentHitPoints*: int
    temporaryHitPoints*: int
    statBlock*: StatBlock
    notes*: string

  CharacterClass* = ref object of Model
    character*: Character
    class*: Class
    subClass*: SubClass
    level*: int

proc newCharacter*(user: User): Character =
  Character(user: user)

proc newCharacter*: Character =
  newCharacter(newUser())

proc addCharacter*(user: User) =
  let db = getDatabase()
  var character = newCharacter(user)
  db.insert(character)
