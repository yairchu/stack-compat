# stack-compat

Build old Stack 1 projects with Stack 2

Used for `git bisect`ing over history where newer versions of stack are installed.

## Related tips

### macOS

If Stack 2.1.1 fails with `tar: Option --force-local is not supported`,
then is a bug with newer version of Stack
which can be worked around via `brew install gnu-tar` and
creating a symlink to it named `tar` in your path shadowing macOS's bundled `tar`.
