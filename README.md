# simple-gist-api-test

## Overview 


## Quickstart


## Tests

Tests are written using [BATS][BATS] this can be installed using [homebrew][homebrew]

```
brew install bats-core
```

Or on Linux `apt install bats` for Debian or `yum install bats` or `dnf install bats` 
for an RPM-based distro such as RHEL/CentOS/Rocky or similar.

You can run the tests for the script using 

```
bats tests/get_user_gists_test.bats
```



## References

* [BATS testing framework][BATS]
* [BATS documentation][BATS Docs]
* [Gists API documentation][Gists API]

[BATS]: https://github.com/bats-core/bats-core
[BATS Docs]: https://bats-core.readthedocs.io/en/stable/
[homebrew]: https://brew.sh
[Gists API]: https://docs.github.com/en/rest/gists
