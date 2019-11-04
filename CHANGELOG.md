# Changed

All notable changes to this project will be documented in this file.

## [v1.1.0] - Sunday, November 3, 2019

 - Bump development and release dependencies to latest versions

## [v1.0.1] - Tuesday, December 18, 2018

 - Add `dependent: :destroy` to audits association
 - Stop tracking `Event::DESTROY` when model is destroyed

## [v1.0.0] - Thursday, February 15, 2018

 - Enabling changed configuration for the `Changed.config.default_changer_proc`.
 - Restructuring `Changed.config` to `Changed.perform`

## [v0.1.0] - Thursday, February 15, 2018

 - Setup `Changed::Audit`, `Changed::Association` for all things changed.
 - Migrated over default set of specifications and libraries into engine.
 - Configuration Circle CI, RSpec, SimpleCov, etc.
