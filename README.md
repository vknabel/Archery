# 🏹 Archery
*Archery* allows you to declare all your project's metadata and what you can do with it in one single place.

Within Archery all your data is centralized as JSON in one file called `Archerfile`. The whole content of that file is treated as metadata. Your scripts live within their own section inside the `scripts` key and are therefore metadata, too.

```json
{
	"name": "SupercoolProject",
	"version": "1.0.0",
	"scripts": {
		"greet": {
			"arrow": "vknabel/BashArrow",
			"command": "echo Hello"
      }
  }
}
```
> *Note:* All of these keys are optional. The minimal Archerfile is `{}`.

Besides the name and version of the project, this Archerfile declares the `greet` command. Arrows are Swift scripts or packages that will be downloaded when needed and run using [Mint](https://github.com/yonaskolb/Mint). No matter which arrow you will choose: it comes with all dependencies it needs. The rest is the script config and depends on the chosen arrow. In this case it refers to the [vknabel/BashArrow](https://github.com/vknabel/BashArrow) on Github which requires a `command` beside others.

```bash
$ archery greet
Hello
$ archery greet World
Hello World
```

## Installation


### Using Mint
```bash
$ mint run vknabel/Archery
```

### Using Marathon
```bash
$ marathon run vknabel/archery
```

### Swift Package Manager
```bash
$ git clone https://github.com/vknabel/Archery.git
$ cd Archery
$ swift build -c release
$ cp -f .build/release/archery /usr/local/bin/archery
```

Archery can also be embedded within your own CLI using SwiftPM.

## Available Arrows
Currently the following arrows are known. Feel free to add your own arrows. If you want to write your own arrow head over to [vknabel/ArrowKit](https://github.com/vknabel/ArrowKit/master/README.md) and feel free to add to add your own arrow here.

### Archery
[vknabel/ArcheryArrow](https://github.com/vknabel/ArcheryArrow) Runs multiple scripts
* Automate complex actions by reusing small building blocks
* Combine all steps for a new release into one command
* Enforce code style and code format in a pre-commit hook

### Bash
[vknabel/BashArrow](https://github.com/vknabel/BashArrow) Run bash scripts.
* Write custom arrows in other languages using the `"nestedArrow": true`
* Generate your docs using jazzy

### Beak
[vknabel/BeakArrow](https://github.com/vknabel/BeakArrow) Run functions inside Swift files.
*Based on [yonaskolb/Beak](https://github.com/yonaskolb/Beak)*

* Great to keep related programs together
* Automate your project
* Write custom arrows in Swift using `"nestedArrow": true`

### Stencil
[vknabel/StencilArrow](https://github.com/vknabel/StencilArrow) Render your metadata.
*Based on [kylef/Stencil](https://github.com/kylef/Stencil)*

* Keep your versions up-to-date
* Generate your Podfile
* Create new models or classes

### Marathon
[vknabel/MarathonArrow](https://github.com/vknabel/MarathonArrow) Run Swift scripts.
*Based on [JohnSundell/Marathon](https://github.com/JohnSundell/Marathon)*

* Write arrows that are specific to your project with `"nestedArrow": true`
* Automate your project

### Mint
[vknabel/MintArrow](https://github.com/vknabel/MintArrow) Run CLIs written in Swift. Internally used for all arrows.
*Based on [yonaskolb/Mint](https://github.com/yonaskolb/Mint)*

* Run Swiftlint, SwiftFormat and other scripts
* Install local dependencies when needed



## Development Status
As Archery is still in early development I want every user to know as early as possible what may actually change or break in future. This project uses semantic versioning. Version 1.0.0 will be released when known bugs are fixed, all major features have been implemented and upcoming one can be implemented without breaking changes. Additional requirements are a good documentation and good error messages. Until 1.0 has been reached minor updates may break, but patches will stay patches and hence safe for updates.

### Archerfile Loaders
In bigger projects the `Archerfile` may get huge when used regularly. Later it shall be possible to extract some JSON values into external files and even other scripts. As the `Archerfile` should not be read directly, this update won’t break arrows.

### YAML file format
Especially if your `Archerfile` contains descriptions it will get hard to read soon. As a better format we will replace JSON with YAML, which is a superset of JSON and hence won’t break your configs. As the `Archerfile` should not be read directly, this update won’t break arrows.

## Contributors
* Valentin Knabel, [@vknabel](https://github.com/vknabel), dev@vknabel.com, [@vknabel](https://twitter.com/vknabel) on Twitter


## License
Archery is available under the [MIT](https://github.com/vknabel/archery/master/LICENSE) license.
