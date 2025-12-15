### How to use
1. copy the script (`vm_setup.sh`) to your home directory
2. execute it by running the command
   ```bash   
   bash vm_setup.sh
   ```
3. choose which components should be installed by pressing `y` or `n` when prompted
4. insert your credentials when prompted (you can find docker credentials on your local machine `cat ~/.git-credentials .gitconfig` and docker credentials `cat ~/.docker/config.json`, copy the hash string in "auth" and decode it with `echo <auth-string> | base64 -d` - you'll get <docker_username>@<docker_password>
5. ⚠️ IMPORTANT: disconnect and reconnect to the vm when the script run is finished, so you user will be added to group `docker`. Otherwise, you will not be able to use docker
