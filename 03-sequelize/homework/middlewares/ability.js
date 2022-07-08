const { Router } = require("express");
const { Ability } = require("../db");
const router = Router();

module.exports = router;

router.post("/", async (req, res) => {
  const { name, mana_cost } = req.body;

  if (!name || !mana_cost) {
    return res.status(404).send("Falta enviar datos obligatorios");
  } else {
    try {
      const newAbility = await Ability.create(req.body);
      res.status(201).json(newAbility);
    } catch (e) {
      res.status(404).send("Error en alguno de los datos provistos");
    }
  }
});

router.put("/setCharacter", async (req, res) => {
  const { idAbility, codeCharacter } = req.body;

  const ability = await Ability.findByPk(idAbility);
  await ability.setCharacter(codeCharacter);
  res.json(ability);
});
