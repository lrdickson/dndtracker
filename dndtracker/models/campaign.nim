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

  Feature* = ref object of Model
    name*: string
    description*: string
    logic*: string # Pseudocode?

  Language* = ref object of Model
    name*: string
    description*: string

  Proficiency* = ref object of Model
    name*: string
    description*: string
    kind*: int
    abilityKind*: int

  Sense* = ref object of Model
    name*: string
    description*: string

  Speed* = ref object of Model
    walk*: int
    swim*: int
    climb*: int
    fly*: int
    burrow*: int

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

# =================== Background =========== #

type
  Background* = ref object of Model
    name*: string
    description*: string

  BackgroundFeature* = ref object of Model
    background*: Background
    kind*: Feature

  BackgroundLanguage* = ref object of Model
    background*: Background
    kind*: Language

  BackgroundProficiency* = ref object of Model
    background*: Background
    kind*: Proficiency

# =================== Class =========== #

type
  Class* = ref object of Model
    name*: string
    hitDice*: int

  ClassFeature* = ref object of Model
    class*: Class
    kind*: Feature
    level*: int

  ClassProficiency* = ref object of Model
    class*: Class
    kind*: Proficiency

  SubClass* = ref object of Model
    name*: string
    class*: Class

  SubClassFeature* = ref object of Model
    subClass*: SubClass
    kind*: Feature
    level*: int

# =================== Race =========== #

type
  Race* = ref object of Model
    name*: string
    description*: string
    speed*: Speed
    abilityScore*: AbilityScore

  RaceFeature* = ref object of Model
    race*: Race
    kind*: Feature

  RaceLanguage* = ref object of Model
    race*: Race
    kind*: Language

  RaceProficiency* = ref object of Model
    race*: Race
    kind*: Proficiency

  RaceSense* = ref object of Model
    race*: Race
    kind*: Sense
    distance*: int

  SubRace* = ref object of Model
    name*: string
    race*: Race
    description*: string
    speed*: Speed
    abilityScore*: AbilityScore

  SubRaceFeature* = ref object of Model
    subRace*: SubRace
    kind*: Feature

  SubRaceLanguage* = ref object of Model
    subRace*: SubRace
    kind*: Language

  SubRaceProficiency* = ref object of Model
    subRace*: SubRace
    kind*: Proficiency

  SubRaceSense* = ref object of Model
    subRace*: SubRace
    kind*: Sense
    distance*: int

# =================== StatBlock =========== #

type
  StatBlock* = ref object of Model
    lawful*: int
    good*: int
    armorClass*: int
    maxHitPoints*: int
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
    kind*: Class
    subKind*: SubClass
    level*: int

  CharacterFeature* = ref object of Model
    character*: Character
    kind*: Feature

  CharacterProficiency* = ref object of Model
    character*: Character
    kind*: Proficiency
    bonusMutliplier*: float

proc newCharacter*(user: User): Character =
  Character(user: user)

proc newCharacter*: Character =
  newCharacter(newUser())

proc addCharacter*(user: User) =
  let db = getDatabase()
  var character = newCharacter(user)
  db.insert(character)
