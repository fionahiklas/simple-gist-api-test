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




[BATS]: https://github.com/bats-core/bats-core
[BATS Docs]: https://bats-core.readthedocs.io/en/stable/
[homebrew]: https://brew.sh
[Gists API]: https://docs.github.com/en/rest/gists
[Github Pagination]: https://docs.github.com/en/rest/overview/resources-in-the-rest-api#pagination 
[Github Pagination Traversal]: https://docs.github.com/en/rest/guides/traversing-with-pagination
