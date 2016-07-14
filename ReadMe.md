This is an example MVC app with added scripting to create a docker image and container for hosting it on Windows 2016 Server Core.

Build should work out of the box, but to get Ctrl+F5 to start the container you will need to customize the debug settings of the project. They should look something like:

![settings](settings.png)

If build isn't working, then most likely the hardcode environment variables in DockerTask.ps1 need to be updated. You can get the correct values for your system by starting a developer command prompt and running set to see the values of those variables in that environment.
