# Untested
# Function to excecute  run_terraform.sh scritp when start button is clicked
# so it will fun with default number of workers 

# needs connection to interface (how?)

function  terrafrom() {
   const { exec } = require("child_process"); 	
   exec("sh run_terraform.sh -auto-approve")
      if (error) {
         console.log('error: ${error.message}');
         return; 
      }
      if (stderr) {
         console.log('stderr: ${stderr}');
            return; 
      }
      console.log('stdout: ${stdout}'; 
    });
}
