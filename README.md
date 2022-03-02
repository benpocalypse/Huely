# Huely

![Huely icon](./data/128.svg)

Control WiFi lights using this simple app.

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.benpocalypse.Huely])

## System requirements

  - [elementary OS](https://elementary.io) 6 (Odin)

## Developer notes

### Getting started

Clone this repository and run the install task:

```shell
task/install
```

You can now run the app from either the _Applications Menu_ or using the run task:

```shell
task/run
```

### About

This project is written in [Vala](https://valadoc.org/) and follows the following elementary OS guidelines:

  - [Human Interface Guidelines](https://docs.elementary.io/hig/)
  - [Developer Guidelines](https://docs.elementary.io/develop/)
  - [Coding style](https://docs.elementary.io/develop/writing-apps/code-style)

Please take some time to familiarise yourself with those documents before continuing.

To get your system ready to develop for elementary OS, please see the [Basic Setup](https://docs.elementary.io/develop/writing-apps/the-basic-setup) section of the [elementary OS Developer Documentation](https://docs.elementary.io/develop/).

### Tasks

#### Install

Configures and runs the build, installs settings-related features and translations and refreshes the icon cache.

Run this after you clone this repository to get a working build.

```shell
task/install
```

#### Build

Builds the project.

```shell
task/build
```

#### Run

Builds and runs the executable.

```shell
task/run
```

#### Package

Creates a Flatpak package.

```shell
task/package
```

#### Run Package

Creates and runs a Flatpak package.

```shell
task/run-package
```

#### Take screenshots

Takes screenshots of your app in both the light and dark colour schemes and also creates a montage of the two for use in the AppCenter.

For ideas on how to customise this script for more complicated screenshots, see [the take-screenshots script for Comet](https://github.com/small-tech/comet/blob/main/task/take-screenshots).

```shell
task/take-screenshots
```

> You must push the generated screenshots folder to your GitHub repository before the screenshot will appear when you preview your app in AppCenter.

#### Publish

There is a simple web site for Huely in the _docs/_ folder.

If GitHub pages is enabled for the app, you can view the site at https://benpocalypse.github.io/Huely

The site has an Install button that links to the Flatpak repository. People can use this button to sideload the app directly from its website.

To publish this Flatpak repository, use this task:

```shell
task/publish
```

> You must push the generated Flatpak repository to your GitHub repository and enable GitHub pages (or host it elsewhere – e.g., using [Site.js](https://sitejs.org)) before people will be able install your app.

#### Preview in AppCenter

Launches app locally in AppCenter so you can preview how it will look when published.

Optionally, you can specify a language code (e.g., `tr_TR`) to preview a specific localisation.

```shell
task/preview-in-appcenter <language-code>
```

## Continuous integration

[Continuous Integration](https://docs.elementary.io/develop/writing-apps/our-first-app/continuous-integration) is set up for this repository.

## It’s elementary, my dear…

This project was initially generated by [Watson](https://github.com/small-tech/watson), a tool for quickly setting up a new elementary OS 6 app that follows platform [human interface](https://docs.elementary.io/hig/) and [development](https://docs.elementary.io/develop/) guidelines.

## Copyright and license

Copyright &copy; 2022-present Ben Foote

Licensed under [GNU GPL version 3.0](./LICENSE).
