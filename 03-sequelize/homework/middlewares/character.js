const { Router } = require("express");
const { Op, Character, Role } = require("../db");
const router = Router();

module.exports = router;

router.post("/", async (req, res) => {
  const { code, name, hp, mana } = req.body;
  if (!code || !name || !hp || !mana) {
    return res.status(404).send("Falta enviar datos obligatorios");
  } else {
    try {
      const newCharacter = await Character.create(req.body);
      res.status(201).json(newCharacter);
    } catch (e) {
      res.status(404).send("Error en alguno de los datos provistos");
    }
  }
});

router.get("/", async (req, res) => {
  const { race, age } = req.query;

  const condition = {};
  const where = {};
  if (race) where.race = race;
  if (age) where.age =age;
  if (where) condition.where = where;
  const characters = await Character.findAll(condition);
  res.json(characters);

  //Metodo menos óptimo
  // if (race && age){
  //   const characters = await Character.findAll({
  //     where: {
  //       race,
  //       age
  //     }
  //   });
  //   return res.json(characters);
  // }
  // const people = await Character.findAll();
  // res.json(people);
});

router.get("/young", async (req, res) => {
  const people = await Character.findAll({
    where: {
      age: {
        [Op.lt]: 25,
      },
    },
  });
  res.json(people);
});

router.get("/roles/:code", async (req, res) => {
  const { code } = req.params;

  const character = await Character.findByPk(code, {
    include: Role,
  });
  res.json(character);
});

router.get("/:code", async (req, res) => {
  const { code } = req.params;
  const character = await Character.findOne({
    where: {
      code,
    },
  });
  if (character) {
    return res.json(character);
  }
  return res
    .status(404)
    .send(`El código ${code} no corresponde a un personaje existente`);
});

router.put("/addAbilities", async (req, res) => {
  const { codeCharacter, abilities } = req.body;
  const character = await Character.findByPk(codeCharacter);
  const promises = abilities.map((a) => character.createAbility(a));
  await Promise.all(promises);
  res.send("OK");
});

router.put("/:attribute", async (req, res) => {
  const { attribute } = req.params;
  const { value } = req.query;
  const people = await Character.update(
    { [attribute]: value },
    { where: { [attribute]: null } }
  );
  res.send(`Personajes actualizados`);
});
