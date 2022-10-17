import norm/[model, sqlite]

import user

import ../database

type
  AbilityScore* = ref object of Model
    strength*: int
    dexterity*: int
    constitution*: int
    intelligence*: int
    wisdom*: int
    charisma*: int

  Language* = ref object of Model
    name*: string
    description*: string

  Sense* = ref object of Model
    name*: string
    description*: string

  Skill* = ref object of Model
    name*: string
    description*: string
    abilityKind*: int

  Speed* = ref object of Model
    walk*: int
    swim*: int
    climb*: int
    fly*: int
    burrow*: int

# =================== Background =========== #

type
  Background* = ref object of Model
    name*: string
    description*: string

  BackgroundLanguage* = ref object of Model
    background*: Background
    kind*: Language

  BackgroundSkill* = ref object of Model
    background*: Background
    kind*: Skill

# =================== Race =========== #

type
  Race* = ref object of Model
    name*: string
    description*: string
    speed*: Speed
    abilityScore*: AbilityScore

  RaceLanguage* = ref object of Model
    race*: Race
    kind*: Language

  RaceSkill* = ref object of Model
    race*: Race
    kind*: Skill
    bonusMutliplier*: float

  RaceSense* = ref object of Model
    race*: Race
    kind*: Sense
    distance*: int

# =================== StatBlock =========== #

type
  StatBlock* = ref object of Model
    lawful*: int
    good*: int
    armorClass*: int
    hitPoints*: int
    speed*: Speed
    abilityScore*: AbilityScore

  StatBlockLanguage* = ref object of Model
    statBlock*: StatBlock
    kind*: Language

  StatBlockSense* = ref object of Model
    statBlock*: StatBlock
    kind*: Sense
    distance*: int

# =================== Character =========== #

type
  Character* = ref object of Model
    user*: User
    name*: string
    background*: Background
    race*: Race
    experiencePoints*: int
    proficiencyBonus*: int
    statBlock*: StatBlock
    notes*: string

  CharacterSkill* = ref object of Model
    character*: Character
    kind*: Skill
    bonusMutliplier*: float

  CharacterSavingThrow* = ref object of Model
    character*: Character
    kind*: int
    bonusMultiplier*: float

