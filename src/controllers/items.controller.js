"use strict";

const ErrorHandler = require("../utils/helpers/error-handler");

const Items = require("../models/items.model");

exports.render1RItems = async (req, res, next) => {
  try {
    const items = await Items.getAll1RItems();

    res.render("modules/items/items", {
      items,
      type: "1R",
    });
  } catch (error) {
    ErrorHandler.handleError(req, res, error);
  }
};

exports.renderDiscretizeRangeItems = async (req, res, next) => {
  try {
    const items = await Items.getAllDiscretizeRangeItems();

    res.render("modules/items/items", {
      items,
      type: "Discretize Range",
    });
  } catch (error) {
    ErrorHandler.handleError(req, res, error);
  }
};
