# MongoCheck
A sound filter for analyzing NoSQL (MongoDB) queries for injection attacks

## 🔌 Requirements

- Node >= v18.0 

## 💿 Installation

### Dependencies
- bs58
- nearley
- replace

MongoCheck is not yet available in the NPM package registry, but can be manually installed by requiring the package like so.
```js
const nosqlcheck = require("./nosqlcheck.js");
```

## Usage

```js
const nosqlcheck = require("./nosqlcheck.js");
const checker = new nosqlcheck();
const augmentedQuery = {
  username: checker.trackInput(username),
  password: checker.trackInput(password),
};

const isBenign = checker.checkQuery(augmented_query);
```

## 🧪 Experiments

All available attack vectors were tried from [Swissky's PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/NoSQL%20Injection) repo.
MongoCheck was succsesfully able to identify all attack vectors. Additionally, we tested 1000 benign queries and no false positives were reported.

## How it works

For a more detailed explanation of how it works, see our attached paper [NoSQL Injection Detection Using Context-Free Grammars](paper.pdf)

We create a [context-free grammar](https://en.wikipedia.org/wiki/Context-free_grammar) (CFG) of MongoDB's query spec. Certain terminal nodes
in the CFG are designated to be input nodes based on the query. A malicious query malforms the underlying syntax tree described by the CFG 
to allow for injection attacks. If the underlying tree resulting from applying the user's input differs from the unadulterated tree, then
an input can be deemed to be malicious.

## Limitations

MongoCheck does not scan query inputs where the expected input form is arbitrary, executable javascript code. 

## 📄 TODO
- [ ] Simplify API (remove unnecessary trackInput call and just have a single checkQuery)
- [ ] Make installable as an NPM package
- [ ] Expand set of supported grammars to other NoSQL database query schema
