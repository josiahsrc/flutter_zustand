# Contributing to Zustand

👍🎉 First off, thanks for taking the time to contribute! 🎉👍

The following is a set of guidelines for contributing to Zustand and its packages. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Proposing a change

If you intend to change the public API, or make any non-trivial changes to the implementation, please file an issue first. This lets us reach an agreement on your proposal before you put significant effort into it.

If you’re only fixing a bug, please file an issue detailing what you’re fixing (before creating a pull request). This is helpful in case we don’t accept that specific fix but want to keep track of the issue.

## Creating a pull request

Before creating a pull request please:

1. Fork the repository and create your branch from `master`.
1. Install all dependencies (`flutter packages get` or `pub get`).
1. Squash your commits and ensure you have a meaningful commit message.
1. If you've changed the public API, make sure to update/add documentation.
1. Format your code (`dart format .`).
1. Analyze your code (`dart analyze --fatal-infos --fatal-warnings .`).
1. Create the Pull Request.
1. Verify that all status checks are passing.

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

## License

By contributing to Zustand, you agree that your contributions will be licensed under its MIT license.

## Attribution

This file was adapted from [Felix Angelov's Equatable package](https://github.com/felangel/equatable/blob/master/CONTRIBUTING.md).
