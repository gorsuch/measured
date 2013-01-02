# measured

An experimental endpoint for papertrail webhooks that converts properly formatted log lines into statsd metrics.

An example of a valid log line:

```
measure=foo.bar value=1
```

Note that `measure=foo.bar` and `value=1` can be anywhere within the line.

The resultant metric sent on to statsd would be `foo.bar:1|g`.
