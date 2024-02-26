# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 2024-02-26 - v0.4.3
 - Fixed a bug where upon starting up, after the user already had lights added, they would appear disconnected and Huely would crash if the user interacted with their saved lights.
 - Added metadata for Flathub to add branding colors.

## 2022-10-20 - v0.4.1
 - Fixed a minor bug where the 'searching' display would add a new spinner every time the discover button is clicked.

## 2022-09-29 - v0.4.0
 - Added ability to long click/press a light in the list in order to delete it from Huely.
 - Made a bunch of underlying changes to the gschema to make things more extensible - no user facing changes hopefully.

## 2022-03-25 - v0.3.0
- New features:
    - Brightness - Now each light has a controllable brightness level.
    - Connection and Color - Now each light shows whether it is connected, and what the current color is.

## 2022-03-02 - v0.2.0
- Initial release
