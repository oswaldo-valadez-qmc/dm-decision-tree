"use strict";

const router = require("express").Router();

const itemsRoutes = require("./items.routes");

router.use("/", itemsRoutes);

module.exports = router;
