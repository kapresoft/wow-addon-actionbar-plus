## In case of taint log 

In Wow Client, Enable taint Log
```
/console taintLog 1
/reload
```

In Shell:
- may need to refresh
```bash
cd [WOW-DIR]
tail -f Logs/taint.log
```

In Wow, Disable taint log if needed:
> If you restart wow client (exit app and open again), it will reset back taint log being off.  But if you don't restart wow client, then just issue the command to turn off taint log.
```
/console taintLog 0
/reload
```
