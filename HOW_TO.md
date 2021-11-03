### Prerequisities 
1. Clone the git hub repository.
2. Make sure Terraform is installed.
3. Source your rc file. 

### To run. 
1. Stand in terrafrom2 folder and run command  
```bash 
node server.js
```
2. Open your web browser and go to link to access the interface  
https://qtl.netlify.app/ 
3. Choose the number of workers and press start. 
4. When all the orchestration is done (this will take up to 1h), the disabled button on the front end will be activated. By clicking on it you will be redirected to the juyputer login page. Login with the login token shown on the interface. Now it is all set up and you can start working with your project. 
5. Press end in the interface when you are done to destroy the intstances. 

### Horizontally scale
To horizontally scale the service one can change the number of workers in the interface and press run. 
