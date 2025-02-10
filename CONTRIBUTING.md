# Welcome

We welcome contributions to the UAC project in many forms, and there's always plenty to do!

First things first, please review the project's [Code of Conduct](CODE_OF_CONDUCT.md) before participating. We must keep things civil.

Here are a couple of things we are looking for help with:

## New artifacts

Have you identified a new artifact that is still not collected by UAC? Please create a new artifact and submit it via a new Pull Request.

Please see [Artifacts definition](https://tclahr.github.io/uac-docs/artifacts/) docs for more information.

## New features

You can request a new feature by submitting an issue to our GitHub Repository. If you would like to implement a new feature, please submit an issue with a proposal for your work first, to be sure that we can use it. This will also allow us to better coordinate our efforts, prevent duplication of work, and help you craft the change so that it is successfully accepted into the project.

## Found a bug?

If you are a user and you find a bug, please submit an [issue](https://github.com/tclahr/uac/issues). Please try to provide sufficient information for someone else to reproduce the issue. One of the project's [maintainers](MAINTAINERS.md) should respond to your issue soon.

Please search within our [already-reported bugs](https://github.com/tclahr/uac/issues) before raising a new one to make sure you're not raising a duplicate.

## Tutorials

Share your experience with the community about how UAC is helping you by writing an article about it. Or write a How-To or Tutorial on how to use UAC for specific cases and let us know. We'd love to share your work with the rest of the community by including it in our docs.

## Submission guidelines

### Submitting an issue

Before you submit an issue, please search the issue tracker, maybe an issue for your problem already exists and the discussion might inform you of workarounds readily available.

We want to fix all the issues as soon as possible, but before fixing a bug we need to reproduce and confirm it. To reproduce bugs we will systematically ask you to provide sufficient information for someone else to reproduce the issue.

Unfortunately, we are not able to investigate/fix bugs without a minimal reproduction, so if we don't hear back from you we are going to close an issue that doesn't have enough info to be reproduced.

### Submitting a Pull Request (PR)

Before you submit your Pull Request (PR) consider the following guidelines. We are using the [GitHub flow](https://guides.github.com/introduction/flow/) process to manage code contributions. If you are unfamiliar, please review that link before proceeding.

The repo holds two main branches:

**main**: Where the source code of HEAD always reflects a production-ready state.

**develop**: Where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. When the source code in the develop branch reaches a stable point and is ready to be released, all of the changes will be merged back into the main branch and then tagged with a release number.

All Pull Requests must be submitted to the **develop** branch.

1. Search [GitHub](https://github.com/tclahr/uac/pulls) for an open or closed PR that relates to your submission. You don't want to duplicate effort.

1. Create a [fork](https://help.github.com/articles/fork-a-repo) (if you haven't already).

1. Clone it locally.

```shell
git clone git@github.com:YOUR_GITHUB_USERNAME/uac.git
```

1. Add the upstream repository as a remote.

```shell
git remote add upstream git@github.com:tclahr/uac.git
```

1. Create a new develop branch.

```shell
git checkout -b develop
```

1. Make sure your local develop branch is up to date with the upstream one.

```shell
git pull upstream develop
```

1. Make your changes in a new branch.

```shell
git checkout -b my-feature-branch develop
```

1. Create your code following our [Coding Rules](#coding-rules).

1. Test your code against as many systems as you can. For instance, your code can fully work on a Linux but not on a FreeBSD system.

1. Commit your changes using a descriptive commit message that follows our [commit message guidelines](#commit-message-guidelines). *Don't commit code as an unrecognized author. Having commits with unrecognized authors makes it more difficult to track who wrote which part of the code. Ensure your Git client is configured with the correct email address and linked to your GitHub user.*

  ```shell
  git commit -s
  ```

1. Push your branch to GitHub.

  ```shell
  git push origin my-feature-branch
  ```

1. In GitHub, open a Pull Request and select the **develop** branch as the base. Never send a Pull Request to **main**.

- If we suggest changes then:
  - Make the required updates using the same branch.
  - Re-run the tests.
  - Push to your GitHub repository (this will update your Pull Request).

That's it! Thank you for your collaboration!

#### After your Pull Request is merged

After your pull request is merged, you can safely delete your branch and pull the changes from the develop (upstream) repository:

- Check out the develop branch:

```shell
git checkout -f develop
```

- Delete the remote branch on GitHub either through the GitHub web UI or your local shell as follows:

```shell
git push origin --delete my-feature-branch
```

- Delete the local branch:

```shell
git branch -D my-feature-branch
```

- Update your develop branch with the latest upstream version:

```shell
git pull --ff upstream develop
```

## Coding rules

To ensure consistency throughout the source code, keep these rules in mind as you are working:

- You can use the [Shell Style Guide](https://google.github.io/styleguide/shellguide.html) as a reference. Keep in mind that UAC is meant to run on any bourne shell, so some features like arrays, command substitution ```$(command)``` and tests ```[[ ... ]]``` are not fully supported by most of them.
- Use [ShellCheck](https://www.shellcheck.net) to identify common bugs and warnings in your code.

## Commit message guidelines

We have very precise rules over how our git commit messages can be formatted. This leads to more readable messages that are easy to follow when looking through the project history.

Each commit message consists of a **header**, a **blank line** and a **body**. The header has a special format that includes a **type** and a **subject**.

```text
<type>: <subject>
<BLANK LINE>
<body>
```

Any line of the commit message cannot be longer than 100 characters! This allows the message to be easier to read on GitHub as well as in various git tools.

Samples:

```text
docs: update changelog to v2.0.0
fix: fixed issue #15
```

### Type

Must be one of the following:

- **docs**: Documentation only changes.
- **feat**: A new feature.
- **artif**: A new artifact or changes to an existing one.
- **fix**: A bug fix.
- **perf**: A code change that improves performance.
- **refactor**: A code change that neither fixes a bug nor adds a feature.
- **style**: Changes that do not affect the meaning of the code (white space, formatting, missing semi-colons, etc).

### Subject

The subject must contain a succinct description of the change:

- use the imperative, present tense: "change" not "changed" nor "changes"
- don't capitalize the first letter
- no dot (.) at the end

### Body

Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes". The body should include the motivation for the change and contrast this with previous behavior. It also needs to include any references to issue(s) being addressed (e.g. Closes #15, Fixes #21).
