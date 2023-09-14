const crypto = require("crypto");
const bs58 = require("bs58");
const fs = require("fs");
const replace = require("replace");
const execFile = require("child_process").execFileSync;
const nearley = require("nearley");

function NoSqlCheck(non_terminals) {
  if (non_terminals === []) {
    this.non_terminals = ["id", "key", "string", "num", "boolean"];
  } else {
    this.non_terminals = non_terminals;
  }

  this.unique_non_terminals = new Set(this.non_terminals);
  this.meta_start = null;
  this.meta_end = null;
  this.grammar = null;

  if (fs.existsSync("nosql.ne")) {
    // console.log("NoSQL Grammar found");
    let buf = fs.readFileSync("nosql.ne");
    text = buf.toString();
    matches = text.match(/(?:meta_(start|end)\s->\s)(?:\")(\w+)(?:\")/g);
    let re = /\"(\w+)\"/;
    this.meta_start = matches[0].match(re)[1];
    this.meta_end = matches[1].match(re)[1];

    let meta_internal = null;
    [, , meta_internal] = generateMetaCharacters();
    this.meta_internal = meta_internal;

    if (!fs.existsSync("no_sql_parser.js")) {
      compile("nosql.ne");
    }

    [this.parser, this.grammar] = loadParser();
  } else {
    fs.copyFileSync("nosql_no_lexer.ne", "nosql.ne");
    let meta_start = null;
    let meta_end = null;
    let meta_internal = null;
    [meta_start, meta_end] = generateMetaCharacters();

    this.meta_start = meta_start;
    this.meta_end = meta_end;

    console.log("NoSQL Grammar not found");

    fs.appendFileSync(
      "nosql.ne",
      '\n\nmeta_start -> "' + this.meta_start + '"'
    );
    fs.appendFileSync("nosql.ne", '\nmeta_end -> "' + this.meta_end + '"\n\n');

    let size = this.unique_non_terminals.size;
    this.unique_non_terminals.forEach(function (key, value) {
      console.log("writing");

      let re = new RegExp("\\b" + value + "\\b(?!\\s->)", "gi");

      replace({
        regex: re,
        replacement: value + "_a",
        paths: ["nosql.ne"],
        silent: true,
      });

      augmented_node =
        value +
        "_a" +
        " -> " +
        value +
        " | " +
        "meta_start " +
        '" " ' +
        value +
        " " +
        '" "' +
        " meta_end";
      fs.appendFileSync("nosql.ne", "\n" + augmented_node);
    });

    compile("nosql.ne");
    [this.parser, this.grammar] = loadParser();
  }

  console.log(this);
}

function generateMetaCharacters() {
  const buffer1 = crypto.randomBytes(8);
  const buffer2 = crypto.randomBytes(8);

  const meta_start = bs58.encode(buffer1);
  const meta_end = bs58.encode(buffer2);

  return [meta_start, meta_end];
}

NoSqlCheck.prototype.trackInput = function (input) {
  // console.log("in" + input);
  return this.meta_start + " " + JSON.stringify(input) + " " + this.meta_end;
};

NoSqlCheck.prototype.checkQuery = function (query) {
  let stage1 = JSON.stringify(query);
  let re_start = new RegExp(".(" + this.meta_start + ")", "g");
  let re_end = new RegExp("(" + this.meta_end + ").", "g");

  let re_escaped_quote = new RegExp('(?<!\\\\)\\\\"', "g");

  let unquoted = stage1.replace(re_start, "$1").replace(re_end, "$1");
  let unescaped = unquoted.replace(re_escaped_quote, '"');

  // console.log(query);
  // console.log(stage1);
  // console.log(unquoted);
  // console.log(unescaped);

  try {
    this.parser.feed(unescaped);
    this.resetParser();
    return true;
  } catch (err) {
    console.log(err);
    this.resetParser();
    return false;
  }
};

function compile(nearley_file) {
  execFile("nearleyc", [nearley_file, "-o", "no_sql_parser.js"]);
}

function loadParser() {
  // console.log("Loading Parser");

  let grammar = require("./no_sql_parser.js");
  return [new nearley.Parser(nearley.Grammar.fromCompiled(grammar)), grammar];
}

NoSqlCheck.prototype.resetParser = function () {
  this.parser = new nearley.Parser(nearley.Grammar.fromCompiled(this.grammar));
};

module.exports = NoSqlCheck;
