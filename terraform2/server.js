// api/server.js

const express = require("express");
const cors = require("cors");
var bodyParser = require("body-parser");

const app = express();

const fs = require("fs");

const path = "./login_info.txt";
const readLastLines = require("read-last-lines");

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

var checkIp = true;
setInterval(checkFile, 10000);

function checkFile() {
  var output = [];
  var count;
  if (checkIp) {
    if (fs.existsSync(path)) {
      // path exists
      console.log("exists:", path);
      readLastLines.read("./login_info.txt", 1).then((lines) => {
        //console.log(line);
        output.push(lines);
      });

      function get_line(filename, line_no, callback) {
        var data = fs.readFileSync(filename, "utf8");
        var lines = data.split("\n");

        if (+line_no > lines.length) {
          throw new Error("File end reached without finding line");
        }

        callback(null, lines[+line_no]);
      }

      get_line("./login_info.txt", 2, function (err, line) {
        //console.log("The line: " + line);
        output.push(line);
      });
      app.get("/ip", jsonParser, function (req, res) {
        res.send(output);
        console.log(output);
        checkIp = false;
      });
    } else {
      console.log("DOES NOT exist:", path);
    }
  }
}

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
    "terraform apply -destroy -auto-approve -lock=false",
    (error, stdout, stderr) => {
      console.log(`stdout: ${stdout}`);
      console.log(`stderr: ${stderr}`);
      if (error !== null) {
        console.log(`exec error: ${error}`);
      }
    }
  );
}
