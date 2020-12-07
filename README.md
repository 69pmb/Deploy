# Deploy
Builds and deploys Angular/Node.js apps into APK file and to remote server.

## Params
|Param          |Description                                            |Required    |Type  |
|:--------------|:------------------------------------------------------|:----------:|:----:|
|java_path      |Java 8 path to used to build APK file                  |Only for APK|Path  |
|web_dir        |Target folder of the remote server                     |Yes         |Path  |
|apps           |Array of apps                                          |            |[]    |
|app.name       |Name of the folder app                                 |Yes         |String|
|app.type       |*cordova* to generate an APK file                      |Only for APK|String|
|app.output_dir |Target folder where the generated APK will be deposited|Only for APK|Path  |
|app.size       |Minimum size in *KB* of the APK file                   |Only for APK|Number|
|app.port       |Application port on the server                         |Yes         |Number|

## Steps
1. *Cordova* steps:
    1. `yarn cordova` to build the app with a specific *base-href*
    1. `cordova build android` generating the APK file
    1. Renames the file by `app.name_YYYY.MM.dd'T'HH.mm.ss.apk`
    1. Moves it to the specify `app.output_dir`
    1. Tests if its size is greater than `app.size`
2. Remote server steps:
    1. `yarn build` to build the app in production mode
    1. Inserts the build timestamp in `index.html`, replacing the `{{timestamp}}` placeholder
    1. Copies the *dist* generated folder to the *web_dir*
    1. Moves the *package.json* and *server.js* files if not exists and replacing app name and port with the ones specifies. *Forever* will be used to run the application
    1. `yarn` if no *node_modules* folder found
