"use strict";

const { pool } = require("../utils/database/query");

const inputs = [
  // "rating_top",
  // "reviews_text_count",
  "genre",
  "tag",
  // "metacritic",
  // "added",
  "beaten",
  "dropped",
  // "owned",
  "playing",
  // "playtime",
  // "rating",
  // "ratings_count",
  // "reviews_count",
  // "suggestions_count",
  // "toplay",
  // "yet",
];

const disc = { beaten: true, dropped: true, playing: true };

const cond = `"(genre = 'Adventure'
OR genre = 'Indie'
OR genre = 'Family'
OR genre = 'Racing'
OR genre = 'Strategy'
OR genre = 'Rpg')
AND dropped > 50
AND beaten > 29
AND tag = 'Dark'
AND playing > 41
"`;

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
