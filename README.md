# simple-gist-api-test

## Overview 

This was just a quick exercise to play with the gists API but also to 
try out the Bats testing framework.

Overall the lessons learned are as follows
1. Bash/shell scripts have some quirks and I've learned alot
2. Mocking/stubbing with Bats can be done but isn't easy (there are extra
   packages for Bats that might have made this easier)
3. The testing too way more effort than the script itself

That last point is somewhat an argument against TDD for shell scripts :(


## Quickstart

Ensure that the following are installed:
1. bash
2. curl
3. jq 

See installation section below for more details

Run the script

```
./get_user_gists.sh -u <username>
```


## Installation

### MacOS

Use [homebrew][homebrew] to install the `jq` utility 

```
brew install jq
```

Bash and curl are already installed on a Mac 


### Linux

Use the appropriate package manager to install `jq` and possibily `curl`.
The `bash` shell should already be available

### Windows

Maybe you should uses a virtual machine, Windows Subsystem for Linux or just 
buy a Mac or a Linux machine :D 


## Tests

### Prerequisites

Tests are written using [BATS][BATS] this can be installed using [homebrew][homebrew] on MacOS

```
brew install bats-core
```

Or on Linux `apt install bats` for Debian does not appear to find a new enough
version of BATS to install.  They are stuck at 1.2 whereas Fedora 36, RHEL 8,
and OpenSUSE have > 1.5.0.

Should be possible to use `yum install bats` or `dnf install bats` on a 
recent RPM-based distro to get a version of BATS that is suitable

Alternatively you could clone the [Bats repo](https://github.com/bats-core/bats-core) and add the bin directory to the path (not tested this approach). 
There is also a [docker image](https://hub.docker.com/r/bats/bats) which can 
be used by mounting the code to test under the `/code/` volume.

TODO: Add instructions on using Docker image on x86 and ARM linux platforms


### Running

You can run the tests for the script using 

```
bats tests/get_user_gists_test.bats
```

If you want to see the log output from the tests then run this command

```
bats --show-output-of-passing-tests tests/get_user_gists_test.bats
```

NOTE: This option doesn't appear to be supported on version 1.2 on Debian


## Test Data

There doesn't appear to be an obvious source of the top gist contributors or some similar way 
to find a user with a significant number of entries.  So I tried to look for developers I 
actually know about that might have at least some gists.

This was actually pretty time-consuming and not entirely fruitful!

I finally found [Charity Majors' github](https://github.com/charity) as she is the co-author 
of the book "Database Reliability Engineering" with [Laine Campbell](https://github.com/lainevcampbell)

There are 14 [gists from Charity](https://gist.github.com/charity) at the time of writing this code
which is at least enough to give a basic test and to construct more test data from this.

Also found [Audrey Tang](https://en.wikipedia.org/wiki/Audrey_Tang) who has 89 [gists](https://gist.github.com/audreyt)

### Investigation

THe following commands will retrieve sample data

```
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/<user>/gists
```

using these for user IDs 

* charity
* audreyt

For Charity's results there are less than the default page size of 30 so there is no indication 
of any [pagination][Github Pagination] in the response to the curl request, e.g. no sign of 
links to next page or size of data, etc.

As per the [github page traversal docs][Github Pagination Traversal] using `curl -I` to look at
the headers alone

```
curl -I -vvv -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/audreyt/gists
```

This gives the link header

```
link: <https://api.github.com/user/20723/gists?page=2>; rel="next", <https://api.github.com/user/20723/gists?page=3>; rel="last"
```

Running this command 

```
curl -I -vvv -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/audreyt/gists\?page=3
```

Gives this header

```
link: <https://api.github.com/user/20723/gists?page=2>; rel="prev", <https://api.github.com/user/20723/gists?page=1>; rel="first"
```


## References

### Testing

* [BATS testing framework][BATS]
* [BATS documentation][BATS Docs]

### Gist API 

* [Gists API documentation][Gists API]
* [Github pagination][Github Pagination]
* [Pagination traversal][Github Pagination Traversal]


### Jq

* [Jq cheat sheet](https://lzone.de/cheat-sheet/jq)
* [Output CSV using jq](https://stackoverflow.com/questions/32960857/how-to-convert-arbitrary-simple-json-to-csv-using-jq)
* [Map to CSV output](https://unix.stackexchange.com/questions/163845/using-jq-to-extract-values-and-format-in-csv)


### Shell script

* [Echo to STDERR](https://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr)
* [Redirecting STDERR](https://stackoverflow.com/questions/3130375/bash-script-store-stderr-in-a-variable/3130425#3130425)
* [Parsing arguments](https://www.computerhope.com/unix/bash/getopts.htm)
* [Declaring bash variables](https://www.mssqltips.com/sqlservertip/5762/introduction-to-bash-scripting-for-sql-server-declaration-of-variables-and-constants/)
* [Bash local variables](https://tldp.org/LDP/abs/html/localvar.html)
* [Getting all variables](https://unix.stackexchange.com/questions/3510/how-to-print-only-defined-variables-shell-and-or-environment-variables-in-bash)
* [Regular expression construct](https://stackoverflow.com/questions/21112707/check-if-a-string-matches-a-regex-in-bash-script)
* [Bash conditional constructs](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)
* [Difference between exit and return](https://stackoverflow.com/questions/4419952/difference-between-return-and-exit-in-bash-functions)
* [Local in bash swallows return code of command](https://stackoverflow.com/questions/4421257/why-does-local-sweep-the-return-code-of-a-command)
* [Propagating shell functions](https://docstore.mik.ua/orelly/unix3/upt/ch29_13.htm)
* [Size of FIFO](https://stackoverflow.com/questions/48945547/change-named-pipe-buffer-size-in-macos)
* [Make temporary files](https://www.gnu.org/software/autogen/mktemp.html)
* [Create sequence](https://www.cyberciti.biz/tips/how-to-generating-print-range-sequence-of-numbers.html)


[BATS]: https://github.com/bats-core/bats-core
[BATS Docs]: https://bats-core.readthedocs.io/en/stable/
[homebrew]: https://brew.sh
[Gists API]: https://docs.github.com/en/rest/gists
[Github Pagination]: https://docs.github.com/en/rest/overview/resources-in-the-rest-api#pagination 
[Github Pagination Traversal]: https://docs.github.com/en/rest/guides/traversing-with-pagination
