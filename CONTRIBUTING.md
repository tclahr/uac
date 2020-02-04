## Welcome
We welcome contributions to the UAC project in many forms, and there's always plenty to do!

First things first, please review the project's [Code of Conduct](CODE_OF_CONDUCT.md) before participating. It is important that we keep things civil.

### Reporting bugs
If you are a user and you find a bug, please submit an [issue](https://github.com/tclahr/uac/issues). Please try to provide sufficient information for someone else to reproduce the issue. One of the project's [maintainers](MAINTAINERS.md) should respond to your issue soon.

### Fixing issues and working stories
Review the [issues list](https://github.com/tclahr/uac/issues) and find something that interests you. It is wise to start with something relatively straight forward and achievable. Usually there will be a comment in the issue that indicates whether someone has already self-assigned the issue. If no one has already taken it, then add a comment assigning the issue to yourself, eg.: ```I'll work on this issue.```. Please be considerate and rescind the offer in comments if you cannot finish in a reasonable time, or add a comment saying that you are still actively working the issue if you need a little more time.

We are using the [GitHub flow](https://guides.github.com/introduction/flow/) process to manage code contributions. If you are unfamiliar, please review that link before proceeding.

To work on something, whether a new feature or a bugfix:
  1. Create a [fork](https://help.github.com/articles/fork-a-repo/) (if you haven't already)

  2. Clone it locally
  ```
  git clone https://github.com/tclahr/uac.git
  ```
  3. Add the upstream repository as a remote
  ```
  git remote add upstream https://github.com/tclahr/uac.git
  ```
  4. Create a branch

  Create a descriptively-named branch off of your cloned fork ([more detail here](https://help.github.com/articles/syncing-a-fork/))
  ```
  git checkout -b issue-nnnn
  ```
  5. Commit your code

  Commit to that branch locally, and regularly push your work to the same branch on the server.

  6. Commit messages

  Commit messages must have a short description no longer than 50 characters followed by a blank line and a longer, more descriptive message that includes reference to issue(s) being addressed so that they will be automatically closed on a merge e.g. ```Closes #1234``` or ```Fixes #1234```.

  7. Pull Request (PR)

  When you need feedback or help, or you think the branch is ready for merging, open a pull request (make sure you have first successfully tested your changes on all supported Operating Systems).

   _Note: if your PR does not merge cleanly, use ```git rebase master``` in your feature branch to update your pull request rather than using ```git merge master```_.

  8. Any code changes that affect documentation should be accompanied by corresponding changes (or additions) to the documentation and tests. This will ensure that if the merged PR is reversed, all traces of the change will be reversed as well.

After your Pull Request (PR) has been reviewed and signed off, a maintainer will merge it into the master branch.

### Legal stuff
We have tried to make it as easy as possible to make contributions. This applies to how we handle the legal aspects of contribution. We use the same approach&mdash;the [Developer's Certificate of Origin 1.1 (DCO)](DCO-1.1.txt)&mdash;that the Linux&reg; Kernel [community](http://elinux.org/Developer_Certificate_Of_Origin) uses to manage code contributions.
We simply ask that when submitting a pull request, the developer must include a sign-off statement in the pull request description.

Here is an example Signed-off-by line, which indicates that the submitter accepts the DCO:

```
Signed-off-by: John Doe <john.doe@hisdomain.com>
```

## Getting help
Please feel free to contact me via [tclahr@gmail.com](mailto:tclahr@gmail.com) or [tclahr@br.ibm.com](mailto:tclahr@br.ibm.com).
