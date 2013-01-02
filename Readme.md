# measured

An experimental HTTP endpoint for papertrail webhooks that exports [`l2met`](https://github.com/ryandotsmith/l2met)-style log data to graphite.

It accepts Papertrail `POSTS` requests on `/` and converts lines that looks like this to graphite metrics:

```
measure=foo.bar value=1
```
