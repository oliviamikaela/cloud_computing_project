// api/server.js

const express = require("express");
const cors = require("cors");
var bodyParser = require("body-parser");

const app = express();

// create application/json parser
var jsonParser = bodyParser.json();

// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false });

//use cors to allow cross origin resource sharing
app.use(cors());

app.post("/", jsonParser, function (req, res) {
  console.log(req.body);
  if (req.body[0] == true && req.body[1] == false) {
    excTerraform(req.body[2]);
  } else if (req.body[1] == true && req.body[0] == false) {
    killTerraform();
  }
});

app.listen(8080, () => {
  console.log("app listening on port 8080");
});

function excTerraform(script) {
  const exec = require("child_process").exec;
  const child = exec(script, (error, stdout, stderr) => {
    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
    if (error !== null) {
      console.log(`exec error: ${error}`);
    }
  });
}

function killTerraform() {
  const exec = require("child_process").exec;
  const child = exec(
    "terraform apply -destroy -auto-approve",
    (error, stdout, stderr) => {
      console.log(`stdout: ${stdout}`);
      console.log(`stderr: ${stderr}`);
      if (error !== null) {
        console.log(`exec error: ${error}`);
      }
    }
  );
}
