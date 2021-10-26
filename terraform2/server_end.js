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
