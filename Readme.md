# measured

An experimental HTTP endpoint for papertrail webhooks that exports [`l2met`](https://github.com/ryandotsmith/l2met)-style log data to graphite.

It accepts Papertrail `POSTS` requests on `/` and converts lines that looks like this to graphite metrics:

```
measure=foo.bar value=1
```

The resultant metric would be `measurement.foo.bar`.  If the logline contains a `timestamp` message, that will be used otherwise one will be provided for you.

The `carbon` endpoint can be configured by modifying `CARBON_URL`.
