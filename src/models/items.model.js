"use strict";

const { pool } = require("../utils/database/query");

const inputs = ["genre", "tag", "beaten", "dropped", "playing"];

const disc = { beaten: true, dropped: true, playing: true };

const cond = `null`;

const output = "classification";

exports.getAll1RItems = async () => {
  const items = [];

  for (let i = 0; i < inputs.length; i++) {
    const input = inputs[i];

    var uniq = `null`;

    if (disc[input]) {
      const aux = (
        await pool.query(
          `CALL discretize_range("${input}", "${output}", 0.7, ${cond})`
        )
      )[0];

      if (aux[0]) uniq = aux[0].uniq;
    }

    const sub_items = (
      await pool.query(
        `CALL 1R("${input}", ${uniq}, "${output}", 0.7, ${cond})`
      )
    )[0];

    items.push({ uniq, name: input, list: sub_items });
  }

  return items;
};

exports.getAllDiscretizeRangeItems = async () => {
  const items = [];

  for (let i = 0; i < inputs.length; i++) {
    const input = inputs[i];

    const sub_items = (
      await pool.query(
        `CALL discretize_range("${input}", "${output}", 0.7, ${cond})`
      )
    )[0];

    items.push({ name: input, list: sub_items });
  }

  return items;
};
