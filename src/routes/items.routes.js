"use strict";

const router = require("express").Router();

const itemsController = require("../controllers/items.controller");

router.route("/").get(itemsController.render1RItems);

router.route("/discretize-range").get(itemsController.renderDiscretizeRangeItems);

module.exports = router;
