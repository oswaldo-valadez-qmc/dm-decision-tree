"use strict";

require("dotenv").config();

const express = require("express");
const expressLayouts = require("express-ejs-layouts");

const path = require("path");

const router = require("./src/routes");

// Init app
const app = express();

// Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Template engine setup
app.set("view engine", "ejs");
app.set("layout extractScripts", true);
app.set("view options", { openDelimiter: "{{", closeDelimiter: "}}" });
app.set("views", path.join(__dirname, "./src/views"));

// Template engine layout
app.use(expressLayouts);
app.set("layout", "layouts/dashboard");

// Router
app.use(router);

// Makes the admin-lte (package) dependency on node_modules static and accessible
app.use(
  "/adminlte",
  express.static(path.join(__dirname, "/node_modules/admin-lte"))
);

// Makes PUBLIC static and accessible
app.use("/public", express.static(path.join(__dirname, "/public")));

// Handle error 404
app.use(function (req, res, next) {
  if (req.user) {
    res.status(404).render("error404");
  } else {
    res.status(404).render("error404", { layout: "layouts/main" });
  }
  next();
});

// Set LISTEN PORT
app.listen(process.env.PORT, () => {
  console.log(`App listening at http://localhost:${process.env.PORT}`);
});
