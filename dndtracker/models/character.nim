import norm/[model, sqlite]

import user

import ../database

# =================== Character =========== #

type
  Character* = ref object of Model
    user*: User
    name*: string
    constitution*: int
    dexterity*: int
    strength*: int
    charisma*: int
    intelligence*: int
    wisdom*: int

proc newCharacter*(user: User): Character =
  Character(user: user,
    name: "",
    constitution: 0,
    dexterity: 0,
    strength: 0,
    charisma: 0,
    intelligence: 0,
    wisdom: 0)

proc newCharacter*: Character =
  Character(user: newUser(),
    name: "",
    constitution: 0,
    dexterity: 0,
    strength: 0,
    charisma: 0,
    intelligence: 0,
    wisdom: 0)

proc addCharacter*(user: User) =
  let db = getDatabase()
  var character = newCharacter(user)
  db.insert(character)
